%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 14. 一月 2017 下午2:04
%%%-------------------------------------------------------------------
-module(log_srv_hour).

-include("gm_pub.hrl").

-behaviour(gen_server).


-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

-export([start/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    Now = erl_time:now(),
    DiffTime = 3600 - (Now rem 3600),
    erlang:start_timer(DiffTime * 1000, self(), save_data),
    {ok, #state{}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, save_data}, State) ->
    start(),
    Now = erl_time:now(),
    DiffTime = 3600 - (Now rem 3600),
    erlang:start_timer(DiffTime * 1000, self(), save_data),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

start() ->
    ETime = erl_time:now(),
    STime = erl_time:zero_times(),
    if
        (ETime - STime) < 3600 -> ok;
        true ->
            STimeBin = integer_to_binary(STime),
            ETimeBin = integer_to_binary(ETime),
            
            ChannelIds = [integer_to_binary(ChannelId) || [ChannelId, _Des] <- load_account:get_channel(-1)],
            stt_report_data_center_d:report(STimeBin, ETimeBin, ChannelIds)
    end.