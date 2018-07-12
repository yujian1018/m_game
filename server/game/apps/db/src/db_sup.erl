-module(db_sup).

-include("db_pub.hrl").

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Arg), {I, {I, start_link, Arg}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Child = [
        ?CHILD(node_connect, worker, [?db, ?mgr_node])
    ],
    {ok, {{one_for_one, 5, 10}, Child}}.

