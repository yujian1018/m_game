-module(http_app).

-behaviour(application).

-include("http_pub.hrl").

-export([start/0, start/2, stop/1, http_set_env/0, stop/0]).


start(_StartType, _StartArgs) ->
    start_http(),
    {ok, Pid} = http_sup:start_link(),
    init(),
    {ok, Pid}.

stop(_State) ->
    ok.


start() ->
    ?LAGER_START,
    
    application:start(crypto),
    application:start(inets),
    ssl:start(),
    application:start(?cache),
    application:start(?http).

start_http() ->
    application:start(ranch),
    application:start(cowlib),
    application:start(cowboy),
    
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/[...]", http_server, []}
        ]}
    ]),
    
    {ok, HttpPort} = application:get_env(?http, port),
    
    {ok, Pid} = cowboy:start_clear(?http, 16, [{port, HttpPort}], #{
        env => #{dispatch => Dispatch},
        request_timeout => 10000
    }),
    ?INFO("http port:~p... pid:~p started~n", [HttpPort, Pid]).


http_set_env() ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/[...]", login_mng, []}
        ]}
    ]),
    cowboy:set_env(?http, dispatch, Dispatch).


stop() ->
    application:stop(?http).


init() ->
    case application:get_env(?http, is_wx_jsapi_sign) of
        {ok, true} -> sdk_weixin_sign:jsapi_sign();
        _ -> ok
    end.