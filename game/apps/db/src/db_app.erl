-module(db_app).

-behaviour(application).

-export([start/2, stop/1, stop/0, start/0]).

-include("db_pub.hrl").


start(_StartType, _StartArgs) ->
    {ok, Pid} = db_sup:start_link(),
    
    case application:get_env(?db, is_mysql) of
        {ok, true} ->
            emysql:start();
        _ ->
            ok
    end,
    
    case application:get_env(?db, is_redis) of
        {ok, true} ->
            eredis_pool:start();
        _ ->
            ok
    end,
    
    case application:get_env(?db, is_mnesia) of
        {ok, true} ->
            db_mnesia_init:start();
        _ ->
            ok
    end,
    ?INFO("db_server started...~n"),
    {ok, Pid}.

stop(_State) ->
    ok.


start() ->
    ?LAGER_START,
    
    application:start(crypto),
    application:start(inets),
    
    application:start(?db).

stop() ->
    application:stop(?db).
