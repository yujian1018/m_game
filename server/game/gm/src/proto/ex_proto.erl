%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 十一月 2017 上午10:41
%%%-------------------------------------------------------------------
-module(ex_proto).

-include("gm_pub.hrl").

-export([handle_client/3]).

handle_client(?ORDERS_RECHARGE, _State, {OrderId}) ->
    binary_can:illegal(OrderId),
    load_orders:recharge_order(OrderId);

handle_client(ProtoId, State, Qs) ->
    ?ERROR("not found this path:~p...uid:~p...qs:~p~n", [ProtoId, State, Qs]),
    <<"">>.
