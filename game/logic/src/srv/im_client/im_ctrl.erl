%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 29. 六月 2017 下午3:42
%%%-------------------------------------------------------------------
-module(im_ctrl).

-include("logic_pub.hrl").

-export([
    create_user/1,
    create_chat/0, create_chat/1, create_chat/2,
    logout_chat/1,
    add/2,
    kick/2
]).

-define(APP_ID, <<"111">>).
-define(APP_SECRECT, <<"222">>).

-define(URL, <<"http://test.dz.01cs.cc">>).

sign() ->
    list_to_binary(erl_hash:md5(<<(?APP_ID)/binary, ".", (?APP_SECRECT)/binary>>)).

create_user(Uid) ->
    Sign = sign(),
    Url = binary_to_list(<<(?URL)/binary, "/user/create?app_id=", (?APP_ID)/binary, "&i_id=", Uid/binary, "&sign=", Sign/binary>>),
    erl_httpc:get(Url, []).


create_chat() ->
    Sign = sign(),
    Url = binary_to_list(<<(?URL)/binary, "/chat/create?app_id=", (?APP_ID)/binary, "&sign=", Sign/binary>>),
    erl_httpc:get(Url, []).

create_chat(Tid) ->
    Sign = sign(),
    Url = binary_to_list(<<(?URL)/binary, "/chat/create?app_id=", (?APP_ID)/binary, "&tid=", Tid/binary, "&sign=", Sign/binary>>),
    erl_httpc:get(Url, []).

create_chat(Tid, Uid) ->
    Sign = sign(),
    Url = binary_to_list(<<(?URL)/binary, "/chat/create?app_id=", (?APP_ID)/binary, "&tid=", Tid/binary, "&member=", Uid/binary, "&sign=", Sign/binary>>),
    erl_httpc:get(Url, []).

logout_chat(Tid) ->
    Sign = sign(),
    Url = binary_to_list(<<(?URL)/binary, "/chat/logout?app_id=", (?APP_ID)/binary, "&tid=", Tid/binary, "&sign=", Sign/binary>>),
    erl_httpc:get(Url, []).


add(Tid, Uid) ->
    Sign = sign(),
    Url = binary_to_list(<<(?URL)/binary, "/chat/add?app_id=", (?APP_ID)/binary, "&tid=", Tid/binary, "&i_id=", Uid/binary, "&sign=", Sign/binary>>),
    erl_httpc:get(Url, []).

kick(Tid, Uid) ->
    Sign = sign(),
    Url = binary_to_list(<<(?URL)/binary, "/chat/kick?app_id=", (?APP_ID)/binary, "&tid=", Tid/binary, "&i_id=", Uid/binary, "&sign=", Sign/binary>>),
    erl_httpc:get(Url, []).