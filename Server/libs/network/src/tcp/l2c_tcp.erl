%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description : tcp封装一层，该模块只用来
%%% 1.维护连接状态。（tcp连接、管理、心跳）
%%% 2.收发信息 （tcp收发信息）
%%% 3.转发进程信息（进程接收到的消息，转发给玩家回調模块（同一个进程）做逻辑处理）
%%%
%%% Created : 2012-9-24
%%% -------------------------------------------------------------------

-module(l2c_tcp).

-behaviour(gen_server).

-include("network_pub.hrl").

-export([start_link/1]).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


start_link([LSocet, Socket, CallBack]) ->
    gen_server:start_link(?MODULE, [LSocet, Socket, CallBack], []).


init([_LSocet, Socket, CallBack]) ->
    process_flag(trap_exit, true),
    inet:setopts(Socket, [{active, once}]),
    
    {R1, R2, R3} = tcp_mod:sign(),
%%    ?INFO("tcp init:~p~n", [{R1, R2, R3}]),
    tcp_mod:send(Socket, <<R1:32, R2:32, R3:32>>),
    ?put_new(?c_socket, Socket),
    ?put_new(?network_callback, CallBack),
    CallBack:init({Socket}).


handle_call(Msg, From, State) ->
    CallBack = erlang:get(?network_callback),
    CallBack:handle_call(Msg, From, State).


handle_cast(Msg, State) ->
    CallBack = erlang:get(?network_callback),
    CallBack:handle_cast(Msg, State).

%% 恶意连接,发大数据,具体最大数据还要测试,暂定40000,(5000　* 8)
handle_info({tcp, _Socket, RecvBin}, State) when bit_size(RecvBin) > 40000 ->
    ?INFO("tcp big data~n"),
    {stop, normal, State};

%% 收到tcp数据,握手
handle_info({tcp, Socket, RecvBin}, State) ->
%%    ?INFO("tcp handle_info:~p~n", [[self(), RecvBin, State]]),
    Ret =
        case RecvBin of
            <<Validity:8, Bin/binary>> ->
                case catch tcp_mod:sign(Validity) of
                    ok ->
                        CallBack = erlang:get(?network_callback),
                        CallBack:handle_info({tcp, Socket, Bin}, State);
                    _Check ->
                        {stop, normal, State}
                end;
            _ ->
                {stop, normal, State}
        end,
    
    inet:setopts(Socket, [{active, once}]),
%%    ?INFO("ws handle_info:~p~n", [[self(), RecvBin, Ret, State]]),
    Ret;

%% 由于断线重连，socket关闭，不在执行下线操作
handle_info({tcp_closed, _Socket}, State) ->
%%    ?INFO("tcp tcp_closed:~p~n", [[self(), erlang:get(?c_socket), Socket, State]]),
    {noreply, State};

handle_info({tcp_passive, _Socket}, State) ->
%%    ?INFO("tcp tcp_passive:~p~n", [[self(), erlang:get(?c_socket), Socket, State]]),
    {noreply, State};

handle_info({tcp_error, _Socket, _Reason}, State) ->
%%    ?INFO("tcp tcp_error:~p~n", [[self(), erlang:get(?c_socket), Socket, State, Reason]]),
    {noreply, State};

handle_info({inet_reply, _Sock, _Error}, State) ->
    if
        _Error =:= ok -> ok;
        true ->
            ?INFO("inet reply error: ~p~n", [_Error])
    end,
    {noreply, State};

%% 发数据包
handle_info(stop, State) ->
%%    ?INFO("fight_server handle_info stop:~p~n", [State]),
    {stop, normal, State};

handle_info(Info, State) ->
    CallBack = erlang:get(?network_callback),
    CallBack:handle_info(Info, State).


%% 进程关闭(包括正常下线,非正常下线都会调用此函数)
terminate(Reason, State) ->
%%    ?INFO("tcp terminate:~p~n", [[self(), Reason, State]]),
    CallBack = erlang:get(?network_callback),
    CallBack:terminate(Reason, State).


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.