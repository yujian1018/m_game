%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 19. 四月 2016 上午9:33
%%%-------------------------------------------------------------------
-module(pay_cb_proto).

-include("http_pub.hrl").

-export([handle_client/3]).

handle_client(Req, ?PAY_SDK, Arg) ->
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 channel_id"/utf8>>),
    RechargeId = list_can:exit_v_not_null(<<"recharge_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 recharge_id"/utf8>>),
    Mod = cache_channel_recharge:get_mod(binary_to_integer(ChannelId), binary_to_integer(RechargeId)),
    case Mod:pay_cb(Req, Arg) of
        {OrderId, OrderNum, OutOrder, Price, IsTextEnv, OutOrderInfo} ->
            case load_orders:set_order(OrderId, OrderNum, OutOrder, Price, RechargeId, OutOrderInfo) of
                [_, [[Uid]]] ->
                    case node_web:send_to_game(Uid, OrderId, IsTextEnv) of
                        ok -> 200;
                        _Other ->
                            ?ERROR("send_to_game error:~p~n", [{Uid, OrderId, _Other, OutOrderInfo}]),
                            ?return_err(?ERR_ARG_ERROR, <<"订单通知到服务器失败"/utf8>>)
                    end;
                _Other ->
                    ?ERROR("update order error:~p~n", [[{OrderId, OrderNum, OutOrder, Price}, _Other]]),
                    ?return_err(?ERR_ARG_ERROR, <<"订单已被使用"/utf8>>)
            end;
        Html ->
            Html
    end;

handle_client(_Req, ?PAY_FAIL, Arg) ->
    OrderId = list_can:exit_v_not_null(<<"order_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 order_id"/utf8>>),
    OrderState = list_can:get_arg(<<"order_id">>, Arg, <<"6">>),
    list_can:member(OrderState, [<<"4">>], ?ERR_ARG_ERROR),
    if
        OrderState =:= <<"4">> -> load_orders:set_state(OrderId, OrderState);
        OrderState =:= <<"5">> ->
            OrderErr = list_can:get_arg(<<"order_id">>, Arg, <<"">>),
            load_orders:set_order_err(OrderId, OrderState, OrderErr);
        true ->
            ok
    end;

handle_client(_Req, Cmd, Arg) ->
    ?DEBUG("handle_info no match ProtoId:~p...arg:~p~n", [Cmd, Arg]),
    ?return_err(?ERR_ARG_ERROR).

