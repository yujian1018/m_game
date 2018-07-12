%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 20. 四月 2017 上午11:20
%%%-------------------------------------------------------------------
-module(log_ex).

-include("obj_pub.hrl").

-export([
    sup/0, save_data/2,
    log_share/2, log_share/4,
    log_invite/2, log_invite/4,
    
    log_task/3
]).

sup() ->
    [
        log_login_log,
        {log_pub, log_attr_id_3},
        {log_pub, log_item_id_404001},
        log_share,
        log_invite,
        log_task
    ].


save_data(LogType, Data) ->
    if
        LogType =:= log_login_log ->
            ?rpc_db_cast(db_mysql, el, [Data]);
        LogType =:= log_share ->
            Sql = lists:foldl(fun(I, Acc) ->
                if Acc =:= <<>> -> I;true -> <<Acc/binary, ",", I/binary>> end end, <<>>, Data),
            ?rpc_db_cast(db_mysql, el, [[<<"insert into log_share(uid, channel_type, css_type, c_times, state) values ">>, Sql, <<";">>]]);
        LogType =:= log_invite ->
            Sql = lists:foldl(fun(I, Acc) ->
                if Acc =:= <<>> -> I;true -> <<Acc/binary, ",", I/binary>> end end, <<>>, Data),
            ?rpc_db_cast(db_mysql, el, [[<<"insert into log_invite(uid, channel_type, css_type, c_times, state) values ">>, Sql, <<";">>]]);
        LogType =:= log_task ->
            ?rpc_db_cast(db_mysql, el, [Data]);
        true -> ok
    end.


log_share(Uid, PlatformType, CssType, OpState) ->
    CTimes = integer_to_binary(erl_time:now()),
    log_share ! erl_bin:sql([(integer_to_binary(Uid)), CTimes, (integer_to_binary(PlatformType)), (integer_to_binary(CssType)), (integer_to_binary(OpState))]).

log_share(Uid, OpState) ->
    log_share(Uid, 0, 1, OpState).


log_invite(Uid, OpState) ->
    log_invite(Uid, 0, 1, OpState).

log_invite(Uid, PlatformType, CssType, OpState) ->
    CTimes = integer_to_binary(erl_time:now()),
    log_invite ! erl_bin:sql([(integer_to_binary(Uid)), CTimes, (integer_to_binary(PlatformType)), (integer_to_binary(CssType)), (integer_to_binary(OpState))]).


log_task(Uid, ChainId, Index) ->
    Data = <<"insert into log_task (uid, chain_id, `index`, u_times) values ",
        (erl_bin:sql([Uid, ChainId, Index, erl_time:now()]))/binary,
        " ON DUPLICATE KEY UPDATE `index` =",
        (integer_to_binary(Index))/binary, ", u_times = ",
        (integer_to_binary(erl_time:now()))/binary, ";">>,
    log_task ! Data.

