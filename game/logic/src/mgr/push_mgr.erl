%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 九月 2017 下午8:29
%%%-------------------------------------------------------------------
-module(push_mgr).


-behaviour(gen_server).

-include("logic_pub.hrl").

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([
    add_timer/3
]).

add_timer(Uin, Uid, Diff) ->
    ?INFO("111:~p~n", [[Uin, Uid, Diff]]),
    ?MODULE ! {add_timer, Uin, Uid, Diff}.

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    {ok, #{}}.


handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({add_timer, Uin, Uid, Diff}, State) ->
    NewState =
        case maps:find(Uin, State) of
            error ->
                erlang:start_timer(Diff * 1000, self(), {timer_push, Uin, Uid}),
                maps:put(Uin, Uid, State);
            _ ->
                State
        end,
    {noreply, NewState};

handle_info({timeout, _TimerRef, {timer_push, Uin, Uid}}, State) ->
    NewState =
        case ?rpc_db_call(redis_online, is_online, [Uid]) of
            false ->
                ?INFO("timer_push timeout:~p~n", [[1, Uin]]),
                ?rpc_push_call(push_rpc, push_data, [1, Uin]),
                maps:remove(Uin, State);
            _ ->
                State
        end,
    {noreply, NewState};
handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

