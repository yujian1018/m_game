%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 十月 2017 上午10:39
%%%-------------------------------------------------------------------
-module(tab_to_vo_meta).

-include("tab_meta.hrl").

-export([
    hrl_record/4,
    load_data/3,
    save_data/3,
    lookup/3,
    to_record/3,
    to_data/3

]).

hrl_record(TabFields, Tab, RecordName, LenPri) ->
    Foldl =
        fun(Field, Acc) ->
            if
                LenPri =:= 2 andalso Field#field.field =:= <<"uid">> -> Acc;
                true ->
                    K = Field#field.field,
                    Comment = Field#field.comment,
                    Default1 =
                        if
                            Field#field.erl_type =:= int andalso Field#field.default =:= <<>> -> <<"0">>;
                            Field#field.erl_type =:= int -> Field#field.default;
                            true -> <<"<<\"", (Field#field.default)/binary, "\">>">>
                        end,
                    
                    NewK = iolist_to_binary(io_lib:format("~-26s", [K])),
                    NewComment = case Comment of
                                     <<>> -> <<"">>;
                                     _ -> <<"%%", Comment/binary>>
                                 end,
                    Default = iolist_to_binary(io_lib:format("~-20s", [<<Default1/binary, ",">>])),
                    <<Acc/binary, "    ", NewK/binary, " = ", Default/binary, NewComment/binary, "\n">>
            end
        end,
    NewRecord = lists:foldl(Foldl, <<>>, TabFields#tab_fields.fields),
    
    IsAutoId = lists:member(<<"auto_id">>, TabFields#tab_fields.pri),
    IsUid = lists:member(<<"uid">>, TabFields#tab_fields.pri),
    Tpl =
        if
            IsAutoId andalso IsUid andalso LenPri =:= 2 ->
                <<"-record({{TAB_NAME}}, {\n    uid,\n    max_auto_id = 0,\n    items = []\n}).\n\n\n-record({{RECORD_NAME}}, {\n{{FIELD_ITEMS}}    op = 0  %0 表示不变 1:新增 2:删除 3:更新\n}).\n\n"/utf8>>;
            IsUid andalso LenPri =:= 2 ->
                <<"-record({{TAB_NAME}}, {\n    uid,\n    items = []\n}).\n\n\n-record({{RECORD_NAME}}, {\n{{FIELD_ITEMS}}    op = 0  %0 表示不变 1:新增 2:删除 3:更新\n}).\n\n"/utf8>>;
            true ->
                <<"-record({{RECORD_NAME}}, {\n{{FIELD_ITEMS}}    op = 0  %0 表示不变 1:新增 2:删除 3:更新\n}).\n\n"/utf8>>
        end,
    t_tpl:render(Tpl, [{<<"{{TAB_NAME}}">>, Tab}, {<<"{{RECORD_NAME}}">>, RecordName}, {<<"{{FIELD_ITEMS}}">>, NewRecord}]).


load_data(I, Tab, Keys) ->
    LenPri = length(I#tab_fields.pri),
    IsAutoId = lists:member(<<"auto_id">>, I#tab_fields.pri),
    IsUid = lists:member(<<"uid">>, I#tab_fields.pri),
    Tpl =
        if
            IsAutoId andalso IsUid andalso LenPri =:= 2 ->
                <<"load_data(Uid) ->
    Fun =
        fun([MaxAutoId, VO | VOAcc]) ->
            Record = to_record(Uid, VO),
            NewMaxAutoId =
                case MaxAutoId of
                    [] -> 0;
                    [[?undefined]] -> 0;
                    [[MaxAuto]] -> MaxAuto
                end,
            insert(Record#{{TAB_NAME}}{max_auto_id = NewMaxAutoId}),
            VOAcc
        end,
    {sql(Uid), Fun}.
    
sql(Uid) ->
    UidBin = integer_to_binary(Uid),
    <<\"select max(`auto_id`) from `{{TAB_NAME}}` where uid = \",
        UidBin/binary, \";select {{KEYS}} from `{{TAB_NAME}}` where uid = \",
        UidBin/binary, \";\">>."/utf8>>;
            true ->
                <<"load_data(Uid) ->
    Fun =
        fun([VO | VOAcc]) ->
            Record = to_record(Uid, VO),
            insert(Record),
            VOAcc
        end,
    {sql(Uid), Fun}.

sql(Uid) ->
    <<\"select {{KEYS}} from {{TAB_NAME}} where uid = \", (integer_to_binary(Uid))/binary, \";\">>."/utf8>>
        end,
    t_tpl:render(Tpl, [{<<"{{TAB_NAME}}">>, Tab}, {<<"{{KEYS}}">>, Keys}]).


save_data(I, Tab, LenPri) ->
    {Keys, SaveInsert, SaveUpdate} =
        lists:foldl(
            fun((Field), {KeysAcc, InsertAcc, UpdateAcc}) ->
                KeysAcc1 =
                    if
                        Field#field.field =:= <<"uid">> -> KeysAcc;
                        KeysAcc =:= <<>> -> <<"`", (Field#field.field)/binary, "`">>;
                        true -> <<KeysAcc/binary, ", `", (Field#field.field)/binary, "`">>
                    end,
                NewFieldBin =
                    if
                        Field#field.erl_type =:= binary ->
                            <<"(Record#?tab_last_name.", (Field#field.field)/binary, ")/binary">>;
                        true ->
                            <<"(integer_to_binary(Record#?tab_last_name.", (Field#field.field)/binary, "))/binary">>
                    end,
                InsertAcc1 =
                    if
                        Field#field.field =:= <<"uid">> -> InsertAcc;
                        InsertAcc =:= <<>> ->
                            <<"'\",\n                        ", NewFieldBin/binary, ", \"'">>;
                        true ->
                            <<InsertAcc/binary, ",'\",\n                        ", NewFieldBin/binary, ", \"'">>
                    end,
                UpdateAcc1 =
                    case lists:member(Field#field.field, I#tab_fields.pri) of
                        true -> UpdateAcc;
                        false ->
                            if
                                UpdateAcc =:= <<>> ->
                                    <<(Field#field.field)/binary, " = '\",\n                        ", NewFieldBin/binary, ", \"'">>;
                                true ->
                                    <<UpdateAcc/binary, ",", (Field#field.field)/binary, " = '\",\n                        ", NewFieldBin/binary, ", \"'">>
                            end
                    end,
                {KeysAcc1, InsertAcc1, UpdateAcc1}
            end, {<<>>, <<>>, <<>>}, I#tab_fields.fields),
    
    Tpl =
        if
            ([<<"uid">>, <<"auto_id">>] =:= I#tab_fields.pri) orelse ([<<"auto_id">>, <<"uid">>] =:= I#tab_fields.pri) ->
                <<"save_data(Uid) ->\n    Record = lookup(Uid),\n    save_data_record(Record).

save_data_record(#{{TAB_NAME}}{uid = Uid, items = Items}) ->
    Fun =
        fun(Record) ->
            if
                Record#?tab_last_name.op == ?OP_ADD ->
                    <<\"insert into {{TAB_NAME}} (uid, {{KEYS}}) values ( '\",
                        (integer_to_binary(Uid))/binary, \"', {{INSERT}});\">>;
                Record#?tab_last_name.op == ?OP_UPDATE ->
                    <<\"update {{TAB_NAME}} set {{UPDATE}} where `uid` = \",
                        (integer_to_binary(Uid))/binary, \" and `auto_id` = '\",
                        (integer_to_binary(Record#?tab_last_name.auto_id))/binary,\"';\">>;
                Record#?tab_last_name.op == ?OP_DEL ->
                    <<\"delete from {{TAB_NAME}} where `uid` = \",
                        (integer_to_binary(Uid))/binary, \" and `auto_id` = '\",
                        (integer_to_binary(Record#?tab_last_name.auto_id))/binary,\"';\">>;
                true ->
                    <<>>
            end
        end,
    lists:map(Fun, Items).\n">>;
            LenPri =:= 2 ->
                [ItemKey] = lists:delete(<<"uid">>, I#tab_fields.pri),
                KeyField = lists:keyfind(ItemKey, #field.field, I#tab_fields.fields),
                KeyFieldBin =
                    if
                        KeyField#field.erl_type =:= binary ->
                            <<"(Record#?tab_last_name.", (KeyField#field.field)/binary, ")/binary">>;
                        true ->
                            <<"(integer_to_binary(Record#?tab_last_name.", (KeyField#field.field)/binary, "))/binary">>
                    end,
                
                <<"save_data(Uid) ->\n    Record = lookup(Uid),\n    save_data_record(Record).

save_data_record(#{{TAB_NAME}}{uid = Uid, items = Items}) ->
    Fun =
        fun(Record) ->
            if
                Record#?tab_last_name.op == ?OP_ADD ->
                    <<\"insert into {{TAB_NAME}} (uid, {{KEYS}}) values ( '\",
                        (integer_to_binary(Uid))/binary, \"', {{INSERT}});\">>;
                Record#?tab_last_name.op == ?OP_UPDATE ->
                    <<\"update {{TAB_NAME}} set {{UPDATE}} where uid = \",
                        (integer_to_binary(Uid))/binary, \" and ", ItemKey/binary, " = \",
                        ", KeyFieldBin/binary, ",\";\">>;
                Record#?tab_last_name.op == ?OP_DEL ->
                    <<\"delete from {{TAB_NAME}} where uid = \",
                        (integer_to_binary(Uid))/binary, \" and ", ItemKey/binary, " = \",
                        ", KeyFieldBin/binary, ",\";\">>;
                true ->
                    <<>>
            end
        end,
    lists:map(Fun, Items).\n">>;
            true ->
                <<"save_data(Uid) ->\n    Record = lookup(Uid),\n    save_data_record(Record).

save_data_record(Record) ->
    if
        Record#?tab_last_name.op == ?OP_ADD ->
            <<\"insert into {{TAB_NAME}} (uid, {{KEYS}}) values ('\",
                (integer_to_binary(Record#?tab_last_name.uid))/binary, \"', {{INSERT}});\">>;
        Record#?tab_last_name.op == ?OP_UPDATE ->
            <<\"update {{TAB_NAME}} set {{UPDATE}} where uid = \",
                (integer_to_binary(Record#?tab_last_name.uid))/binary, \";\">>;
        true ->
            <<>>
    end.\n">>
        end,
    t_tpl:render(Tpl, [{<<"{{TAB_NAME}}">>, Tab}, {<<"{{KEYS}}">>, Keys}, {<<"{{INSERT}}">>, SaveInsert}, {<<"{{UPDATE}}">>, SaveUpdate}]).


lookup(Tab, LenPri, Mod) ->
    Tpl =
        if
            LenPri =:= 1 ->
                <<"lookup(Uid) ->
    [Record] = cache:lookup(?tab_name, Uid),
    erl_record:diff_record(Record, #?tab_last_name{}).

lookup(Uid, Index) when is_integer(Index) ->
    Record = lookup(Uid),
    element(Index, Record);

lookup(Uid, Indexs) ->
    Record = lookup(Uid),
    [element(Index, Record) || Index <- Indexs].


lookup_db(Uid, Indexs) ->
    case redis_online:is_online(Uid) of
        {ok, _Pid} ->
            lookup(Uid, Indexs);
        {ok, Node, _Pid} ->
            rpc:call(Node, {{MOD}}, lookup, [Uid, Indexs]);
        false ->
            Record = lookup_record(Uid),
            if
                is_integer(Indexs) -> element(Indexs, Record);
                true -> [element(Index, Record) || Index <- Indexs]
            end
    end.">>;
            LenPri =:= 2 ->
                <<"lookup(Uid) ->
    [Record = #{{TAB_NAME}}{items = Items}] = cache:lookup(?tab_name, Uid),
    Record#{{TAB_NAME}}{items = [erl_record:diff_record(Item, #?tab_last_name{}) || Item <- Items]}.

lookup(Uid, Index) when is_integer(Index) ->
    [#{{TAB_NAME}}{items = Items}] = cache:lookup(?tab_name, Uid),
    [element(Index, erl_record:diff_record(Item, #?tab_last_name{})) || Item <- Items];

lookup(Uid, Indexs) ->
    [#{{TAB_NAME}}{items = Items}] = cache:lookup(?tab_name, Uid),
    [
        [element(Index, erl_record:diff_record(Item, #?tab_last_name{})) || Index <- Indexs]
        || Item <- Items].


lookup_db(Uid, Indexs) ->
    case redis_online:is_online(Uid) of
        {ok, _Pid} ->
            lookup(Uid, Indexs);
        {ok, Node, _Pid} ->
            rpc:call(Node, {{MOD}}, lookup, [Uid, Indexs]);
        false ->
            Record = lookup_record(Uid),
            if
                is_integer(Indexs) -> [element(Indexs, Item) || Item <- Record#{{TAB_NAME}}.items];
                true -> [[element(Index, Item) || Index <- Indexs] || Item <- Record#{{TAB_NAME}}.items]
            end
    
    end.">>
        end,
    t_tpl:render(Tpl, [{<<"{{TAB_NAME}}">>, Tab}, {<<"{{MOD}}">>, Mod}]).


to_record(I, Tab, LenPri) ->
    {IsFunBin, Keys, KvLists} =
        lists:foldl(
            fun(Field, {IsFunBinAcc, KeysAcc, MatchAcc}) ->
                KeysAcc1 =
                    if
                        Field#field.field =:= <<"uid">> -> KeysAcc;
                        KeysAcc =:= <<>> -> list_to_binary(string:to_upper(binary_to_list(Field#field.field)));
                        true ->
                            <<KeysAcc/binary, ", ", (list_to_binary(string:to_upper(binary_to_list(Field#field.field))))/binary>>
                    end,
                {NewV, IsFunBinAcc1} =
                    if
                        Field#field.field =:= <<"uid">> -> {<<"Uid">>, 0};
                        Field#field.erl_type =:= binary ->
                            {<<"FunBin(", (list_to_binary(string:to_upper(binary_to_list(Field#field.field))))/binary, ")">>, 1};
                        true ->
                            {list_to_binary(string:to_upper(binary_to_list(Field#field.field))), 0}
                    end,
                MatchAcc1 =
                    if
                        Field#field.field =:= <<"uid">> andalso LenPri =:= 2 -> MatchAcc;
                        MatchAcc =:= <<>> ->
                            <<(Field#field.field)/binary, " = ", NewV/binary>>;
                        true ->
                            <<MatchAcc/binary, ", ", (Field#field.field)/binary, " = ", NewV/binary>>
                    end,
                IsFunBinAcc2 =
                    if
                        IsFunBinAcc =:= 1 -> 1;
                        true -> IsFunBinAcc1
                    end,
                {IsFunBinAcc2, KeysAcc1, MatchAcc1}
            end, {0, <<>>, <<>>}, I#tab_fields.fields),
    FunBin =
        if
            IsFunBin =:= 1 ->
                <<"FunBin =
        fun(Bin) ->
            if
                Bin =:= ?undefined -> <<>>;
                true -> Bin
            end
        end,">>;
            true -> <<>>
        end,
    Tpl =
        if
            LenPri =:= 2 ->
                <<"to_record(Uid, []) -> #{{TAB_NAME}}{uid = Uid};
to_record(Uid, Data) ->
    {{FUN_BIN}}
    Fun =
        fun([{{KEYS}}]) ->
            #?tab_last_name{{{FIELDS}}}
        end,
    Items = lists:map(Fun, Data),
    #{{TAB_NAME}}{uid = Uid, items = Items}.">>;
            true ->
                <<"to_record(Uid, []) -> #?tab_last_name{uid = Uid, op = ?OP_NULL};
to_record(Uid, Data) ->
    {{FUN_BIN}}
    [[{{KEYS}}]] = Data,
    #?tab_last_name{{{FIELDS}}}.">>
        end,
    t_tpl:render(Tpl, [{<<"{{TAB_NAME}}">>, Tab}, {<<"{{FUN_BIN}}">>, FunBin}, {<<"{{KEYS}}">>, Keys}, {<<"{{FIELDS}}">>, KvLists}]).

to_data(I, Tab, LenPri) ->
    {Kv, KVs} =
        lists:foldl(
            fun(Field, {KVAcc, KVSAcc}) ->
                if
                    Field#field.field =:= <<"uid">> -> {KVAcc, KVSAcc};
                    KVAcc =:= <<>> ->
                        {
                            <<"Record#?tab_last_name.", (Field#field.field)/binary>>,
                            <<"Item#?tab_last_name.", (Field#field.field)/binary>>};
                    true ->
                        {
                            <<KVAcc/binary, ", Record#?tab_last_name.", (Field#field.field)/binary>>,
                            <<KVSAcc/binary, ", Item#?tab_last_name.", (Field#field.field)/binary>>}
                end
            end, {<<>>, <<>>}, I#tab_fields.fields),
    Tpl =
        if
            LenPri =:= 2 ->
                <<"data(Uid) -> to_data(lookup(Uid)).
to_data(Record) ->
    [[{{KVS}}] || Item <- Record#{{TAB_NAME}}.items, Item#?tab_last_name.op =/= ?OP_DEL].">>;
            true ->
                <<"data(Uid) -> to_data(lookup(Uid)).
to_data(Record) ->
    [
        {{KV}}
    ].">>
        end,
    t_tpl:render(Tpl, [{<<"{{TAB_NAME}}">>, Tab}, {<<"{{KVS}}">>, KVs}, {<<"{{KV}}">>, Kv}]).
