%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc redis 操作
%%%
%%% Created : 14. 九月 2016 下午3:56
%%%-------------------------------------------------------------------
-module(redis_token).

-include("db_pub.hrl").

-define(TAB_TOKEN(Token), <<"token:", Token/binary>>).  %token缓存表，token有效期7天
-define(uin, <<"uin">>).
-define(channel_id, <<"channel_id">>).
-define(role_ban, <<"role_ban">>).%是否封号

-export([
    exit/2,
    set/3,
    reset/4,
    set_role_ban/2
]).

exit(Token, Uin) ->
    Key = ?TAB_TOKEN(Token),
    case ?rpc_db_call(db_redis, q, [[<<"HMGET">>, Key, ?uin, ?channel_id, ?role_ban]]) of
        {ok, [Uin, Channel, RoleBan]} ->
            Now = erl_time:now(),
            if
                RoleBan == ?undefined -> ok;
                true ->
                    RoleBanInt = binary_to_integer(RoleBan),
                    if
                        RoleBanInt >= Now -> ?return_err(?ERR_CLOSURE);
                        true -> ok
                    end
            end,
            Channel;
        _Other ->
            ?return_err(?ERR_LOGIN_TOKNE_OUTDATE)
    end.


set(Uin, Token, Channel) ->
    Key = ?TAB_TOKEN(Token),
    ?rpc_db_call(db_redis, qp, [[
        [<<"HMSET">>, Key, ?uin, Uin, ?channel_id, Channel],
        [<<"EXPIRE">>, Key, round(?TIMEOUT_D_7 / 1000)]
    ]]).


reset(OldToken, Uin, Token, Channel) ->
    Key1 = ?TAB_TOKEN(OldToken),
    Key2 = ?TAB_TOKEN(Token),
    ?rpc_db_call(db_redis, qp, [[
        [<<"DEL">>, Key1],
        [<<"HMSET">>, Key2, ?uin, Uin, ?channel_id, Channel],
        [<<"EXPIRE">>, Key2, round(?TIMEOUT_D_7 / 1000)]
    ]]).


set_role_ban(Token, BanTimes) ->
    Key = <<"token:", Token/binary>>,
    ?rpc_db_call(db_redis, q, [[<<"HMSET">>, Key, <<"role_ban">>, BanTimes]]).