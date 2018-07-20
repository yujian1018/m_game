%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 17. 三月 2017 上午11:39
%%%-------------------------------------------------------------------
-module(global_rpc).

-include("gm_pub.hrl").

-export([
    rpc_mgr_server/4,
    rpc/5, rpc_cast/5
]).

rpc_mgr_server(AppName, M, F, A) ->
    case rpc(AppName, mgr_node, M, F, A) of
        {error, Err} ->
            ?ERROR("rpc error:~p~n", [Err]),
            error;
        Ret -> Ret
    end.


rpc(AppName, Env, M, F, A) ->
    case application:get_env(AppName, Env) of
        {badrpc, nodedown} ->
            {error, <<"nodedown">>};
        {ok, Node} -> rpc:call(Node, M, F, A);
        _Other ->
            {error, [<<"app:">>, AppName, <<" no key:">>, Env]}
    end.

rpc_cast(AppName, Env, M, F, A) ->
    case application:get_env(AppName, Env) of
        {badrpc, nodedown} ->
            {error, <<"nodedown">>};
        {ok, Node} -> rpc:cast(Node, M, F, A);
        _Other ->
            {error, [<<"app:">>, AppName, <<" no key:">>, Env]}
    end.