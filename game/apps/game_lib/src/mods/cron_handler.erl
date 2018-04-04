%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 倒计时事件
%%%
%%% Created : 22. 七月 2016 下午5:07
%%%-------------------------------------------------------------------
-module(cron_handler).

-include("obj_pub.hrl").

-export([event/1]).


event(CronId) ->
    case CronId of
        {?EVENT_ZERO_REFRESH, ?EVENT_START} -> player_mgr:abcast(attr_handler, {?event_zero_refresh});
        _ -> ok
    end.