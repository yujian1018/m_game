-module(network).

-include("network_pub.hrl").

-export([start/3, start/4, stop/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Arg), {I, {I, start_link, Arg}, temporary, infinity, Type, [I]}).

%%test l2c:start(Port, ?TCP_OPTIONS, player_server, ws)

start(Port, Opts, CallBack) ->
    start(Port, Opts, CallBack, tcp).

start(Port, Opts, CallBack, Proto) ->
    Child = ?CHILD(l2c_accept_sup, supervisor, [Port, Opts, CallBack, Proto]),
    ChildProto =
        if
            Proto == tcp ->
                ?CHILD(l2c_tcp_sup, supervisor);
            Proto == ws ->
                ?CHILD(l2c_ws_sup, supervisor)
        end,
    supervisor:start_child(network_sup, ChildProto),
    supervisor:start_child(network_sup, Child).


stop(_State) ->
    ok.



    
    