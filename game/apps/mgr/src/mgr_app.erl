-module(mgr_app).

-behaviour(application).

-export([start/2, stop/1, stop/0, start/0]).

-include("mgr_pub.hrl").


start(_StartType, _StartArgs) ->
    {ok, Pid} = mgr_sup:start_link(),
    ?INFO("mgr_server started...~n"),
    {ok, Pid}.

stop(_State) ->
    ok.


start() ->
    ?LAGER_START,
    application:start(?cache),
    application:start(?mgr).


stop() ->
    application:stop(?mgr),
    init:stop().
