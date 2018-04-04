%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 11. 九月 2017 下午2:32
%%%-------------------------------------------------------------------
-module(redis_token).

-export([
    set_role_ban/2
]).

-include("gm_pub.hrl").

-define(TAB_TOKEN(Token), <<"token:", Token/binary>>).  %token缓存表，token有效期7天
-define(role_ban, <<"role_ban">>).%是否封号


set_role_ban(Token, 0) ->
    Key = <<"token:", Token/binary>>,
    eredis_pool:q(pool_redis_1, [<<"HDEL">>, Key, <<"role_ban">>]);
set_role_ban(Token, BanTimes) ->
    Key = <<"token:", Token/binary>>,
    eredis_pool:q(pool_redis_1, [<<"HMSET">>, Key, <<"role_ban">>, BanTimes]).
