%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 15. 十二月 2015 下午2:45
%%%-------------------------------------------------------------------
-module(erl_log_sup).

-behaviour(supervisor).

-export([
    start_link/0,
    init/1,
    start_child/1
]).


-define(CHILD(Name, I, Type, Arg), {Name, {I, start_link, [Arg]}, permanent, 5000, Type, [I]}).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    Child = [?CHILD(LogName, erl_log_srv, worker, LogName) || LogName <- log_pub:sup()],
    {ok, {{one_for_one, 5, 10}, Child}}.


start_child(Mod) ->
    supervisor:start_child(?MODULE, ?CHILD(Mod, erl_log_srv, worker, Mod)).
    

