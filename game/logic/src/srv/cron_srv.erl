%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 活动管理器
%%%
%%% Created : 25. 八月 2016 下午5:15
%%%-------------------------------------------------------------------
-module(cron_srv).

-include("logic_pub.hrl").

-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

%%-map(state, #{id => {Deadline, TimeRef}}). 只存储倒计时的信息

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    State = all(#{}),
    erlang:start_timer(?TIMEOUT_MI_5, self(), get_global_cron_tabs),
    {ok, State}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, get_global_cron_tabs}, State) ->
    cache_sup:reload(global_cron, global_cron),
%%    cache_sup:reload(global_active, global_active),
    NewState = all(State),
    erlang:start_timer(?TIMEOUT_MI_5, self(), get_global_cron_tabs),
    {noreply, NewState};

handle_info({timeout, _TimerRef, {refresh, Id}}, State) ->
    NewState =
        case global_cron:diff_time(Id) of
            {once, _Time} ->
                case Id of
                    {ActiveId, ?EVENT_START} ->
                        global_active:set(ActiveId, 1);
                    {ActiveId, ?EVENT_STOP} ->
                        global_active:set(ActiveId, 0)
                end,
                maps:remove(Id, State);
            {cycle, DiffTime} ->
                cron_handler:event(Id),
                erlang:start_timer(DiffTime * 1000, self(), {refresh, Id}),
                maps:remove(Id, State)
        end,
    {noreply, NewState};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


all(Maps) ->
    All = global_cron:all(),
    FunFoldl =
        fun(Item, MapsAcc) ->
            case start_timer(Item, MapsAcc) of
                {error, 2} ->
                    MapsAcc;
                {error, 1} ->
                    MapsAcc;
                {Id, DiffTimes, TimeRef} ->
                    case maps:find(Id, MapsAcc) of
                        error ->
                            maps:put(Id, {DiffTimes, TimeRef}, MapsAcc);
                        {ok, {KeyDiffTimes, KeyTimeRef}} ->
                            if
                                DiffTimes >= KeyDiffTimes - 5 andalso DiffTimes =< KeyDiffTimes + 5 -> MapsAcc;
                                true ->
                                    erlang:cancel_timer(KeyTimeRef),
                                    maps:put(Id, {DiffTimes, TimeRef}, MapsAcc)
                            end
                    end
            end
        end,
    lists:foldl(FunFoldl, Maps, All).

start_timer({Id, ?EVENT_GLOBAL, W, Month, D, H, M}, Maps) ->
    case maps:find(Id, Maps) of
        error ->
            {_Type, DiffTime} = global_cron:diff_time(W, Month, D, H, M),
            Deadline = erl_time:now() + DiffTime,
            {Id, Deadline, erlang:start_timer(DiffTime * 1000, self(), {refresh, Id})};
        {ok, {DiffTimes, TimeRef}} ->
            {Id, DiffTimes, TimeRef}
    end;

start_timer({{ActiveId, EventType}, _EventType, W, Month, D, H, M}, _Maps) ->
    {_Type, DiffTimes} = global_cron:diff_time(W, Month, D, H, M),
    if
        EventType =:= ?EVENT_START ->
            {_, DiffETimes} = global_cron:diff_time({ActiveId, ?EVENT_STOP}),
            if
                (DiffTimes < 0) andalso (0 < DiffETimes) ->
                    global_active:set(ActiveId, ?EVENT_START),
                    {error, 2};
                (0 < DiffTimes) andalso (DiffTimes < DiffETimes) ->
                    Deadline = erl_time:now() + DiffTimes,
                    {{ActiveId, EventType}, Deadline, erlang:start_timer(DiffTimes * 1000, self(), {refresh, {ActiveId, EventType}})};
                true ->
                    global_active:set(ActiveId, ?EVENT_STOP),
                    {error, 1}
            end;
        true ->
            if
                DiffTimes > 0 ->
                    Deadline = erl_time:now() + DiffTimes,
                    {{ActiveId, EventType}, Deadline, erlang:start_timer(DiffTimes * 1000, self(), {refresh, {ActiveId, EventType}})};
                true -> {error, 1}
            end
    end.

