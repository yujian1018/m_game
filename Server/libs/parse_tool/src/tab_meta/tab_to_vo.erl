%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 12. 十月 2017 下午5:56
%%%-------------------------------------------------------------------
-module(tab_to_vo).

-include("tab_meta.hrl").


-export([
    main/0
]).

main() ->
    crypto:start(),
    emysql:start(),
    {ok, Pools} = application:get_env(emysql, pools),
    case lists:keyfind(pool_dynamic_1, 1, Pools) of
        {pool_dynamic_1, PoolKv} ->
            {_, Database} = lists:keyfind(database, 1, PoolKv),
            TabFields = tab_lookup:tab_fields([{pool_dynamic_1, Database}]),
            file:make_dir("./src/auto/db"),
            lists:map(
                fun(I) ->
                    case lists:member(<<"uid">>, I#tab_fields.pri) of
                        true ->
                            LenPri = length(I#tab_fields.pri),
                            if
                                LenPri =< 2 -> to_record(I);
                                true -> ok
                            end;
                        false -> ok
                    end
                end, TabFields);
        _ ->
            erlang:throw("no pool_dynamic_1")
    end.


to_record(I) ->
    OldRecord =
        case file:read_file("./src/auto/db/" ++ binary_to_list(I#tab_fields.tab_name) ++ "_auto_sql.hrl") of
            {error, enoent} -> <<>>;
            {ok, S} ->
                iolist_to_binary(parse_hrl(I#tab_fields.tab_name, binary:split(S, [<<"\n">>, <<"\r\n">>], [global, trim_all]), [], []));
            _ -> erlang:throw(["read file err", binary_to_list(I#tab_fields.tab_name) ++ "_auto_sql.hrl"])
        end,
    
    TabNameBin = I#tab_fields.tab_name,
    LenPri = length(I#tab_fields.pri),
    {Y, M, D} = erlang:date(),
    RecordName = <<TabNameBin/binary, "_", (integer_to_binary(Y))/binary, (integer_to_binary(M))/binary, (integer_to_binary(D))/binary>>,
    NewRecord = tab_to_vo_meta:hrl_record(I, TabNameBin, RecordName, LenPri),
    Tpl = erl_file:read_file(parse_tool, "/priv/tpl/tab_to_vo/to_hrl.tpl"),
    NewTpl = t_tpl:render(Tpl, [{<<"{{TAB_NAME}}">>, TabNameBin}, {<<"{{RECORD_NAME}}">>, RecordName},
        {<<"{{RECORD}}">>, NewRecord}, {<<"{{OLD_RECORD}}">>, OldRecord}]),
    
    file:write_file("./src/auto/db/" ++ binary_to_list(I#tab_fields.tab_name) ++ "_auto_sql.hrl", NewTpl),
    
    
    Mod = <<TabNameBin/binary, "_auto_sql">>,
    
    LookUP = tab_to_vo_meta:lookup(TabNameBin, LenPri, Mod),
    Keys =
        lists:foldl(
            fun((Field), KeysAcc) ->
                if
                    Field#field.field =:= <<"uid">> -> KeysAcc;
                    KeysAcc =:= <<>> -> <<"`", (Field#field.field)/binary, "`">>;
                    true -> <<KeysAcc/binary, ", `", (Field#field.field)/binary, "`">>
                end
            end, <<>>, I#tab_fields.fields),
    DataLoad = tab_to_vo_meta:load_data(I, TabNameBin, Keys),
    DataSave = tab_to_vo_meta:save_data(I, TabNameBin, LenPri),
    DataToRecord = tab_to_vo_meta:to_record(I, TabNameBin, LenPri),
    Data = tab_to_vo_meta:to_data(I, TabNameBin, LenPri),
    LoadCachePos =
        case length(I#tab_fields.pri) of
            1 -> <<"#?tab_last_name.uid">>;
            2 -> <<"#", TabNameBin/binary, ".uid">>
        end,
    Erl = erl_file:read_file(parse_tool, "/priv/tpl/tab_to_vo/to_erl.tpl"),
    NewErl = t_tpl:render(Erl, [{<<"{{MODULE}}">>, Mod}, {<<"{{KEY_POS}}">>, LoadCachePos},
        {<<"{{LOOKUP}}">>, LookUP},
        {<<"{{LOAD_DATA}}">>, DataLoad},
        {<<"{{SAVE_DATA}}">>, DataSave},
        {<<"{{TO_RECORD}}">>, DataToRecord},
        {<<"{{TO_DATA}}">>, Data}]),
    file:write_file("./src/auto/db/" ++ binary_to_list(I#tab_fields.tab_name) ++ "_auto_sql.erl", NewErl).


parse_hrl(_TabName, [], _ItemAcc, Acc) -> lists:reverse(Acc);
parse_hrl(TabName, [H | R], ItemAcc, Acc) ->
    {NewItemAcc, NewAcc} =
        case H of
            <<"%%", _Other/binary>> -> {ItemAcc, Acc};
            <<"-record(", _Other/binary>> ->
                TabNameByte = byte_size(TabName),
                <<TabName:TabNameByte/binary, Dot:1/binary, _Other2/binary>> = _Other,
                if
                    Dot =:= <<"_">> ->
                        {Y, M, D} = erlang:date(),
                        DateBin = <<(integer_to_binary(Y))/binary, (integer_to_binary(M))/binary, (integer_to_binary(D))/binary>>,
                        DateBinByte = byte_size(DateBin),
                        <<Date:DateBinByte/binary, _Other3/binary>> = _Other2,
                        if
                            Date =:= DateBin -> {ItemAcc, Acc};
                            true -> {[<<"-record(", _Other/binary, "\n">>], Acc}
                        end;
                    Dot =:= <<",">> -> {ItemAcc, Acc};
                    true -> {[<<"-record(", _Other/binary, "\n">>], Acc}
                end;
            <<"}).">> ->
                if
                    ItemAcc =:= [] -> {ItemAcc, Acc};
                    true -> {[], [lists:reverse([<<"}).\n\n\n">> | ItemAcc]) | Acc]}
                end;
            H ->
                if
                    ItemAcc =:= [] -> {ItemAcc, Acc};
                    true -> {[<<H/binary, "\n">> | ItemAcc], Acc}
                end
        end,
    parse_hrl(TabName, R, NewItemAcc, NewAcc).