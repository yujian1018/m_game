%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 更新时区做倒计时推送
%%%
%%% Created : 23. 九月 2017 下午3:57
%%%-------------------------------------------------------------------
-module(cron_srv).

-behaviour(gen_server).

-include("push_pub.hrl").

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


-define(ALL_CRON, [
    {{10003, 1}, 12 * 3600, -3600 * 2},
    {{10003, 2}, 14 * 3600, -3600 * 2}
]).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    all_cron(),
    {ok, #{}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, {cron_push_time, {ChannelId, EventId}}}, State) ->
    case lists:keyfind({ChannelId, EventId}, 1, ?ALL_CRON) of
        false -> ok;
        {{ChannelId, EventId}, GmtTimes, GMTOffset} ->
            Now = erl_time:now(),
            ZeroTime = erl_time:zero_times(),
            DiffTime = ZeroTime + 86400 + GmtTimes + GMTOffset - Now,
            erlang:start_timer(DiffTime * 1000, self(), {cron_push_time, {ChannelId, EventId}}),
            push_srv:push_data(EventId)
    end,
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


all_cron() ->
    Now = erl_time:now(),
    ZeroTime = erl_time:zero_times(),
    Fun =
        fun({{ChannelId, EventId}, GmtTimes, GMTOffset}) ->
            DiffTime =
                if
                    Now >= ZeroTime + GmtTimes + GMTOffset ->
                        ZeroTime + 86400 + GmtTimes + GMTOffset - Now;
                    true ->
                        ZeroTime + GmtTimes + GMTOffset - Now
                end,
            ?INFO("all_cron: id:~p...difftime:~p~n", [{ChannelId, EventId}, DiffTime]),
            erlang:start_timer(DiffTime * 1000, self(), {cron_push_time, {ChannelId, EventId}})
        end,
    lists:map(Fun, ?ALL_CRON).
