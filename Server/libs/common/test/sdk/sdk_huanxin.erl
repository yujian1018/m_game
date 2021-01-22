%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 22. 六月 2017 下午8:44
%%%-------------------------------------------------------------------
-module(sdk_huanxin).

-include("erl_pub.hrl").

-export([
    token/0,
    set_user/3, get_user/2, del_user/2, get_msg/2, send_msg/4, his_msg/2
]).

-define(APP_KEY, <<"111#happyjob">>).
-define(CLIENT_ID, <<"222">>).
-define(CLIENT_SECRET, <<"YXA6-333">>).

-define(URL, "http://a1.easemob.com").

token() ->
    Post = <<"{\"grant_type\":\"client_credentials\",\"client_id\":\"111\",\"client_secret\":\"YXA6-222\"}">>,
    {ok, Body} = erl_httpc:post(?URL ++ "token", [], [], Post),
    {List} = jiffy:decode(Body),
    {_, Token} = lists:keyfind(<<"access_token">>, 1, List),
    {_, ExpiresIn} = lists:keyfind(<<"expires_in">>, 1, List),
    {Token, ExpiresIn}.


set_user(Token, Account, Pwd) ->
    Post = <<" {\"username\":\"", Account/binary, "\",\"password\":\"", Pwd/binary, "\"}">>,
    Header = [{"Authorization", "Bearer " ++ binary_to_list(Token)}],
    {ok, _Body} = erl_httpc:post(?URL ++ "users", Header, "application/json", Post).

get_user(Token, Account) ->
    Header = [{"Authorization", "Bearer " ++ binary_to_list(Token)}],
    {ok, _Body} = erl_httpc:request(get, {?URL ++ "users/" ++ binary_to_list(Account), Header}, [{timeout, 5000}], []).

del_user(Token, Account) ->
    Header = [{"Authorization", "Bearer " ++ binary_to_list(Token)}],
    erl_httpc:request(delete, {?URL ++ "users/" ++ binary_to_list(Account), Header, "application/json", ""}, [{timeout, 5000}], []).

get_msg(Token, Account) ->
    Header = [{"Authorization", "Bearer " ++ binary_to_list(Token)}],
    {ok, _Body} = erl_httpc:get(?URL ++ "users/" ++ binary_to_list(Account) ++ "/offline_msg_count", Header).


send_msg(Token, From, To, Msg) ->
    Post = <<"{
    \"target_type\" : \"users\",
    \"target\" : [\"", To/binary, "\"],
    \"msg\" : {
        \"type\" : \"txt\",
        \"msg\" : \"", Msg/binary, "\"
        },
    \"from\" : \"", From/binary, "\"
    }">>,
    Header = [{"Authorization", "Bearer " ++ binary_to_list(Token)}],
    {ok, _Body} = erl_httpc:post(?URL ++ "users", Header, "application/json", Post).


his_msg(Token, Account) ->
    Post = <<" {\"username\":\"", Account/binary, "\",\"password\":\"", Account/binary, "\"}">>,
    Header = [{"Authorization", "Bearer " ++ binary_to_list(Token)}],
    {ok, _Body} = erl_httpc:post(?URL ++ "/chatmessages/users", Header, "application/json", Post).