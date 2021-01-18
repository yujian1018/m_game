%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 14. 一月 2017 下午2:04
%%%-------------------------------------------------------------------
-module(log_srv).

-include("gm_pub.hrl").

-behaviour(gen_server).


-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

-export([start/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    [[MaxTimes]] = erl_mysql:execute(pool_log_1, <<"SELECT MAX(times) FROM report_data_center">>),
    DiffTime = if
                   MaxTimes =:= undefined -> 0;
                   true ->
                       {{Y, Mon, D}, {H, M, S}} = calendar:local_time(),
                       case erl_time:sec_to_localtime(MaxTimes + 86400) of
                           {{Y, Mon, D}, _} ->
                               86400 - ((H * 3600 + M * 60 + S) - 6 * 3600);
                           _ ->
                               0
                       end
               end,
    erlang:start_timer(DiffTime * 1000, self(), save_data),
    {ok, #state{}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, save_data}, State) ->
    start(erl_time:zero_times()),
    DiffTime = erl_time:zero_times() + 86400 + 6 * 3600 - erl_time:now(),
    erlang:start_timer(DiffTime * 1000, self(), save_data),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


start(ZeroTime) ->
    STime = ZeroTime - 86400,
    ETime = ZeroTime,
    STimeBin = integer_to_binary(STime),
    ETimeBin = integer_to_binary(ETime),
    
    ChannelIds = [integer_to_binary(ChannelId) || [ChannelId, _Des] <- load_account:get_channel(-1)],
    
    stt_log_attr_lv:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_asset:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_asset_diamond:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_asset_gold:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_asset_item:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_data_center:report(STimeBin, ETimeBin, ChannelIds),
    
    stt_report_data_ltv:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_login_log:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_login_out:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_lv:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_retain:report(STimeBin, ETimeBin, ChannelIds),
    stt_report_retain_udid:report(STimeBin, ETimeBin, ChannelIds).