-module(t_sup).


-behaviour(supervisor).

-export([
    start_link/0
]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Childs = [
        ?CHILD(mgr_sup, supervisor),
        ?CHILD(srv_sup, supervisor),
        ?CHILD(t_ws_sup, supervisor)
    ],
    {ok, {{one_for_one, 5, 10}, Childs}}.

