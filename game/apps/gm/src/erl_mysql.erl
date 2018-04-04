%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 16. 五月 2016 下午5:23
%%%-------------------------------------------------------------------
-module(erl_mysql).

-include("gm_pub.hrl").

-export([illegal_character/1, execute/2]).

-export([ea/1, es/1, ed/1, el/1, eg/1]).


-export([sql/1]).


-define(ILLEGAL_CHARACTER, [<<"'">>, <<"`">>]).
illegal_character(K) -> illegal_character(K, ?ILLEGAL_CHARACTER).

illegal_character(_K, []) -> true;
illegal_character(K, [Char | Chars]) ->
    case binary:match(K, Char) of
        nomatch -> illegal_character(K, Chars);
        _ -> false
    end.

ea(SQL) -> execute(pool_account_1, SQL).
ed(SQL) -> execute(pool_dynamic_1, SQL).
es(SQL) -> execute(pool_static_1, SQL).
el(SQL) -> execute(pool_log_1, SQL).
eg(SQL) -> execute(pool_gm_1, SQL).


execute(_Pool, <<>>) ->
    <<>>;
execute(_Pool, []) ->
    [];
execute(Pool, SQL) ->
%%    ?WARN("SQL:~ts~n", [SQL]),
    case iolist_to_binary(SQL) of
        <<>> -> <<>>;
        Sql -> execute(Pool, 0, Sql)
    end.


execute(Pool, 6, Sql) ->
    ?ERROR("sql ex error:pool:~p...sql:~p~n", [Pool, Sql]),
    {error, []};


execute(Pool, Num, Sql) ->
    try emysql:execute(Pool, Sql, 30000) of
        {result_packet, _SeqNum, _FieldList, Rows, _Extra} ->
            Rows;
        {ok_packet, _SeqNum, _AffectedRows, InsertId, _Status, _WarningCount, _Msg} ->
            InsertId;
        {error_packet, _SeqNum, _Code, _Status, _Msg} ->
            ?ERROR("emysql:execute error:~p~nPool:~p...SQL:~p~n", [{error_packet, _SeqNum, _Code, _Status, _Msg}, Pool, Sql]),
            {error, 'ERR_EXEC_SQL_ERR'};
        Packets ->
            case catch ret(Packets, []) of
                {throw, 'ERR_EXEC_SQL_ERR'} ->
                    ?ERROR("emysql:execute error POOL:~p...SQL:~ts~n", [Pool, Sql]),
                    {error, 'ERR_EXEC_SQL_ERR'};
                Ret -> Ret
            end
    catch
        _E1:_E2 ->
            if
                _E1 =:= exit andalso _E2 =:= pool_not_found ->
                    ?ERROR("emysql:execute crash:catch:~p~nwhy:~p~nPool:~p...SQL:~p~n", [_E1, _E2, Pool, Sql]),
                    {error, []};
                true ->
                    ?ERROR("emysql:execute crash:catch:~p~nwhy:~p~nPool:~p...SQL:~p~n", [_E1, _E2, Pool, Sql]),
                    timer:sleep(3000),
                    execute(Pool, Num + 1, Sql)
            end
    end.

ret([], Acc) -> lists:reverse(Acc);
ret([{result_packet, _SeqNum, _FieldList, Rows, _Extra} | R], Acc) -> ret(R, [Rows | Acc]);
ret([{ok_packet, _SeqNum, _AffectedRows, InsertId, _Status, _WarningCount, _Msg} | R], Acc) -> ret(R, [InsertId | Acc]);
ret([{error_packet, _SeqNum, _Code, _Status, _Msg} | _R], _Acc) ->
    ?ERROR("emysql:execute error:~p~n SQL_FAIL:~p~nSQL_SUCCESS::~p~n", [{error_packet, _SeqNum, _Code, _Status, _Msg}, _R, _Acc]),
    ?return_err('ERR_EXEC_SQL_ERR').


sql(Values) ->
    FunFoldl = fun(Value, Acc) ->
        NewValue =
            if
                is_integer(Value) -> integer_to_binary(Value);
                true -> Value
            end,
        if
            Acc =:= <<>> -> <<"'", NewValue/binary, "'">>;
            true -> <<Acc/binary, ",'", NewValue/binary, "'">>
        end
               end,
    Sql = lists:foldl(FunFoldl, <<>>, Values),
    <<"(", Sql/binary, ")">>.
