%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 微信登陆支付
%%%
%%% Created : 27. 七月 2016 下午1:33
%%%-------------------------------------------------------------------
-module(sdk_weixin_sign).

-include("erl_pub.hrl").

-export([
    jsapi_sign/0
]).


-define(APP_ID, "111").
-define(APP_SECRET, "222").
-define(CALL_URL, <<"http://fk.dz.01cs.cc/">>).


access_token() ->
    Url = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=" ++ ?APP_ID ++ "&secret=" ++ ?APP_SECRET,
    case erl_httpc:get(Url, []) of
        {ok, Json} ->
            ?INFO("111:~p~n", [Json]),
            {Kvs} = jiffy:decode(Json),
            case lists:keyfind(<<"access_token">>, 1, Kvs) of
                {<<"access_token">>, AccessToken} ->
                    binary_to_list(AccessToken);
                _ ->
                    ?ERROR("weixin access_token json:~p~n", [Json]),
                    <<>>
            end;
        Err ->
            ?ERROR("weixin access_token err:~p~n", [Err])
    end.


jsapi_ticket() ->
    AccessToken = access_token(),
    Url = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=" ++ AccessToken ++ "&type=jsapi",
    case erl_httpc:get(Url, []) of
        {ok, Json} ->
            ?INFO("222:~p~n", [Json]),
            {Kvs} = jiffy:decode(Json),
            case lists:keyfind(<<"ticket">>, 1, Kvs) of
                {<<"ticket">>, Ticket} ->
                    Sign = erl_hash:sha1_bin(<<"jsapi_ticket=", Ticket/binary, "&noncestr=123&timestamp=456&url=", (?CALL_URL)/binary>>),
                    cache_global:insert(sdk_weixin_jsapi_sign, {Sign, erl_time:now() + 7200}),
                    Sign;
                _ ->
                    ?ERROR("weixin getticket json:~p~n", [Json]),
                    <<>>
            end;
        Err ->
            ?ERROR("weixin getticket err:~p~n", [Err])
    end.


jsapi_sign() ->
    case cache_global:lookup(sdk_weixin_jsapi_sign) of
        [] -> jsapi_ticket();
        {Sign, TimeOut} ->
            Now = erl_time:now(),
            if
                Now >= TimeOut -> jsapi_ticket();
                true ->
                    Sign
            end
    end.
    
    
    