%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 16. 五月 2016 下午5:23
%%%-------------------------------------------------------------------
-module(db_mysql).

-include("erl_pub.hrl").


-export([ea/1, es/1, ed/1, el/1, eg/1]).
-export([execute/2]).


ea(SQL) -> execute(?pool_account_1, SQL).
ed(SQL) -> execute(?pool_dynamic_1, SQL).
es(SQL) -> execute(?pool_static_1, SQL).
el(SQL) -> execute(?pool_log_1, SQL).
eg(SQL) -> execute(?pool_gm_1, SQL).


execute(_Pool, <<>>) ->
    <<>>;
execute(_Pool, []) ->
    [];
execute(Pool, SQL) ->
    do_sql(Pool, SQL).


do_sql(Pool, Sql) ->
%%    ?DEBUG("do_sql(~tp, ~tp)", [Pool, Sql]),
    try emysql:execute(Pool, Sql) of
        {result_packet, _SeqNum, _FieldList, Rows, _Extra} ->
            Rows;
        {ok_packet, _SeqNum, _AffectedRows, InsertId, _Status, _WarningCount, _Msg} ->
            InsertId;
        {error_packet, _SeqNum, _Code, _Status, _Msg} ->
            ?ERROR("emysql error_packet:~p~nPool:~tp...SQL:~tp~n", [{error_packet, _SeqNum, _Code, _Status, _Msg}, Pool, Sql]),
            ?return_err(?ERR_EXEC_SQL_ERR, 'ERR_EXEC_SQL_ERR');
        Packets ->
            case catch ret(Packets, []) of
                {throw, 'ERR_EXEC_SQL_ERR'} ->
                    ?ERROR("emysql error POOL:~tp...SQL:~tp~n", [Pool, Sql]),
                    ?return_err(?ERR_EXEC_SQL_ERR, 'ERR_EXEC_SQL_ERR');
                Ret -> Ret
            end
    catch
        _E1:_E2 ->
            ?ERROR("emysql crash:catch:~tp~nwhy:~tp~nPool:~tp...SQL:~tp~n", [_E1, _E2, Pool, Sql])
    end.


ret([], Acc) -> lists:reverse(Acc);
ret([{result_packet, _SeqNum, _FieldList, Rows, _Extra} | R], Acc) -> ret(R, [Rows | Acc]);
ret([{ok_packet, _SeqNum, _AffectedRows, InsertId, _Status, _WarningCount, _Msg} | R], Acc) -> ret(R, [InsertId | Acc]);
ret([{error_packet, _SeqNum, _Code, _Status, _Msg} | _R], _Acc) ->
    ?ERROR("emysql:execute error:~tp~n SQL_FAIL:~tp~nSQL_SUCCESS::~tp~n", [{error_packet, _SeqNum, _Code, _Status, _Msg}, _R, _Acc]),
    ?return_err('ERR_EXEC_SQL_ERR').
