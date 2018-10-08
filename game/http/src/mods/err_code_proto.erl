%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 四月 2017 上午11:16
%%%-------------------------------------------------------------------
-module(err_code_proto).

-include_lib("http_pub.hrl").

-define(CACHE_CONFIG_KEY_1, 1). %服务器维护公告id

-export([
    to_msg/1
]).


to_msg(?ERR_MAINTAIN_SYSTEM) ->
    NewV = case cache_config:get_v(?CACHE_CONFIG_KEY_1) of
               <<>> -> <<"游戏服务器维护中"/utf8>>;
               V -> V
           end,
    <<"{\"code\":2, \"msg\":\"", NewV/binary, "\"}"/utf8>>;

to_msg({ErrCode, Msg}) ->
    <<"{\"code\":", (integer_to_binary(ErrCode))/binary, ", \"msg\":\"", Msg/binary, "\"}"/utf8>>;

to_msg(ErrCode) -> <<"{\"code\":", (integer_to_binary(ErrCode))/binary, "}"/utf8>>.

