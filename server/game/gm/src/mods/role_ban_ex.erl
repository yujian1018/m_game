%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 三月 2017 下午5:00
%%%-------------------------------------------------------------------
-module(role_ban_ex).

-include("gm_pub.hrl").

-export([
    insert/2,
    update/2,
    delete/2
]).


insert(_TabName, Args) ->
    Uin = list_can:exit_v_not_null(<<"uin">>, Args),
    ChannelId = binary_to_integer(list_can:exit_v_not_null(<<"channel_id">>, Args)),
    case erl_mysql:execute(pool_account_1, <<"select channel_id from account where uin = '", Uin/binary, "';">>) of
        [[ChannelId]] ->
            BanTimes = list_can:exit_v_not_null(<<"ban_times">>, Args),
            set_role_ban(Uin, integer_to_binary(erl_time:time2timer(BanTimes))),
            R2 = [{K, V} || {K, V} <- Args, V =/= <<>>],
            FunFoldl =
                fun({K, V}, Record) ->
                    {Index, NewV} = role_ban:to_index(K, V),
                    setelement(Index, Record, NewV)
                end,
            VO = lists:foldl(FunFoldl, role_ban:record(), R2),
            role_ban:insert(VO);
        _Other ->
            ?return_err(?ERR_CHANNEL_ID)
    end.


update(_TabName, Args) ->
    Uin = list_can:exit_v_not_null(<<"uin">>, Args),
    ChannelId = binary_to_integer(list_can:exit_v_not_null(<<"channel_id">>, Args)),
    case erl_mysql:execute(pool_account_1, <<"select channel_id from account where uin = '", Uin/binary, "';">>) of
        [[ChannelId]] ->
            BanTimes = list_can:exit_v_not_null(<<"ban_times">>, Args),
            set_role_ban(Uin, integer_to_binary(erl_time:time2timer(BanTimes))),
            R2 = [{K, V} || {K, V} <- Args, V =/= <<>>],
            FunFoldl =
                fun({K, V}, Record) ->
                    {Index, NewV} = role_ban:to_index(K, V),
                    setelement(Index, Record, NewV)
                end,
            VO = lists:foldl(FunFoldl, role_ban:record(), R2),
            role_ban:update(VO);
        _Other ->
            ?return_err(?ERR_CHANNEL_ID)
    end.


set_role_ban(Uin, BanTimes) ->
    case erl_mysql:execute(pool_account_1, <<"select token from account_info where uin = ", Uin/binary, ";">>) of
        [[Token]] ->
            redis_token:set_role_ban(Token, BanTimes),
            erl_mysql:execute(pool_account_1, <<"update account set ban_times = ", BanTimes/binary, " where uin = ", Uin/binary, ";">>),
            [[Uid]] = erl_mysql:execute(pool_dynamic_1, <<"select uid from player where uin = ", Uin/binary, ";">>),
            case redis_online:is_online(Uid) of
                {ok, Pid} -> catch gen_server:call(Pid, {stop, ?ERR_CLOSURE, BanTimes}, 10000);
                {ok, Node, PidBin} -> ?rpc_call(Node, Uid, PidBin, {stop, ?ERR_CLOSURE, BanTimes});
                false -> false
            end,
            <<"ok">>;
        _ ->
            ?return_err(?ERR_CHANNEL_ID)
    end.

delete(TabNameMod, Args) ->
    Uin = list_can:exit_v_not_null(<<"uin">>, Args),
    case erl_mysql:execute(pool_account_1, <<"select token from account_info where uin = ", Uin/binary, ";">>) of
        [[Token]] ->
            redis_token:set_role_ban(Token, 0),
            erl_mysql:execute(pool_account_1, <<"update account set ban_times = 0 where uin = ", Uin/binary, ";">>),
            [{K, V}] = Args,
            {_Index, NewV} = TabNameMod:to_index(K, V),
            TabNameMod:delete(NewV);
        _ ->
            ?return_err(?ERR_CHANNEL_ID)
    end.