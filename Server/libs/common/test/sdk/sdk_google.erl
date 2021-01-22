%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 微信登陆支付
%%%
%%% Created : 27. 七月 2016 下午1:33
%%%-------------------------------------------------------------------
-module(sdk_google).

-export([
    login/1,
    pay_cb/2,
    access_token/0
]).

-include("erl_pub.hrl").
-include_lib("public_key/include/public_key.hrl").


%% @doc 查询订单
-define(QUERY_URL(PackageName, ProductId, PurchaseToken, AccessToken),
    <<"https://www.googleapis.com/androidpublisher/v2/applications/", PackageName/binary,
        "/purchases/products/", ProductId/binary,
        "/tokens/", PurchaseToken/binary,
        "?access_token=", AccessToken/binary>>).


login(_Arg) ->
    ok.


pay_cb(Req, _GetArg) ->
    {ok, PostVals, _Req2} = cowboy_req:read_body(Req),
    Arg = cow_qs:parse_qs(PostVals),
    PackageName = list_can:exit_v(<<"packageName">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有packageName"/utf8>>),
    ProductId = list_can:exit_v(<<"productId">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有productId"/utf8>>),
    PurchaseToken = list_can:exit_v(<<"purchaseToken">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有purchaseToken"/utf8>>),
    GoodsOrderId = list_can:exit_v(<<"orderId">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有orderId"/utf8>>),
    OrderId = list_can:exit_v(<<"order_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有order_id"/utf8>>),
    Price = list_can:exit_v(<<"price">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有price"/utf8>>),
    AccessToken = access_token(),
    Uri = binary_to_list(?QUERY_URL(PackageName, ProductId, PurchaseToken, AccessToken)),
    case erl_httpc:get(Uri, []) of
        {ok, Response} ->
            {Json} = jiffy:decode(Response),
            case proplists:get_value("purchaseState", Json) of
                0 ->
                    {OrderId, <<"">>, GoodsOrderId, Price, 0, PostVals};
                _ ->
                    ?return_err(?ERR_SDK_PAY_ERR, <<"google支付失败"/utf8>>)
            end;
        _ ->
            ?return_err(?ERR_SDK_PAY_FAIL, <<"google访问失败"/utf8>>)
    end.



access_token() ->
    Rsa = <<"-----BEGIN PRIVATE KEY-----\111\n">>,
    AuthHeader = <<"{\"alg\":\"RS256\",\"typ\":\"JWT\"}">>,
    STime = erl_time:now(),
    Exp = STime + 3600,
    AuthClaimSet = <<"{\"iss\":\"123\",\"scope\":\"https://www.googleapis.com/auth/androidpublisher\",\"aud\":\"https://accounts.google.com/o/oauth2/token\",\"iat\":", (integer_to_binary(STime))/binary, ",\"exp\":", (integer_to_binary(Exp))/binary, "}">>,
    
    [Entry] = public_key:pem_decode(Rsa),
    PemKey = public_key:pem_entry_decode(Entry),
    RsaKey = public_key:der_decode('RSAPrivateKey', PemKey#'PrivateKeyInfo'.privateKey),
    
    Assertion = sign_token:jwt(AuthHeader, AuthClaimSet, RsaKey),
    GrantType = <<"urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer">>,
    case erl_httpc:post("https://accounts.google.com/o/oauth2/token",
        [], "application/x-www-form-urlencoded", <<"grant_type=", GrantType/binary, "&assertion=", Assertion/binary>>) of
        {ok, Body} ->
            {Tokens} = jiffy:decode(Body),
            case lists:keyfind("access_token", 1, Tokens) of
                {_, Token} ->
                    Token;
                _ ->
                    ?return_err(?ERR_SDK_SIGN_ERR, <<"google签名失败"/utf8>>)
            end;
        _Other ->
            ?return_err(?ERR_SDK_SIGN_ERR, <<"google签名失败"/utf8>>)
    end.