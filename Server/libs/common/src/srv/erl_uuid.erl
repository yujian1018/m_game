%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 13. 七月 2018 上午10:29
%%%-------------------------------------------------------------------
-module(erl_uuid).

-include("erl_pub.hrl").

-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
    uuid/0
]).

-define(now_micro, now_micro).
-define(inc_int, inc_int).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    {ok, AreaId} = application:get_env(?common, area_id),
    {ok, SId} = application:get_env(?common, s_id),
    ?INFO("area_id:~p...s_id:~p~n", [AreaId, SId]),
    ?start_timer(1, timeout_m_1),
    {ok, #{?now_micro => erl_time:m_now(), ?inc_int => 0}}.

%% @doc area_id = 32 s_id = 32 inc = 4096 now_micro = 2199023255552
handle_call(uuid, _From, #{?now_micro := NowMicro, ?inc_int := Inc}) ->
    {ok, AreaId} = application:get_env(?common, area_id),
    {ok, SId} = application:get_env(?common, s_id),
    {RetNowMicro, RetInc} =
        case erl_time:m_now() of
            NowMicro ->
                if
                    Inc >= 4096 ->
                        timer:sleep(1),
                        {erl_time:m_now(), 0};
                    true ->
                        {NowMicro, Inc}
                end;
            NewNowMicro ->
                {NewNowMicro, 0}
        end,
    RetUUID = RetNowMicro bsl 23 + AreaId bsl 18 + SId bsl 12 + RetInc + 1,
    {reply, RetUUID, #{?now_micro => RetNowMicro, ?inc_int => RetInc + 1}};

handle_call(_Request, _From, State) -> {reply, ok, State}.


handle_cast(_Request, State) -> {noreply, State}.


handle_info(_Info, State) -> {noreply, State}.


terminate(_Reason, _State) -> ok.


code_change(_OldVsn, State, _Extra) -> {ok, State}.


uuid() ->
    gen_server:call(?MODULE, uuid).