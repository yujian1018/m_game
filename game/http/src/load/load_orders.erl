%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2016 上午10:02
%%%-------------------------------------------------------------------
-module(load_orders).

-export([
    get_order/0, set_state/2,
    set_order/6,
    set_order_err/3
]).

-include("http_pub.hrl").


get_order() ->
    STimesBin = integer_to_binary(erl_time:now() - 86400),
    Ret = ?rpc_db_call(db_mysql, ea, [<<"select order_id, uid from orders where `status` = 0 and s_times >= ", STimesBin/binary, ";">>]),
    if
        Ret =:= [[0]] -> true;
        true -> false
    end.


set_state(OrderId, Status) ->
    ?rpc_db_call(db_mysql, ea, [<<"UPDATE orders SET status = ", Status/binary, " WHERE order_id = '", OrderId/binary, "' and (status=0 or status = 1);">>]).


set_order(OrderId, OrderNum, OutOrder, Price, RechargeId, OutOrderInfo) ->
    Ret = ?rpc_db_call(db_mysql, ea, [<<"select `status` from orders where order_id = '", OrderId/binary, "';">>]),
    if
        Ret =:= [[0]] orelse Ret =:= [[1]] ->
            Now = integer_to_binary(erl_time:now()),
            ?rpc_db_call(db_mysql, ea, [<<"UPDATE
  orders
SET
    e_times = ", Now/binary, ",
    status = 1,
    recharge_id = '", RechargeId/binary, "',
    amount = ", Price/binary, ",
    out_order = '", OutOrder/binary, "',
    order_num = '", OrderNum/binary, "',
    out_order_info = '", OutOrderInfo/binary, "'
WHERE order_id = '", OrderId/binary, "';
SELECT uid FROM orders WHERE order_id = '", OrderId/binary, "';">>]);
        true -> error
    end.


set_order_err(OrderId, OrderState, OrderErr) ->
    ?rpc_db_call(db_mysql, ea, [<<"UPDATE orders SET status = ", OrderState/binary, " WHERE order_id = '",
        OrderId/binary, "' and (status=0 or status = 1);insert into orders_err (order_id, msg) values ('",
        OrderId/binary, "', '", OrderErr/binary, "') ON DUPLICATE KEY UPDATE msg = '", OrderErr/binary, "';">>]).