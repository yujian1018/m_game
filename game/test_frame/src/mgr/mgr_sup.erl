%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 15. 十二月 2017 下午5:50
%%%-------------------------------------------------------------------
-module(mgr_sup).

-behaviour(supervisor).
-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Child = [
        ?CHILD(player_mgr, worker)
    ],
    {ok, {{one_for_one, 5, 10}, Child}}.

