-module(cache_app).

-behaviour(application).


-export([start/2, stop/1]).
-export([start/0, stop/0]).


start(_StartType, _StartArgs) ->
    {ok, Pid} = cache_sup:start_link(),
    cache_sup:start(),
    {ok, Pid}.


stop(_State) ->
    ok.


start() ->
    application:start(cache).


stop() ->
    application:stop(cache).