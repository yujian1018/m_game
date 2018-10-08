%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 19. 七月 2016 下午2:42
%%%-------------------------------------------------------------------
-module(load_orders).

-include("logic_pub.hrl").

-export([
    create_orders/7,
    get_goods_id/1,
    set_orders/2, set_orders/1
]).

create_orders(OrderId, Now, Uid, ChannelId, GoodsId, GoodsNum, Currency) ->
    ?rpc_db_call(db_mysql, ea, [<<"INSERT INTO orders (
  order_id,
  c_times,
  uid,
  channel_id,
  goods_id,
  goods_num,
  currency
)
VALUES
  ('", OrderId/binary, "', ", Now/binary, ", ", Uid/binary, ", '", ChannelId/binary, "', ", GoodsId/binary, ", ", GoodsNum/binary, ",  '", Currency/binary, "');">>]).


get_goods_id(OrderId) ->
    case ?rpc_db_call(db_mysql, ea, [<<"SELECT goods_id FROM orders WHERE order_id = '", OrderId/binary, "'  AND  (state = '0' or state='1');">>]) of
        [[GoodsId]] ->
            GoodsId;
        _ ->
            []
    end.


set_orders(OrderId, IsSandbox) ->
    Now = integer_to_binary(erl_time:now()),
    NewIsSandBox =
        if
            IsSandbox =:= ?TRUE -> <<"1">>;
            true ->
                Uin = ?get(?uin),
                case ?rpc_db_call(db_mysql, ea, [<<"select uin from white_list where uin = ", (integer_to_binary(Uin))/binary, ";">>]) of
                    [[Uin]] -> <<"1">>;
                    _ -> <<"0">>
                end
        end,
    ?rpc_db_call(db_mysql, ea, [<<"UPDATE orders SET status = 2, e_times=", Now/binary, ", is_sandbox = ", NewIsSandBox/binary, " WHERE order_id = '", OrderId/binary, "';">>]).


set_orders(OrderId) ->
    ?rpc_db_call(db_mysql, ea, [<<"UPDATE orders SET state = 1 WHERE order_id = '", OrderId/binary, "';">>]).