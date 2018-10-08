
%% Author: Administrator
%% Created: 2012-9-23
%% @doc application,服务器主监控进程.

-module(logic_app).

-behaviour(application).

-include("logic_pub.hrl").

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
    {send_timeout, 5000}    %% 发送超时时间5s
]).


start(_StartType, _StartArgs) ->
    ?LAGER_START,
    
    application:start(crypto),
    application:start(inets),
    
    
    application:start(?cache),
    
    {ok, Pid} = logic_sup:start_link(),
    init(),
    ?INFO("game started...~n"),
    {ok, Pid}.

stop(_State) ->
    ok.


start() ->
    application:start(?obj).

stop() ->
    application:stop(?network),
    application:stop(?obj),
    application:stop(?cache),
    init:stop().

init() ->
    application:start(?network),
    {ok, Port} = application:get_env(?obj, port),
    network:start(Port, ?TCP_OPTIONS, player_server, ws),
    ?INFO("tcp port:~p~n", [Port]),
    ok.
