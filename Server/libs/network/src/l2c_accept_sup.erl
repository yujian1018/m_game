-module(l2c_accept_sup).

-behaviour(supervisor).

-export([start_link/4]).

-export([init/1]).


-define(CHILD(I, RegNum, Type, Arg), {{I, RegNum}, {I, start_link, Arg}, temporary, 5000, Type, [I]}).


start_link(Port, Opts, CallBack, Proto) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Port, Opts, CallBack, Proto]).

init([Port, Opts, CallBack, Proto]) ->
    case gen_tcp:listen(Port, Opts) of
        {ok, LSocket} ->
            Schedulers = erlang:system_info(schedulers_online),
            Child = [?CHILD(l2c_accept, I, worker, [LSocket, CallBack, Proto]) || I <- lists:seq(1, Schedulers)],
            {ok, {{one_for_one, 1, 5}, Child}};
        _Other ->
            exit(["listen error~n", _Other])
    end.


