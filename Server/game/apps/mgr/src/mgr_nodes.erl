%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 五月 2017 下午8:17
%%%-------------------------------------------------------------------
-module(mgr_nodes).

-include("mgr_pub.hrl").

-behaviour(gen_server).

-export([start_link/0, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


init([]) ->
    tick(),
    erlang:start_timer(?TIMEOUT_S_10, self(), ?timeout_s_10),
    {ok, #{}}.


handle_call(_Request, _From, State) -> {reply, ok, State}.
handle_cast(_Request, State) -> {noreply, State}.


handle_info({tick, Node, Args}, State) ->
    cache_server_version:node_set(Node, Args),
    {noreply, State};

handle_info({nodedown, Node}, State) ->
    ?PRINT("node_down:~p~n", [Node]),
    cache_server_version:node_del(Node),
    {noreply, State};

handle_info({timeout, _TimerRef, ?timeout_s_10}, State) ->
    tick(),
    erlang:start_timer(?TIMEOUT_S_10, self(), ?timeout_s_10),
    {noreply, State};

handle_info(_Info, State) -> {noreply, State}.


terminate(_Reason, _State) -> ok.
code_change(_OldVsn, State, _Extra) -> {ok, State}.


tick() ->
    case ets:lookup(?ETS_TAB_NODE, all_ids) of
        [] -> [];
        [{_, _, Nodes}] ->
            Fun =
                fun(Node) ->
                    case net_adm:ping(Node) of
                        pong ->
                            ok;
                        pang ->
                            cache_server_version:node_del(Node),
                            ?ERROR("node:~p closeed~n", [Node])
                    end
                end,
            lists:map(Fun, Nodes)
    end.