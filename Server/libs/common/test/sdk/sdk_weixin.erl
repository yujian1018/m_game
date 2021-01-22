%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 微信登陆支付
%%%
%%% Created : 27. 七月 2016 下午1:33
%%%-------------------------------------------------------------------
-module(sdk_weixin).

-export([login/1, pay_cb/2]).

-export([arg_create/7, to_html/1, to_json/1]).

-include("erl_pub.hrl").


%% @doc 统一下单
-define(WEIXIN_PAY_URL, <<"https://api.mch.weixin.qq.com/pay/unifiedorder"/utf8>>).

%% @doc 查询订单
-define(WEIXIN_QUERY_URL, <<"https://api.mch.weixin.qq.com/pay/orderquery"/utf8>>).

-define(NOTIFY_URL, <<"http://﻿116.62.12.145:9998/webWeixin/"/utf8>>).

-ifdef(prod).

-define(APP_ID, "111").
-define(APP_SECRET, "222").

-define(MCH_ID, "333").
-define(KEY, <<"444"/utf8>>).

-else.

-define(APP_ID, "111").
-define(APP_SECRET, "222").
-define(MCH_ID, "333").
-define(KEY, <<"444"/utf8>>).

-endif.


login(Arg) ->
    Code = list_can:exit_v_not_null(<<"code">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 code"/utf8>>),
    case erl_httpc:post("https://api.weixin.qq.com/sns/oauth2/access_token", [], "application/x-www-form-urlencoded",
        iolist_to_binary(["appid=", ?APP_ID, "&secret=", ?APP_SECRET, "&code=", Code, "&grant_type=authorization_code"])) of
        {ok, Body1} ->
            {ok, {obj, R1}, []} = rfc4627:decode(Body1),
            Token = list_can:get_arg("access_token", R1),
            OpenId = list_can:get_arg("openid", R1),
            Unionid = list_can:get_arg("unionid", R1),
            case erl_httpc:post("https://api.weixin.qq.com/sns/userinfo", [], "application/x-www-form-urlencoded",
                iolist_to_binary(["access_token=", Token, "&openid=", OpenId, "&lang=zh_CN"])) of
                {ok, Body2} ->
                    {R2} = jiffy:encode(Body2),
                    Name = list_can:get_arg("nickname", R2, <<>>),
                    Sex = case proplists:get_value("sex", R2) of
                              1 -> <<"1">>;
                              _ -> <<"0">>
                          end,
                    Province = proplists:get_value("province", R2, <<>>),
                    City = proplists:get_value("city", R2, <<>>),
                    HeadImg = proplists:get_value("headimgurl", R2, <<>>),
                    HeadImg1 = binary:part(HeadImg, 0, byte_size(HeadImg) - 2),
                    {Unionid, Token, {Name, Sex, <<HeadImg1/binary, "/132">>, <<Province/binary, " ", City/binary>>}};
                _Other ->
                    ?WARN("userinfo:~p~n", [_Other]),
                    ?return_err(?ERR_SDK_ERR, <<"sdk登陆，平台验证失败"/utf8>>)
            end;
        _Other ->
            ?WARN("access_token error:~p~n", [_Other]),
            ?return_err(?ERR_SDK_FAIL, <<"sdk登陆，平台验证网络超时"/utf8>>)
    end.



pay_cb(_Req, _GetArg) ->
    case load_orders:get_order() of
        [] -> <<"{success:N}">>;
        OrderIds ->
            Fun =
                fun([OrderId, Uid]) ->
                    Arg = arg_query(OrderId),
                    case erl_httpc:post(?WEIXIN_QUERY_URL, [], [], Arg) of
                        {ok, BodyBin} ->
                            {<<"xml">>, _, Xml} = mochiweb_html:parse(BodyBin),
                            Ret1 = lists:keyfind(<<"return_code">>, 1, Xml),
                            Ret2 = lists:keyfind(<<"result_code">>, 1, Xml),
                            Ret3 = lists:keyfind(<<"trade_state">>, 1, Xml),
                            case {Ret1, Ret2, Ret3} of
                                {{_, [], [<<"SUCCESS">>]}, {_, [], [<<"SUCCESS">>]}, {_, [], [<<"SUCCESS">>]}} ->
                                    case node_web:send_to_game(Uid, OrderId, 0) of
                                        ok -> <<"SUCCESS">>;
                                        _ -> ?return_err(?ERR_ARG_ERROR)
                                    end;
                                _ ->
                                    load_orders:set_state(OrderId, <<"1">>)
                            end;
                        _ ->
                            ok
                    end
                end,
            lists:map(Fun, OrderIds),
            <<"{success:Y}">>
    end.



arg_create(ProName, GameId, Uid, OrderId, TotleFee, UserIp, WxOpenId) ->
    List = [
        {<<"appid">>, list_to_binary(?APP_ID)},
        {<<"mch_id">>, list_to_binary(?MCH_ID)},
        {<<"nonce_str">>, list_to_binary(erl_string:uuid())},
        {<<"body">>, ProName},
        {<<"attach">>, <<GameId/binary, ",", Uid/binary, ",", OrderId/binary>>},
        {<<"out_trade_no">>, OrderId},
        {<<"total_fee">>, TotleFee},
        {<<"spbill_create_ip">>, UserIp},
        {<<"notify_url">>, ?NOTIFY_URL},
        {<<"trade_type">>, <<"JSAPI">>},
        {<<"openid">>, WxOpenId}
    ],
    
    Sign = to_sign(List, ?KEY),
    to_xml(List ++ [{<<"sign">>, Sign}]).

arg_query(OderId) ->
    List = [
        {<<"appid">>, list_to_binary(?APP_ID)},
        {<<"mch_id">>, list_to_binary(?MCH_ID)},
        {<<"nonce_str">>, list_to_binary(erl_string:uuid())},
        {<<"out_trade_no">>, OderId}
    ],
    Sign = to_sign(List, ?KEY),
    to_xml(List ++ [{<<"sign">>, Sign}]).

to_html(PrePayId) ->
    List = [
        {<<"appId">>, list_to_binary(?APP_ID)},
        {<<"timeStamp">>, integer_to_binary(erl_time:now())},
        {<<"nonceStr">>, list_to_binary(erl_string:uuid())},
        {<<"package">>, <<"prepay_id=", PrePayId/binary>>},
        {<<"signType">>, <<"MD5">>}
    ],
    Sign = to_sign(List, ?KEY),
    to_json(List ++ [{<<"paySign">>, Sign}]).


to_sign(List, Key) ->
    FunFoldl =
        fun({K, V}, AccBin) ->
            if
                AccBin =:= <<>> -> <<K/binary, "=", V/binary>>;
                true -> <<AccBin/binary, "&", K/binary, "=", V/binary>>
            end
        end,
    Bin = lists:foldl(FunFoldl, <<>>, lists:keysort(1, List) ++ [{<<"key">>, Key}]),
    list_to_binary(string:to_upper(erl_hash:md5(Bin))).


to_xml(List) ->
    FunFoldl =
        fun({K, V}, AccBin) ->
            <<AccBin/binary, "<", K/binary, ">", V/binary, "</", K/binary, ">">>
        end,
    Xml = lists:foldl(FunFoldl, <<>>, List),
    <<"<xml>", Xml/binary, "</xml>">>.


to_json(List) ->
    FunFoldl =
        fun({K, V}, AccBin) ->
            if
                AccBin =:= <<>> -> <<"\"", K/binary, "\":\"", V/binary, "\"">>;
                true ->
                    <<AccBin/binary, ",\n\"", K/binary, "\":\"", V/binary, "\"">>
            end
        end,
    Json = lists:foldl(FunFoldl, <<>>, List),
    <<"{\n", Json/binary, "}">>.

