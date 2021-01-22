%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 七月 2016 下午5:19
%%%-------------------------------------------------------------------
-module(erl_log_srv).

-include("erl_pub.hrl").
-behaviour(gen_server).

-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


start_link(LogName) ->
    gen_server:start_link({local, LogName}, ?MODULE, LogName, []).


init(LogName) ->
    process_flag(trap_exit, true),
    
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {ok, #{tab_name => LogName, logs => [], count => 0}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(stop, State) ->
    {stop, normal, State};


handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, ?timeout_mi_5}, State = #{tab_name := TabName, logs := Logs}) ->
    save_data(TabName, Logs),
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {noreply, State#{logs => [], count => 0}};


handle_info(Msg, State = #{count := Count, tab_name := TabName, logs := Logs}) when is_binary(Msg) orelse is_tuple(Msg) orelse is_list(Msg) ->
    NewState =
        if
            Count + 1 =:= 1000 ->
                save_data(TabName, Logs),
                State#{logs => [Msg], count => 1};
            true ->
                State#{logs => [Msg | Logs], count => Count + 1}
        end,
    {noreply, NewState}.


terminate(_Reason, #{tab_name := TabName, logs := Logs}) ->
    save_data(TabName, Logs).


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


save_data(_TabName, []) -> ok;
save_data(TabName, Data) -> log_pub:save_data(TabName, Data).



