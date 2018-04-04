%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 1.先沙箱模式充值充值
%%% 2.提交审核时,苹果审核app时，仍然在沙盒环境下测试
%%% 3.所以需要兼容，先生产环境验证，再沙盒模式验证
%%%
%%% Created : 27. 七月 2016 下午1:33
%%%-------------------------------------------------------------------
-module(sdk_ios).

-include("http_pub.hrl").

-export([login/1, pay_cb/2]).


-define(PAY_VERIFY, "https://buy.itunes.apple.com/verifyReceipt"). %正式服
-define(PAY_SANDBOX_VERIFY, "https://sandbox.itunes.apple.com/verifyReceipt").  %测试服


login(Arg) ->
    Account = list_can:exit_v_not_null(<<"open_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 open_id"/utf8>>),
    Token = list_can:exit_v_not_null(<<"token">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 token"/utf8>>),
    {Account, Token, {<<>>, <<"1">>, <<>>, <<>>}}.


pay_cb(Req, _GetArg) ->
    {ok, PostVals, _Req2} = cowboy_req:read_body(Req),
    {Arg} = jiffy:decode(PostVals),
    OrderId = list_can:exit_v_not_null(<<"goodsOrderId-data">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 goodsOrderId-data"/utf8>>),
    Price = list_can:exit_v_not_null(<<"goodsPrice-data">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 goodsPrice-data"/utf8>>),
    ReceiptData = list_can:get_arg(<<"receipt-data">>, Arg, <<>>),
    case erl_httpc:post(?PAY_VERIFY, [], "Content-Type: application/json", <<"{\"receipt-data\" : \"", ReceiptData/binary, "\"}">>) of
        {ok, Response} ->
            {Json} = jiffy:decode(Response),
            case proplists:get_value(<<"status">>, Json) of
                0 ->
                    GoodsOrderId =
                        case proplists:get_value(<<"receipt">>, Json) of
                            undefined -> <<>>;
                            {Receipt} ->
                                case proplists:get_value(<<"in_app">>, Receipt) of
                                    undefined -> <<>>;
                                    [{InApp} | _] ->
                                        case proplists:get_value(<<"transaction_id">>, InApp) of
                                            undefined -> <<>>;
                                            TranId -> TranId
                                        end
                                end
                        end,
                    {OrderId, <<"">>, GoodsOrderId, Price, 0, PostVals};
                21007 ->
                    ?WARN("SANDBOX:~p~n", [OrderId]),
                    case erl_httpc:post(?PAY_SANDBOX_VERIFY, [], "Content-Type: application/json", <<"{\"receipt-data\" : \"", ReceiptData/binary, "\"}">>) of
                        {ok, Response2} ->
                            {Json2} = jiffy:decode(Response2),
                            case proplists:get_value(<<"status">>, Json2) of
                                0 ->
                                    GoodsOrderId2 =
                                        case proplists:get_value(<<"receipt">>, Json2) of
                                            undefined -> <<>>;
                                            {Receipt2} ->
                                                case proplists:get_value(<<"in_app">>, Receipt2) of
                                                    undefined -> <<>>;
                                                    [{InApp2} | _] ->
                                                        case proplists:get_value(<<"transaction_id">>, InApp2) of
                                                            undefined -> <<>>;
                                                            TranId2 -> TranId2
                                                        end
                                                end
                                        end,
                                    {OrderId, <<"">>, GoodsOrderId2, Price, 1, PostVals};
                                _ ->
                                    ?ERROR("SANDBOX err:~p~n", [[OrderId, Response]]),
                                    ?return_err(?ERR_SDK_PAY_ERR, <<"iOS沙箱支付失败"/utf8>>)
                            end
                    end;
                _ ->
                    ?ERROR("pay err:~p~n", [[OrderId, Response]]),
                    ?return_err(?ERR_SDK_PAY_ERR, <<"iOS生产模式支付失败"/utf8>>)
            end;
        _ ->
            ?return_err(?ERR_SDK_PAY_FAIL, <<"iOS访问失败"/utf8>>)
    end.