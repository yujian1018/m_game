%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 五月 2017 下午8:17
%%%-------------------------------------------------------------------
-module(node_connect).

-include("erl_pub.hrl").

-behaviour(gen_server).

-export([start_link/2, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


start_link(AppName, MgrNode) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [AppName, MgrNode], []).


init([AppName, MgrNode]) ->
    process_flag(trap_exit, true),
    case net_kernel:connect_node(MgrNode) of
        true ->
            {mgr_nodes, MgrNode} ! {tick, node(), 0};
        false -> ok
    end,
    erlang:start_timer(10000, self(), timeout_s_10),
    {ok, #{app_name => AppName, mgr_node => MgrNode}}.


handle_call(_Request, _From, State) -> {reply, ok, State}.
handle_cast(_Request, State) -> {noreply, State}.


handle_info({timeout, _TimerRef, timeout_s_10}, State = #{app_name:=AppName, mgr_node := MgrNode}) ->
    case net_kernel:connect_node(MgrNode) of
        true ->
            if
                AppName =:= obj ->
                    {mgr_nodes, MgrNode} ! {tick, node(), player_mgr:total_player()};
                true ->
                    {mgr_nodes, MgrNode} ! {tick, node(), 0}
            end;
        false ->
            ?WARN("mgr_node close wait 10s reconnect:~p~n", [MgrNode])
    end,
    erlang:start_timer(10000, self(), timeout_s_10),
    {noreply, State};


handle_info(_Info, State) ->
    {noreply, State}.


terminate(_Reason, #{mgr_node := MgrNode}) ->
    case net_kernel:connect_node(MgrNode) of
        true ->
            ?INFO("aaa:~p~n", [{nodedown, node()}]),
            {mgr_nodes, MgrNode} ! {nodedown, node()};
        false ->
            ok
    end.


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
