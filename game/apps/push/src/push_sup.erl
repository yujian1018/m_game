%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 九月 2017 下午2:54
%%%-------------------------------------------------------------------
-module(push_sup).


-behaviour(supervisor).

-include("push_pub.hrl").

-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type, Arg), {I, {I, start_link, Arg}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Childs = [
        ?CHILD(push_srv, worker, []),
        ?CHILD(cron_srv, worker, [])
    ],
    {ok, {{one_for_one, 5, 10}, Childs}}.


