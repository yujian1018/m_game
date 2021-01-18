%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 五月 2017 下午4:43
%%%-------------------------------------------------------------------
-module(app_push).

-include("push_pub.hrl").

-export([
    httpc/2, httpc/3
]).

-define(APP_KEY, <<"a">>).

-define(MASTER_SECRET, <<"b">>).


send_alias(Uins, 1, Msg) ->
    <<"{\"platform\":\"all\",\"audience\":{\"alias\":", Uins/binary, "},\"notification\":{\"alert\":\"", Msg/binary, "\", \"ios\":{\"sound\" : \"sound.caf\"}},\"options\":{\"apns_production\": true}}">>;
send_alias(Uins, 2, Msg) ->
    <<"{\"platform\":\"all\",\"audience\":{\"alias\":", Uins/binary, "},\"notification\":{\"alert\":\"", Msg/binary, "\", \"ios\":{\"sound\" : \"sound.caf\"}},\"options\":{\"apns_production\": true}}">>.


httpc(Uins, Event, Msg) ->
    ?INFO("push 222:~p~n", [[Uins, Event]]),
    Args = send_alias(Uins, Event, Msg),
    Ret = httpc:request(post, {"https://api.jpush.cn/v3/push",
        [{"Authorization", "Basic " ++ binary_to_list(base64:encode(<<(?APP_KEY)/binary, ":", (?MASTER_SECRET)/binary>>))}],
        "Content-Type: application/json", Args}, [{timeout, 5000}], []),
    ?INFO("222:~p~n", [Ret]).

httpc(Uin, Msg) ->
    ?INFO("push 111:~p~n", [Uin]),
    Args = <<"{\"platform\":\"all\",\"audience\":{\"alias\":[\"",
        (integer_to_binary(Uin))/binary, "\"]},\"notification\":{\"alert\":\"",
        Msg/binary, "\", \"ios\":{\"sound\" : \"sound.caf\"}},\"options\":{\"apns_production\": true}}"/utf8>>,
    Ret = httpc:request(post, {"https://api.jpush.cn/v3/push",
        [{"Authorization", "Basic " ++ binary_to_list(base64:encode(<<(?APP_KEY)/binary, ":", (?MASTER_SECRET)/binary>>))}],
        "Content-Type: application/json", Args}, [{timeout, 5000}], []),
    ?INFO("111:~p~n", [Ret]).