%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 每分钟刷新缓存表
%%%
%%% Created : 25. 七月 2016 上午9:12
%%%-------------------------------------------------------------------
-module(cache_srv).

-behaviour(gen_server).

-include("erl_pub.hrl").

-export([
    refresh/0,
    reset_record/3, reset_record/4
]).


%% @doc 刷新数据
-callback refresh() -> list().


-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


refresh() ->
    gen_server:call(?MODULE, refresh).


refresh_time(AppName) ->
    lists:map(fun(Mod) -> Mod:refresh() end, erl_file:get_mods(AppName, cache_srv)).


start_link(AppName) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, AppName, []).


init(AppName) ->
    refresh_time(AppName),
    erlang:start_timer(?TIMEOUT_MI_1, self(), ?timeout_mi_1),
    {ok, #{app_name => AppName}}.


handle_call(refresh, _From, State = #{app_name := AppName}) ->
    catch refresh_time(AppName),
    {reply, ok, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({timeout, _TimerRef, ?timeout_mi_1}, State = #{app_name := AppName}) ->
    catch refresh_time(AppName),
    erlang:start_timer(?TIMEOUT_MI_1, self(), ?timeout_mi_1),
    {noreply, State};

handle_info({timeout, _TimerRef, {Mod, Fun, Arg}}, State) ->
    Mod:Fun(Arg),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


reset_record(TabName, AllRecords, NewAllIds) ->
    OldIds = case ets:lookup(TabName, all_ids) of
                 [] -> [];
                 [{_, _, IdList1}] -> IdList1
             end,
    DelIds = erl_list:diff(OldIds, NewAllIds, []),
    ets:insert(TabName, AllRecords),
    ets:insert(TabName, {TabName, all_ids, NewAllIds}),
    [ets:delete(TabName, DelId) || DelId <- DelIds],
    OldIds.

reset_record(TabName, AllRecords, NewAllIds, TabType) ->
    OldIds = case ets:lookup(TabName, all_ids) of
                 [] -> [];
                 [{_, _, IdList1}] -> IdList1
             end,
    DelIds = erl_list:diff(OldIds, NewAllIds, []),
    ets:insert(TabName, AllRecords),
    
    if
        TabType == bag ->
            ets:delete_object(TabName, {TabName, all_ids, OldIds}),
            [ets:delete_object(TabName, DelId) || DelId <- DelIds];
        true ->
            [ets:delete(TabName, DelId) || DelId <- DelIds]
    end,
    ets:insert(TabName, {TabName, all_ids, NewAllIds}),
    OldIds.