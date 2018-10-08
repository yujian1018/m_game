%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 27. 六月 2017 下午7:53
%%%-------------------------------------------------------------------
-module(im_app).

-behaviour(application).

-include("im_pub.hrl").

-export([start/0, start/2, stop/1, stop/0]).

%% rabbitmq框架使用的tcp选项
%% -define(TCP_OPTIONS, [binary, {packet, 0}, {active, false},
%%                      {reuseaddr, true}, {nodelay, false}, {delay_send, true},
%%                      {send_timeout, 5000}, {keepalive, false}, {exit_on_close, true}]).
-define(TCP_OPTIONS, [
    binary,
    {packet, 0},            %%不设置包头长度
    {active, false},        %% 无法接收数据，直到inet:setopts(Socket, [{active, once}]), 接收一次数据
    {delay_send, true},     %%delay_send是不主动强制send, 而是等socket可写的时候马上就写 延迟发送：{delay_send, true}，聚合若干小消息为一个大消息，性能提升显著
    {nodelay, true},        %%If Boolean == true, the TCP_NODELAY option is turned on for the socket, which means that even small amounts of data will be sent immediately.
    {reuseaddr, true},
    {send_timeout, 5000},    %% 发送超时时间5s
    {high_watermark, 38528},   %% 默认8192 8kb
    {low_watermark, 19264}      %% 默认 4096 4kb

]).

start(_StartType, _StartArgs) ->
    ?LAGER_START,
    
    crypto:start(),
    emysql:start(),
    
    {ok, Pid} = im_sup:start_link(),
    init(),
    {ok, Pid}.

stop(_State) ->
    ok.

init() ->
    application:start(?network),
    {ok, Port} = application:get_env(im, port),
    l2c:start(Port, ?TCP_OPTIONS, im_server, ws),
    ?INFO("tcp port:~p~n", [Port]),
    start_http(),
    ok.


start() ->
    application:start(im).

stop() ->
    application:stop(?network),
    application:stop(im),
    init:stop().


start_http() ->
    application:start(ranch),
    application:start(cowlib),
    application:start(cowboy),
    
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/[...]", im_http, []}
        ]}
    ]),
    
    {ok, HttpPort} = application:get_env(im, port_http),
    
    {ok, Pid} = cowboy:start_clear(http, 16, [{port, HttpPort}], #{
        env => #{dispatch => Dispatch},
        request_timeout => 10000
    }),
    ?INFO("http port:~p... pid:~p started~n", [HttpPort, Pid]).