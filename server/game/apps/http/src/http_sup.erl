-module(http_sup).

-behaviour(supervisor).

-include("http_pub.hrl").

-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Arg), {I, {I, start_link, Arg}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Child = [
        ?CHILD(log_login_srv, worker),
        ?CHILD(erl_log_sup, worker),
        ?CHILD(cache_srv, worker, [?http]),
        ?CHILD(node_connect, worker, [?http, ?mgr_node])
    ],
    {ok, {{one_for_one, 5, 10}, Child}}.

