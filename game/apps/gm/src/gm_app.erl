-module(gm_app).

-behaviour(application).

-include("gm_pub.hrl").

-export([start/0, start/2, stop/1, stop/0]).


start(_StartType, _StartArgs) ->
    gm_sup:start_link().

stop(_State) ->
    ok.


start() ->
    init(),
    application:start(?gm),
    
    start_http().


init() ->
    ?LAGER_START,
    
    crypto:start(),
    inets:start(),
    emysql:start(),
    gm_app_ex:init().


stop() ->
    emysql:stop(),
    application:stop(?gm),
    init:stop().

start_http() ->
    application:start(ranch),
    application:start(cowlib),
    application:start(cowboy),
    
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/favicon.ico", gm_server, []},
            {"/api/[...]", gm_server, []},
            {"/", gm_server, []},
            {"/[...]", cowboy_static, {priv_dir, gm, <<"docroot">>, []}}
        ]}
    ]),
    {ok, HttpPort} = application:get_env(?gm, port),
    
    {ok, Pid} = cowboy:start_clear(http, 8, [{port, HttpPort}], #{
        env => #{dispatch => Dispatch},
        request_timeout => 10000
    }),
    ?INFO("start gm_tool server port:~p... pid:~p~n", [HttpPort, Pid]).


