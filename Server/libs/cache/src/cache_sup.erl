-module(cache_sup).


-behaviour(supervisor).

-define(no_cache_behaviour, 1).
-include("cache_pub.hrl").
-include("cache_err.hrl").

-export([start_link/0, init/1]).

-export([
    start/0,

    start_child/1,
    reload/0, reload/1, reload/2
]).

-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).
-define(CHILD(I, Type, Config), {Config#cache_mate.name, {I, start_link, [Config]}, transient, infinity, Type, [Config#cache_mate.name]}).


start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).


init([]) ->
    {ok, {{one_for_one, 5, 10}, []}}.


start() ->
    NewApps =
        case application:get_env(cache, app_names) of
            undefined -> [cache];
            {ok, Apps} -> lists:usort([cache | Apps])
        end,
    start(NewApps).


start(Apps) ->
    FunApp =
        fun(App) ->
            Mods = erl_file:get_mods(App, ?cache_behaviour),
            lists:map(fun(Mod) -> Mod:load_cache() end, Mods)
        end,
    Configs = lists:sort(
        fun(R1, R2) ->
            R1#cache_mate.priority =< R2#cache_mate.priority
        end,
        lists:flatten(lists:map(FunApp, Apps))),
    [supervisor:start_child(?MODULE, ?CHILD(cache_mgr, worker, Config)) || Config <- Configs].


start_child(Mod) ->
    Configs = Mod:load_cache(),
    [supervisor:start_child(?MODULE, ?CHILD(cache_mgr, worker, Config)) || Config <- Configs].


reload() ->
    NewApps =
        case application:get_env(cache, app_names) of
            undefined -> [cache];
            {ok, Apps} -> lists:usort([cache | Apps])
        end,
    FunApp =
        fun(App) ->
            Mods = erl_file:get_mods(App, ?cache_behaviour),
            lists:map(
                fun(Mod) ->
                    [ reload(Mod, Config#cache_mate.name)||Config <- Mod:load_cache()]
                end, Mods)
        end,
    lists:map(FunApp, NewApps).


reload(Module) -> reload(Module, Module).
reload(Module, Tab) ->
    case erl_file:is_behaviour(Module, ?cache_behaviour) of
        true ->
            case lists:keyfind(Tab, #cache_mate.name, Module:load_cache()) of
                false -> {error, ?CACHE_ERR_NO_DATA, "no table"};
                ConfigVO ->
                    case erlang:whereis(ConfigVO#cache_mate.name) of
                        ?undefined ->
                            supervisor:start_child(?MODULE, ?CHILD(cache_mgr, worker, ConfigVO));
                        Pid ->
                            case erlang:is_process_alive(Pid) of
                                true ->
                                    gen_server:call(Pid, {reset_cache, ConfigVO});
                                false ->
                                    supervisor:start_child(?MODULE, ?CHILD(cache_mgr, worker, ConfigVO))
                            end
                    end
            end;
        _ -> {error, ?CACHE_ERR_NO_DATA, "no behaviour"}
    end.