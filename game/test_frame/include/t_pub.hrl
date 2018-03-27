%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 17. 一月 2017 下午6:10
%%%-------------------------------------------------------------------

-include_lib("network/include/network_pub.hrl").
-include("../src/auto/proto/proto_all.hrl").      %协议宏


-define(HTTP_ADDR, begin {ok, HttpAddr} = application:get_env(test_frame, http_addr), HttpAddr end).
-define(VERSION, begin {ok, Version} = application:get_env(test_frame, version), Version end).
-define(CHANNEL_ID, begin {ok, ChannelId} = application:get_env(test_frame, channel_id), ChannelId end).
-define(SIGN(Date), erl_hash:md5_to_bin(<<"date=", (integer_to_binary(Date))/binary, "&key=", (?KEY)/binary>>)).

-define(KEY, <<"2b9eb9e4f0211582e4cf056af5f60289">>).

-define(login_state, login_state).  % 0:初始化 1:接收到随机数种子，可以正常通讯
-define(uin, uin).
-define(token, token).
-define(tick, tick).