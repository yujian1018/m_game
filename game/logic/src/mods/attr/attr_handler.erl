%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 玩家属性
%%%
%%% Created : 22. 七月 2016 下午5:07
%%%-------------------------------------------------------------------
-module(attr_handler).

-include("player_behaviour.hrl").
-include("logic_pub.hrl").
-include("../../db/load_attr.hrl").

-export([
    send_to_client_key/0,
    offlien_event/0
]).

load_data(Uid) ->
    load_attr:load_data(Uid).


online(_Uid) -> ok.


online_send_data(Uid) ->
    [RefreshTimes, GmtOffset] = load_attr:get_v(Uid, [?REFRESH_TIMES, ?GMT_OFFSET]),
    ConfigTimes = global_cron:now_refresh_times({?EVENT_ZERO_REFRESH, ?EVENT_START}),
    case erl_time:is_yesterday(RefreshTimes, GmtOffset, ConfigTimes) of
        false -> ok;
        RefreshTimes1 ->
            load_attr:set_v(Uid, [[?REFRESH_TIMES, "=", RefreshTimes1]]),
            player_behaviour:event_zero_refresh(Uid)
    end,
    
    [Nick, Sex, Gold, Icon] =
        load_attr:get_v(Uid, [send_to_client_key()]),
    
    attr_proto:online_send(
        [
            [[?UID, Uid], [?NICK, Nick], [?SEX, Sex], [?GOLD, Gold], [?ICON, Icon]]
        ]).


save_data(Uid) ->
    load_attr:save_data(Uid).


terminate(Uid) ->
    load_attr:del_data(Uid).


handler_call(Uid, ?event_zero_refresh) ->
    load_log_online:day_refresh(Uid),
    load_attr:reset_v(Uid),
    config_prize:card_daily_prize(Uid),
    config_prize:vip_daily_prize(Uid);

handler_call(Uid, ?EVENT_LVUP_VIP) ->
    config_prize:vip_lvup(Uid);

handler_call(_Uid, get_channel_id) ->
    erlang:get(?channel_id);

handler_call(_Uid, _Msg) -> ok.


handler_msg(Uid, _FromPid, _FromModule, {?event_zero_refresh}) ->
    load_attr:set_v(Uid, [[?REFRESH_TIMES, "=", erl_time:now() + 5]]),
    player_behaviour:event_zero_refresh(Uid);

handler_msg(_Uid, _FromPid, _FromModule, _Msg) ->
    ?INFO("badmatch handler_msg: uid:~p...from_pid:~p...from_module:~p...msg:~p~n", [_Uid, _FromPid, _FromModule, _Msg]).


send_to_client_key() ->
    [?NICK, ?SEX, ?GOLD, ?ICON].


offlien_event() ->
    ok.