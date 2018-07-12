%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 九月 2017 下午2:54
%%%-------------------------------------------------------------------
-module(push_app).

-include("push_pub.hrl").

-behaviour(application).

-export([start/2, stop/1, stop/0, start/0]).

start(_StartType, _StartArgs) ->
    {ok, Pid} = push_sup:start_link(),
    ?INFO("push_server started...~n"),
    {ok, Pid}.

stop(_State) ->
    ok.


start() ->
    ?LAGER_START,
    inets:start(),
    ssl:start(),
    application:start(?push).


stop() ->
    application:stop(?push),
    init:stop().

