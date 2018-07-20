%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 15. 十二月 2015 下午2:45
%%%-------------------------------------------------------------------
-module(log_sup).

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
    Child =
        [?CHILD(Id, log_srv, worker, {Mod, Id}) || {Mod, Id} <- log_pub:sup()] ++
        [?CHILD(Id, log_srv, worker, Id) || Id <- log_ex:sup()],
    {ok, {{one_for_one, 5, 10}, Child}}.


start_child(Mod) ->
    supervisor:start_child(?MODULE, ?CHILD(Mod, log_srv, worker, Mod)).
    

