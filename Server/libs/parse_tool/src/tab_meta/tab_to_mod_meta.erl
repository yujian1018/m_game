-module(tab_to_mod_meta).

-export([
    to_module/1,
    to_record/2,
    to_field/1,
    to_insert/2,
    to_delete/2,
    to_update/4,
    to_lookup/4,
    to_select/2,
    to_validate/0,
    to_validate/1,
    to_default/2
]).

to_module(Mod) ->
    <<"%%%-------------------------------------------------------------------
%%% @doc 自动生成，请不要手动编辑
%%%
%%%-------------------------------------------------------------------
-module(mysql_"/utf8, Mod/binary, ").

-include(\"mysql_tab_record.hrl\").

-export([
    insert/1, insert/2,
    delete/1, delete/2,
    update/1, update/2,
    lookup/1, lookup/2,
    select/1, select/5, select/6,
    validate/2, validate/3,
    to_default/1, to_index/2, record/0, record_info/0
]).

">>.

to_record(Tab, KvList) ->
    Foldl =
        fun({K, Default, Comment}, {Acc, {Index, Totle}}) ->
            NewK = iolist_to_binary(io_lib:format("~-26s", [K])),
            NewComment = case Comment of
                             <<>> -> <<"\n">>;
                             _ -> <<" % ", Comment/binary, "\n">>
                         end,
            if
                Index =:= Totle ->
                    {
                        <<Acc/binary, "    ", NewK/binary, " = <<\"", Default/binary, "\">>", NewComment/binary>>,
                        {Index + 1, Totle}
                    };
                true ->
                    {
                        <<Acc/binary, "    ", NewK/binary, " = <<\"", Default/binary, "\">>,", NewComment/binary>>,
                        {Index + 1, Totle}
                    }
            end
        end,
    {NewRecord, _} = lists:foldl(Foldl, {<<>>, {1, length(KvList)}}, KvList),
    
    <<"-record(", Tab/binary, ", {
", NewRecord/binary, "
}).


">>.

to_field(Fields) ->
    Fun =
        fun(I) ->
            Line = iolist_to_binary(binary:split(iolist_to_binary(io_lib:format("~p", [I])), <<"\n">>, [global, trim_all])),
            <<"%% ", Line/binary, "\n">>
        end,
    lists:map(Fun, Fields).

to_insert(Tab, KvList) ->
    Fields = fun_arg(KvList),
    
    Foldl =
        fun({K, _Default, _Comment}, {FunAcc, Values, Can}) ->
            
            Variate = list_to_binary(string:to_upper(binary_to_list(K))),
            Fun = <<"            ", Variate/binary, " = Fun(Record#", Tab/binary, ".", K/binary, "),\n">>,
            NewV = <<"                \",", Variate/binary, "/binary, \"">>,
            Values1 =
                if
                    Values == <<>> -> NewV;
                    true -> <<Values/binary, ",\n", NewV/binary>>
                end,
            Can1 =
                if
                    Can =:= <<>> ->
                        <<"        fun() -> validate(", Tab/binary, ", <<\"", K/binary, "\">>, Record#", Tab/binary, ".", K/binary, ") end">>;
                    true ->
                        <<Can/binary, ",\n        fun() -> validate(", Tab/binary, ", <<\"", K/binary, "\">>, Record#", Tab/binary, ".", K/binary, ") end">>
                end,
            {<<FunAcc/binary, Fun/binary>>, Values1, Can1}
        end,
    {FunArg, NewValues, NewCan} = lists:foldl(Foldl, {<<>>, <<>>, <<>>}, KvList),
    Pool = list_to_binary(atom_to_list(get(pool))),
    <<"


insert(Record) ->
    case insert(Record, sql) of
        {error, Err} -> {error, Err};
        Sql -> db_mysql:execute(", Pool/binary, ", Sql)
    end.

insert(Record, sql) ->
     case erl_can:can([
", NewCan/binary, "
    ]) of
        {ok, _FieldData} ->
            Fun =
                fun(Key) ->
                    if
                        is_integer(Key) -> integer_to_binary(Key);
                        Key =:= <<\"''\">> -> <<\"''\">>;
                        Key =:= <<>> -> <<\"''\">>;
                        true -> <<\"'\", Key/binary, \"'\">>
                    end
                end,
", FunArg/binary, "
            <<\"insert into `", Tab/binary, "` (", Fields/binary, ") value (
", NewValues/binary, "
                );\">>;
        _Err ->
            _Err
    end.


">>.

to_delete(Tab, []) ->
    <<"delete(_Record) -> io:format(\"table:", Tab/binary, "...no pri_key~n\"), {error, <<\"no_pri_key\">>}.
delete(_Record, sql) -> io:format(\"table:", Tab/binary, "...no pri_key~n\"), {error, <<\"no_pri_key\">>}.

">>;
to_delete(Tab, PRIList) ->
    Foldl = fun({Field, ErlType}, {Arg, Fun, Where}) ->
        Variate = list_to_binary(string:to_upper(binary_to_list(Field))),
        Can = fun_can(Tab, Field, Variate),
        SqlWhere = fun_where(Field, Variate, ErlType),
        
        Arg2 = if
                   Arg == <<>> -> Variate;
                   true -> <<Arg/binary, ",", Variate/binary>>
               end,
        Fun2 = if
                   Fun == <<>> -> Can;
                   true -> <<Fun/binary, ",", Can/binary>>
               end,
        Where2 = if
                     Where == <<>> -> SqlWhere;
                     true -> <<Where/binary, " AND ", SqlWhere/binary>>
                 end,
        {Arg2, Fun2, Where2}
            end,
    {NewArg1, NewFun, NewWhere} = lists:foldl(Foldl, {<<>>, <<>>, <<>>}, PRIList),
    Pool = list_to_binary(atom_to_list(get(pool))),
    NewArg =
        case length(PRIList) of
            1 -> NewArg1;
            _ -> <<"{", NewArg1/binary, "}">>
        end,
    <<"delete(", NewArg/binary, ") ->
    case delete(", NewArg/binary, ", sql) of
        {error, Err} -> {error, Err};
        Sql -> db_mysql:execute(", Pool/binary, ", Sql)
    end.

delete(", NewArg/binary, ", sql) ->
    case erl_can:can([", NewFun/binary, "
    ]) of
        {ok, _} ->
            <<\"delete from ", Tab/binary, " where
            ", NewWhere/binary, ";\">>;
        _Err ->
            _Err
    end.

">>.

to_update(Tab, [], _, _) ->
    <<"update(_Record) -> io:format(\"table:", Tab/binary, "...no pri_key~n\"), {error, <<\"no_pri_key\">>}.
update(_Record, sql) -> io:format(\"table:", Tab/binary, "...no pri_key~n\"), {error, <<\"no_pri_key\">>}.

">>;

to_update(Tab, _, [], _) ->
    <<"update(_Record) -> io:format(\"table:", Tab/binary, "...all pri_key~n\"), {error, <<\"all_pri_key\">>}.
update(_Record, sql) -> io:format(\"table:", Tab/binary, "...no pri_key~n\"), {error, <<\"no_pri_key\">>}.

">>;

to_update(Tab, PRIList, _OtherList, CanKvList) ->
    Foldl =
        fun({Field, ErlType}, {Pri, Where, Num}) ->
            Variate = list_to_binary(string:to_upper(binary_to_list(Field))),
            SqlWhere = fun_where(Field, Variate, ErlType),
            NewWhere = if
                           Where == <<>> -> SqlWhere;
                           true -> <<Where/binary, " AND ", SqlWhere/binary>>
                       end,
            NewPri = if
                         Pri =:= <<>> ->
                             <<"{value, {_, ", Variate/binary, "}, FieldData", (integer_to_binary(Num))/binary, "} = lists:keytake(<<\"", Field/binary, "\">>, 1, FieldData),">>;
                         true ->
                             <<Pri/binary, "\n            {value, {_, ", Variate/binary, "}, FieldData", (integer_to_binary(Num))/binary, "} = lists:keytake(", Field/binary, ", 1, FieldData", (integer_to_binary(Num - 1))/binary, "),">>
                     end,
            {NewPri, NewWhere, Num + 1}
        end,
    {NewPri, NewWhere, _} = lists:foldl(Foldl, {<<>>, <<>>, 0}, PRIList),
    Len = length(PRIList),
    
    NewCan = lists:foldl(
        fun({K, _V, _Comment}, Fields) ->
            if
                Fields =:= <<>> ->
                    <<"        fun() -> validate(", Tab/binary, ", <<\"", K/binary, "\">>, Record#", Tab/binary, ".", K/binary, ") end">>;
                true ->
                    <<Fields/binary, ",\n        fun() -> validate(", Tab/binary, ", <<\"", K/binary, "\">>, Record#", Tab/binary, ".", K/binary, ") end">>
            end
        end, <<>>, CanKvList),
    Pool = list_to_binary(atom_to_list(get(pool))),
    <<"update(Record) ->
    case update(Record, sql) of
        {error, Err} -> {error, Err};
        Sql -> db_mysql:execute(", Pool/binary, ", Sql)
    end.

update(Record, sql) ->
     case erl_can:can([
", NewCan/binary, "
    ]) of
        {ok, FieldData} ->
            ", NewPri/binary, "
            SetAcc = lists:foldl(
                fun({K, Default}, Acc) ->
                    case to_default(K) of
                        Default -> Acc;
                        _ ->
                            V = if
                                    is_integer(Default) -> integer_to_binary(Default);
                                    true -> <<\"'\", Default/binary, \"'\">>
                                end,
                            if
                                Acc =:= <<>> -> <<\"`\", K/binary, \"` = \", V/binary>>;
                                true -> <<Acc/binary, \",`\", K/binary, \"` = \", V/binary>>
                            end
                    end
                end,
                <<>>,
                FieldData", (integer_to_binary(Len - 1))/binary, "),
            <<\"update ", Tab/binary, " set \", SetAcc/binary, \" where
   ", NewWhere/binary, ";\">>;
        _Err ->
            _Err
    end.

">>.


to_lookup(Tab, _, [], _) ->
    <<"lookup(_Record) -> io:format(\"table:", Tab/binary, "...no pri_key~n\"), {error, <<\"no_pri_key\">>}.
lookup(_Record, sql) -> io:format(\"table:", Tab/binary, "...no pri_key~n\"), {error, <<\"no_pri_key\">>}.

">>;

to_lookup(Tab, _, _, []) ->
    <<"lookup(_Record) -> io:format(\"table:", Tab/binary, "...all pri_key~n\"), {error, <<\"all_pri_key\">>}.
lookup(_Record, sql) -> io:format(\"table:", Tab/binary, "...all pri_key~n\"), {error, <<\"all_pri_key\">>}.

">>;

to_lookup(Tab, KvList, PRIList, _OtherList) ->
    Foldl =
        fun({Field, ErlType}, {Arg, Fun, Where}) ->
            Variate = list_to_binary(string:to_upper(binary_to_list(Field))),
            Can = fun_can(Tab, Field, Variate),
            SqlWhere = fun_where(Field, Variate, ErlType),
            
            Arg2 = if
                       Arg == <<>> -> Variate;
                       true -> <<Arg/binary, ",", Variate/binary>>
                   end,
            
            Fun2 = if
                       Fun == <<>> -> Can;
                       true -> <<Fun/binary, ",", Can/binary>>
                   end,
            Where2 = if
                         Where == <<>> -> SqlWhere;
                         true -> <<Where/binary, " AND ", SqlWhere/binary>>
                     end,
            {Arg2, Fun2, Where2}
        end,
    {NewArg1, NewFun, NewWhere} = lists:foldl(Foldl, {<<>>, <<>>, <<>>}, PRIList),
    NewArg =
        case length(PRIList) of
            1 -> NewArg1;
            _ -> <<"{", NewArg1/binary, "}">>
        end,
    NewFields = fun_arg(KvList),
    Data = list_to_binary(string:join([string:to_upper(binary_to_list(K)) || {K, _D, _C} <- KvList], ", ")),
    RecordData = list_to_binary(string:join([binary_to_list(K) ++ " = " ++ string:to_upper(binary_to_list(K)) || {K, _D, _C} <- KvList], ", ")),
    Pool = list_to_binary(atom_to_list(get(pool))),
    <<"lookup(", NewArg/binary, ") ->
    case lookup(", NewArg/binary, ", sql) of
        {error, _Err} -> {error, _Err};
        Sql ->
            case db_mysql:execute(", Pool/binary, ", Sql) of
                [] -> [];
                [[", Data/binary, "]] ->
                    #", Tab/binary, "{", RecordData/binary, "}
            end
    end.

lookup(", NewArg/binary, ", sql) ->
    case erl_can:can([", NewFun/binary, "
    ]) of
        {ok, _} ->
            <<\"select ", NewFields/binary, " from ", Tab/binary, " where
            ", NewWhere/binary, ";\">>;

        _Err ->
            _Err
    end.

">>.




to_select(Tab, KvList) ->
    Fields = fun_arg(KvList),
    Foldl =
        fun({Field, _Default, _Comment}, {AccField, RFCEncode}) ->
            
            NewAccField =
                if
                    AccField =:= <<>> -> list_to_binary(string:to_upper(binary_to_list(Field)));
                    true -> <<AccField/binary, ", ", (list_to_binary(string:to_upper(binary_to_list(Field))))/binary>>
                end,
            NewRFCEncode =
                if
                    RFCEncode =:= <<>> ->
                        <<"{<<\"", Field/binary, "\">>, ", (list_to_binary(string:to_upper(binary_to_list(Field))))/binary, "}">>;
                    true ->
                        <<RFCEncode/binary, ", ", "{<<\"", Field/binary, "\">>, ", (list_to_binary(string:to_upper(binary_to_list(Field))))/binary, "}">>
                end,
            {NewAccField, NewRFCEncode}
        end,
    {NewField, NewEncode} = lists:foldl(Foldl, {<<>>, <<>>}, KvList),
    Pool = list_to_binary(atom_to_list(get(pool))),
    <<"select(Sql) ->
    [[[Count]], Ret] = db_mysql:execute(", Pool/binary, ", Sql),
    Fun =
        fun([", NewField/binary, "]) ->
            {[", NewEncode/binary, "]}
        end,
    {Count, lists:map(Fun, Ret)}.

select(SelectKvList, StartIndex, Len, SortKey, SortType ) ->
    SIndex = integer_to_binary(StartIndex),
    case select(SelectKvList, SIndex, Len, SortKey, SortType, sql) of
        {error, Err} -> {error, Err};
        Sql ->
            select(Sql)
    end.

select(SelectKvList, StartIndex, Len, SortKey, SortType, sql) ->
    SelectArg = lists:foldl(
        fun({Field, Item}, Acc) ->
            case binary_can:illegal_character(Item) of
                false -> Acc;
                true ->
                    Kv = case binary:match(Field, <<\"_begin\">>) of
                             nomatch ->
                                 case binary:match(Field, <<\"_end\">>) of
                                     nomatch ->
                                         case binary:match(Field, <<\"_times\">>) of
                                             nomatch ->
                                                 <<\"`\", Field/binary, \"`='\", Item/binary, \"'\">>;
                                             {_Index3, _Pos3} ->
                                                  <<\"`\", Field/binary, \"`='\", (integer_to_binary(erl_time:time2timer(Item)))/binary, \"'\">>
                                         end;
                                     {Index2, _Pos2} ->
                                         Field2 = binary:part(Field, 0, Index2),
                                         <<\"`\", Field2/binary, \"`<\", (integer_to_binary(erl_time:time2timer(Item)))/binary>>
                                 end;
                             {Index, _Pos} ->
                                 Field1 = binary:part(Field, 0, Index),
                                 <<\"`\", Field1/binary, \"`>=\", (integer_to_binary(erl_time:time2timer(Item)))/binary>>
                         end,
                    if
                        Acc =:= <<>> -> Kv;
                        true -> <<Acc/binary, \" AND \", Kv/binary>>
                    end

            end
        end,
        <<>>,
        SelectKvList),
    OrderBy =
        if
            SortKey == <<\"\">> -> <<>>;
            true ->
                case SortType of
                <<\"0\">> ->
                    <<\" order by \", SortKey/binary, \" \">>;
                <<\"1\">> ->
                    <<\" order by \", SortKey/binary, \" DESC \">>
            end
        end,
    case SelectArg of
        <<>> ->
            <<\"select count(*) from ", Tab/binary, "; select ", Fields/binary, " from ", Tab/binary, " \", OrderBy/binary, \" limit \", StartIndex/binary, \", \", Len/binary, \";\">>;
        _ ->
            <<\"select count(*) from ", Tab/binary, " where \", SelectArg/binary, \"; select ", Fields/binary, " from ", Tab/binary, " where \", SelectArg/binary, OrderBy/binary, \" limit \", StartIndex/binary, \", \", Len/binary, \";\">>
    end.

">>.


to_validate() ->
    <<"validate(Table, Field, Value) ->
    case validate(Field, Value) of
        false ->
            io:format(\"error tab:~p record:~p val:~p validate_fail~n\", [Table, Field, Value]),
            {error, validate_fail};
        true ->
            {ok, {Field, Value}}
    end.


">>.

to_validate(FieldsRecord) ->
    Fun =
        fun({K, DataType, TypeSize, IsNull, Default}) ->
            KArg = list_to_binary(string:to_upper(binary_to_list(K))),
            CheckNull = if
                            IsNull =:= <<"NO">> -> <<"">>;
                            true -> <<"(", KArg/binary, "=:= <<\"", Default/binary, "\">>)">>
                        end,
            {CheckType, Illegal} =
                if
                    DataType =:= int ->
                        {<<"( is_integer(", KArg/binary, ") andalso ", KArg/binary, " >= -2147483648 andalso ", KArg/binary, " =< 2147483648 ) ">>,
                            <<>>};
                    TypeSize =:= null ->
                        {<<"( is_binary(", KArg/binary, ") )">>,
                            <<" andalso binary_can:illegal_character(", KArg/binary, ")">>};
                    DataType =:= binary ->
                        {<<"( is_binary(", KArg/binary, ") andalso byte_size(", KArg/binary, ") =< ", TypeSize/binary, ")">>,
                            <<" andalso binary_can:illegal_character(", KArg/binary, ")">>}
                end,
            if
                CheckNull =:= <<"">> ->
                    <<"validate(<<\"", K/binary, "\">>, ", KArg/binary, ") -> ", CheckType/binary, Illegal/binary, ";\n">>;
                true ->
                    <<"validate(<<\"", K/binary, "\">>, ", KArg/binary, ") -> ", CheckNull/binary, " orelse ", CheckType/binary, Illegal/binary, ";\n">>
            end
        end,
    <<(iolist_to_binary(lists:map(Fun, FieldsRecord)))/binary,
        "validate(_K, _V) ->
    io:format(\"error no field:~p~n\", [[_K, _V]]),
    false.">>.

to_default(Tab, ToRecord) ->
    {ToDefaultAcc, ToIndexAcc} = lists:foldl(
        fun({K, ErlType, Default, _Comment}, {ToDefault, ToIndex}) ->
            V = case binary:match(K, <<"times"/utf8>>) of
                    nomatch ->
                        if
                            ErlType =:= int -> <<"type_can:t2t(V, binary, integer)">>;
                            true -> <<"V">>
                        end;
                    _ ->
                        if
                            ErlType =:= int -> <<"erl_time:time2timer(V)">>;
                            true -> <<"V">>
                        end
                end,
            
            Index = case binary:match(K, <<"times"/utf8>>) of
                        nomatch ->
                            <<"to_index(<<\"", K/binary, "\">>, V) -> {#", Tab/binary, ".", K/binary, ", ", V/binary, "}">>;
                        _ ->
                            <<"to_index(<<\"", K/binary, "\">>, V) -> {#", Tab/binary, ".", K/binary, ", ", V/binary, "};\nto_index(<<\"", K/binary, "_begin\">>, V) -> {#", Tab/binary, ".", K/binary, ", ", V/binary, "};\nto_index(<<\"", K/binary, "_end\">>, V) -> {#", Tab/binary, ".", K/binary, ", ", V/binary, "}">>
                    end,
            if
                ToDefault =:= <<>> ->
                    {
                        <<"to_default(<<\"", K/binary, "\">>) -> <<\"", Default/binary, "\">>">>,
                        Index
                    };
                true ->
                    {
                        <<ToDefault/binary, ";\nto_default(<<\"", K/binary, "\">>) -> <<\"", Default/binary, "\">>">>,
                        <<ToIndex/binary, ";\n", Index/binary>>
                    }
            end
        end, {<<>>, <<>>}, ToRecord),
    
    <<"

", ToDefaultAcc/binary, ".


", ToIndexAcc/binary, ".


record() -> #", Tab/binary, "{}.
record_info() -> record_info(fields, ", Tab/binary, ").">>.



fun_arg(AccRecord) ->
    lists:foldl(
        fun({K, _Default, _Comment}, Fields) ->
            if
                Fields =:= <<>> -> <<"`", K/binary, "`">>;
                true -> <<Fields/binary, ", `", K/binary, "`">>
            end
        end, <<>>, AccRecord).

fun_can(Tab, Field, Variate) ->
    <<"\n        fun() -> validate(", Tab/binary, ", <<\"", Field/binary, "\">>, ", Variate/binary, ") end">>.

fun_where(Field, Variate, ErlType) ->
    if
        ErlType =:= int ->
            <<"`", Field/binary, "` = \",(integer_to_binary(", Variate/binary, "))/binary, \"">>;
        true ->
            <<"`", Field/binary, "` = '\",", Variate/binary, "/binary, \"'">>
    end.