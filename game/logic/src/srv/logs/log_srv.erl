%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 七月 2016 下午5:19
%%%-------------------------------------------------------------------
-module(log_srv).

-include("logic_pub.hrl").
-behaviour(gen_server).

-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(log, {type, tab_name, log = [], count = 0}).

start_link(LogName) ->
    case LogName of
        {log_pub, TabName} ->
            gen_server:start_link({local, TabName}, ?MODULE, LogName, []);
        _ ->
            gen_server:start_link({local, LogName}, ?MODULE, LogName, [])
    end.



init(LogName) ->
    process_flag(trap_exit, true),
    
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    case LogName of
        {log_pub, TabName} -> {ok, #log{tab_name = TabName, type = log_pub}};
        _ -> {ok, #log{tab_name = LogName}}
    end.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(stop, State) ->
    {stop, normal, State};


handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, ?timeout_mi_5}, State) ->
    save_data(State#log.type, State#log.tab_name, State#log.log),
    erlang:start_timer(?TIMEOUT_MI_5, self(), ?timeout_mi_5),
    {noreply, State#log{log = [], count = 0}};


handle_info({log_role_op, Uid, Op, CTimes}, State) ->
    NewState = if
                   State#log.count + 1 =:= 200 ->
                       save_data(State#log.type, State#log.tab_name, State#log.log),
                       State#log{log = [[Uid, Op, CTimes]], count = 1};
                   true ->
                       Log = case lists:keytake(Uid, 1, State#log.log) of
                                 false ->
                                     [[Uid, Op, CTimes] | State#log.log];
                                 {value, {Uid, OldOp, OldCTimes}, R} ->
                                     [[Uid, <<Op/binary, OldOp/binary>>, OldCTimes] | R]
                             end,
            
                       State#log{log = Log, count = State#log.count + 1}
               end,
    {noreply, NewState};

handle_info(Msg, State) when is_binary(Msg) orelse is_tuple(Msg) orelse is_list(Msg) ->
    NewState =
        if
            State#log.count + 1 =:= 1000 ->
                save_data(State#log.type, State#log.tab_name, State#log.log),
                State#log{log = [Msg], count = 1};
            true ->
                State#log{log = [Msg | State#log.log], count = State#log.count + 1}
        end,
    {noreply, NewState}.


terminate(_Reason, State) ->
    save_data(State#log.type, State#log.tab_name, State#log.log).


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


save_data(_, _TabName, []) -> ok;
save_data(log_pub, TabName, Data) -> log_pub:save_data(TabName, Data);
save_data(_, TabName, Data) -> log_ex:save_data(TabName, Data).



