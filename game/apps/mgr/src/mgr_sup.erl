-module(mgr_sup).

-behaviour(supervisor).

-include("mgr_pub.hrl").

-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type, Arg), {I, {I, start_link, Arg}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Childs = [
        ?CHILD(cache_srv, worker, [mgr]),
        ?CHILD(mgrs, worker, [])
    ],
    {ok, {{one_for_one, 5, 10}, Childs}}.

