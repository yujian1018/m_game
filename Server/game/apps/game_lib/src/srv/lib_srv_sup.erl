%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 18. 四月 2017 下午3:15
%%%-------------------------------------------------------------------
-module(lib_srv_sup).

-include("game_pub.hrl").

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Arg), {I, {I, start_link, Arg}, permanent, 5000, Type, [I]}).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Child = [
        ?CHILD(cache_srv, worker, [?obj]),
        ?CHILD(log_sup, worker),
        ?CHILD(cron_srv, worker)
    ],
    {ok, {{one_for_one, 5, 10}, Child}}.