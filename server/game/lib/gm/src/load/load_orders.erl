%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 十一月 2017 上午10:56
%%%-------------------------------------------------------------------
-module(load_orders).

-include("gm_pub.hrl").

-export([
    recharge_order/1
]).

recharge_order(OrderId) ->
    [[Uid, State]] = erl_mysql:ea(<<"SELECT `uid`, `state` FROM orders WHERE order_id = '", OrderId/binary, "';">>),
    if
        State =:= 1 ->
            case redis_online:is_online(Uid) of
                {ok, Node, PidBin} ->
                    Now = integer_to_binary(erl_time:now()),
                    erl_mysql:ea(<<"UPDATE orders SET e_times = ",
                        Now/binary, ",state = 1, out_order_info = '手动补单' WHERE order_id = '"/utf8, OrderId/binary, "';">>),
                    ?rpc_call(Node, Uid, PidBin, ?call_msg(asset_handler, {add_item, OrderId, 1}));
                _ ->
                    ?return_err(?ERR_ARG_ERROR, <<"玩家必须在线！"/utf8>>)
            end;
        true ->
            ?return_err(?ERR_ARG_ERROR, <<"订单状态必须是创建订单！"/utf8>>)
    end.