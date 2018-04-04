%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 15. 十二月 2015 下午2:45
%%%-------------------------------------------------------------------
-module(lib_mgr_sup).

-behaviour(supervisor).
-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Child = [
%%        ?CHILD(rank_mgr, worker),
        ?CHILD(player_mgr, worker)
    ],
    {ok, {{one_for_one, 5, 10}, Child}}.
