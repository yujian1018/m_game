-module(l2c_tcp_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1, start_child/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, temporary, 5000, Type, [I]}).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Child = [
        ?CHILD(l2c_tcp, worker)
    ],
    {ok, {{simple_one_for_one, 0, 1}, Child}}.


start_child([LSocet, Socket, CallBack]) ->
    supervisor:start_child(?MODULE, [[LSocet, Socket, CallBack]]).
