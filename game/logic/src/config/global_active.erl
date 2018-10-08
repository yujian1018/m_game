%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 27. 七月 2016 下午7:14
%%%-------------------------------------------------------------------
-module(global_active).

-include_lib("cache/include/cache_mate.hrl").
-include("logic_pub.hrl").

-export([
    exit/1, get_active/1,
    set/2,
    all_date_type/1, all_progress_type/1, all_prize_type/1
]).

-export([
]).

-define(tab_name, global_active).

-record(global_active, {
    id,
    time_type,
    progress_type,
    prize_type,
    s_times,
    e_times,
    op_state
}).


load_cache() ->
    [
        #cache_mate{
            name = ?tab_name,
            fields = record_info(fields, ?tab_name),
            group = [#global_active.time_type, #global_active.prize_type, #global_active.progress_type],
            priority = 10,
            rewrite = fun rewrite/1
        }
    ].


rewrite(Item = #global_active{id = Id, time_type = TimeType}) ->
    if
        TimeType =:= ?ACTIVE_DATE_DEADLINE ->
            {once, DiffSTimes} = global_cron:diff_time({Id, ?EVENT_START}),
            {once, DiffETimes} = global_cron:diff_time({Id, ?EVENT_STOP}),
            Now = erl_time:now(),
            STimes = Now + DiffSTimes,
            ETimes = Now + DiffETimes,
            if
                Now =< ETimes andalso STimes < ETimes ->
                    Item#global_active{id = Id, s_times = STimes, e_times = ETimes, op_state = 1};
                true -> Item#global_active{id = Id, s_times = STimes, e_times = ETimes, op_state = 0}
            end;
        true ->
            Item#global_active{id = Id}
    end.


set(ActiveId, OpState) ->
    case ets:lookup(?tab_name, ActiveId) of
        [] -> false;
        [Record] ->
            if
                Record#global_active.time_type =:= ?ACTIVE_DATE_DEADLINE ->
                    Now = erl_time:now(),
                    if
                    %% @doc 中途修改时间
                        OpState =:= ?EVENT_STOP andalso (Now < Record#global_active.e_times - 10) ->
                            ok;
                        OpState =:= ?EVENT_STOP andalso Now >= Record#global_active.e_times - 10 ->
                            ets:insert(?tab_name, Record#global_active{op_state = ?EVENT_STOP});
                        true ->
                            ets:insert(?tab_name, Record#global_active{op_state = OpState})
                    end;
                true ->
                    ok
            end
    end.


exit(ActiveId) ->
    case ets:lookup(?tab_name, ActiveId) of
        [] -> ?false;
        [Record] ->
            if
                Record#global_active.op_state =:= ?TRUE -> ?true;
                true -> ?false
            end
    end.


all_date_type(Type) ->
    case ets:lookup(?tab_name, {'group', #?tab_name.time_type, Type}) of
        [] -> [];
        [{_, _, Ids}] -> Ids
    end.


all_progress_type(Type) ->
    case ets:lookup(?tab_name, {'group', #?tab_name.progress_type, Type}) of
        [] -> [];
        [{_, _, Ids}] -> Ids
    end.


all_prize_type(Type) ->
    case ets:lookup(?tab_name, {'group', #?tab_name.prize_type, Type}) of
        [] -> [];
        [{_, _, Ids}] -> Ids
    end.


get_active(ActiveId) ->
    case ets:lookup(?tab_name, ActiveId) of
        [] -> [];
        [Record] ->
            {
                Record#global_active.time_type,
                Record#global_active.progress_type,
                Record#global_active.prize_type
            }
    end.