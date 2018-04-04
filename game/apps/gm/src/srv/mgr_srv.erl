%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 14. 九月 2016 下午2:51
%%%-------------------------------------------------------------------
-module(mgr_srv).

-behaviour(gen_server).

-include("gm_pub.hrl").

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-export([get_lists/0]).

-record(state, {data = []}).


get_lists() ->
    gen_server:call(?MODULE, get_lists).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    Data = get_obj_servers(),
    erlang:start_timer(?TIMEOUT_MI_1, self(), get_lists),
    {ok, #state{data = Data}}.


handle_call(get_lists, _From, State) ->
    {reply, State#state.data, State};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.


handle_cast(_Request, State) ->
    {noreply, State}.


handle_info({timeout, _TimerRef, get_lists}, State) ->
    Data = get_obj_servers(),
    erlang:start_timer(?TIMEOUT_MI_1, self(), get_lists),
    {noreply, State#state{data = Data}};

handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, _State) ->
    ok.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


get_obj_servers() ->
    case global_rpc:rpc_mgr_server(?gm, mgr_nodes, all_addrs, []) of
        {badrpc, nodedown} ->
            {[], 0};
        {Obj, Size} ->
            {Obj, Size};
        _ -> {[], 0}
    end.