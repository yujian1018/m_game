%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 三月 2017 14:03
%%%-------------------------------------------------------------------
-module(im_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

-export([init/1]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Child = [
        ?CHILD(mgr_sup, supervisor)
    ],
    
    {ok, {{one_for_one, 5, 10}, Child}}.
