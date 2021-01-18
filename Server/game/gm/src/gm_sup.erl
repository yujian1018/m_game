-module(gm_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Arg), {I, {I, start_link, Arg}, permanent, 5000, Type, [I]}).

-ifdef(debug).
-define(Child, [?CHILD(reload, worker, [[gm]])]).
-else.
-define(Child, []).
-endif.


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Child = [
        ?CHILD(mgr_srv, worker),
        ?CHILD(log_srv, worker),
        ?CHILD(log_srv_hour, worker) | ?Child
    ],
    {ok, {{one_for_one, 1, 10}, Child}}.

