%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description : tcp封装一层，该模块只用来
%%% 1.维护连接状态。（tcp连接、管理、心跳）
%%% 2.收发信息 （tcp收发信息）
%%% 3.转发进程信息（进程接收到的消息，转发给玩家回調模块（同一个进程）做逻辑处理）
%%% ws协议规则：https://segmentfault.com/a/1190000005680323

%%Frame format:
%%​​
%%      0                   1                   2                   3
%%      0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
%%     +-+-+-+-+-------+-+-------------+-------------------------------+
%%     |F|R|R|R| opcode|M| Payload len |    Extended payload length    |
%%     |I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
%%     |N|V|V|V|       |S|             |   (if payload len==126/127)   |
%%     | |1|2|3|       |K|             |                               |
%%     +-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
%%     |     Extended payload length continued, if payload len == 127  |
%%     + - - - - - - - - - - - - - - - +-------------------------------+
%%     |                               |Masking-key, if MASK set to 1  |
%%     +-------------------------------+-------------------------------+
%%     | Masking-key (continued)       |          Payload Data         |
%%     +-------------------------------- - - - - - - - - - - - - - - - +
%%     :                     Payload Data continued ...                :
%%     + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
%%     |                     Payload Data continued ...                |
%%     +---------------------------------------------------------------+
%% FIN	1bit	标明这一帧是否是整个消息体的最后一帧
%% RSV1 RSV2 RSV3	1bit	保留位，必须为0，如果不为0，则标记为连接失败
%% opcode	4bit	操作位，定义这一帧的类型

%x0	标明这一个数据包是上一个数据包的延续，它是一个延长帧 (continuation frame)
%x1	标明这个数据包是一个字符帧 (text frame)
%x2	标明这个数据包是一个字节帧 (binary frame)
%x3-7	保留值，供未来的非控制帧使用
%x8	标明这个数据包是用来告诉对方，我方需要关闭连接
%x9	标明这个数据包是一个心跳请求 (ping)
%xA	标明这个数据包是一个心跳响应 (pong)
%xB-F	保留至，供未来的控制帧使用

%% Mask	1bit	标明承载的内容是否需要用掩码进行异或
%% Masking-key	0 or 4bytes	掩码异或运算用的key
%% Payload length	7bit or 7 +16bit or 7 + 64bit 承载体的长度
%% 1.读取9-15位 (包括9和15位本身)，并转换为无符号整数。如果值小于或等于125，这个值就是长度；如果是 126，请转到步骤 2。如果它是 127，请转到步骤 3。
%% 2.读取接下来的 16 位并转换为无符号整数，并作为长度。
%% 3.读取接下来的 64 位并转换为无符号整数，并作为长度。
%%% Created : 2012-9-24
%%% -------------------------------------------------------------------

-module(l2c_ws).

-include("network_pub.hrl").

-behaviour(gen_server).

-export([encode/1, encode/2]).

-export([start_link/1, init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


start_link([LSocet, Socket, CallBack]) ->
    gen_server:start_link(?MODULE, [LSocet, Socket, CallBack], []).


init([_LSocet, Socket, CallBack]) ->
    process_flag(trap_exit, true),
    inet:setopts(Socket, [{active, once}]),

    ?put_new(?TCP_CONNECT_STATE, 0),
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
%%    ?INFO("tcp big data~n"),
    {stop, {tcp, max_bit}, State};

%% 收到tcp数据,握手
handle_info({tcp, Socket, RecvBin}, State) ->
%%    ?INFO("ws handle_info:~p~n", [[self(), Socket, RecvBin, State]]),
    CSocket = ?get(?c_socket),
    Ret =
        if
            CSocket =:= Socket ->
                case ?get(?TCP_CONNECT_STATE) of
                    0 ->
                        ws_mod:header(Socket, RecvBin),
                        ?ws_send(ws_mod:sign()),
                        erlang:erase(?TCP_CONNECT_STATE),
                        {noreply, State};
                    ?undefined ->
                        handle_pack(Socket, RecvBin, State)
                end;
            true ->
                {noreply, State}
        end,
    inet:setopts(CSocket, [{active, once}]),
%%    ?INFO("ws handle_info:~p~n", [[self(), RecvBin, Ret, State]]),
    Ret;


%% 用户正常下线,返回stop即可,析构函数在terminate()中
handle_info({tcp_closed, _Socket}, State) ->
%%    ?INFO("ws tcp_closed:~p~n", [[self(), _Socket, State]]),
    {stop, normal, State};

handle_info({tcp_passive, _Socket}, State) ->
%%    ?INFO("tcp tcp_passive:~p~n", [[self(), erlang:get(?c_socket), _Socket, State]]),
    {stop, normal, State};

handle_info({tcp_error, _Socket, _Reason}, State) ->
%%    ?INFO("tcp tcp_error:~p~n", [[self(), erlang:get(?c_socket), _Socket, State, _Reason]]),
    {stop, normal, State};

handle_info({inet_reply, _Sock, _Error}, State) ->
    if
        _Error =:= ok -> ok;
        true ->
            ?INFO("inet reply error: ~p~n", [_Error])
    end,
    {noreply, State};

handle_info(Info, State) ->
    CallBack = erlang:get(?network_callback),
    CallBack:handle_info(Info, State).


%% 进程关闭(包括正常下线,非正常下线都会调用此函数)
terminate(Reason, State) ->
%%    ?INFO("ws terminate:~p~n", [[self(), Reason, State]]),
    CallBack = erlang:get(?network_callback),
    CallBack:terminate(Reason, State).


code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


%% 正式接受数据
%x8	标明这个数据包是用来告诉对方，我方需要关闭连接
handle_pack(Socket, <<_Fin:1, _RSV:3, 8:4, _Rest/binary>>, State) ->
    gen_tcp:send(Socket, <<1:1, 0:3, 8:4>>),
    {stop, normal, State};

%x9	标明这个数据包是一个心跳请求 (ping)
%xA	标明这个数据包是一个心跳响应 (pong)
handle_pack(Socket, <<_Fin:1, _RSV:3, 9:4, _Rest/binary>>, State) ->
    gen_tcp:send(Socket, <<1:1, 0:3, 10:4>>),
    {noreply, State};

handle_pack(Socket, <<_Fin:1, _Rsv:3, _Opcode:4, _Mask:1, 126:7, Len:16, Rest/binary>>, State) ->
    handle_pack(Socket, Len, Rest, State);

handle_pack(Socket, <<_Fin:1, _Rsv:3, _Opcode:4, _Mask:1, 127:7, Len:64, Rest/binary>>, State) ->
    handle_pack(Socket, Len, Rest, State);

handle_pack(Socket, <<_Fin:1, _Rsv:3, _Opcode:4, _Mask:1, Len:7, Rest/binary>>, State) ->
    handle_pack(Socket, Len, Rest, State);

handle_pack(_Socket, _Bin, State) ->
    {noreply, State}.


handle_pack(Socket, Len, Rest, State) ->
    case Rest of
        <<Masking:4/binary, Payload:Len/binary, Next/binary>> ->
            Str = unmask(Payload, Masking, <<>>),
            case handle_str(Socket, Str, State) of
                {noreply, State2} ->
                    case size(Next) of
                        0 -> {noreply, State2};
                        _Other ->
                            handle_pack(Socket, Next, State2)
                    end;
                {stop, _Normal, State} ->
%%                    ?INFO("handle_info({tcp, Socket, Str}, State) return close"),
                    {stop, normal, State}
            end;
        _ ->
%%            ?INFO("tcp websocket RecvBin error handle_pack/5:~p~n", [Rest]),
%%            {stop, normal, State}
            {noreply, State}
    end.


handle_str(Socket, Str, State) ->
    CallBack = erlang:get(?network_callback),
    CallBack:handle_info({tcp, Socket, Str}, State).


unmask(Payload, Masking = <<MA:8, MB:8, MC:8, MD:8>>, Acc) ->
    case size(Payload) of
        0 -> Acc;
        1 ->
            <<A:8>> = Payload,
            <<Acc/binary, (MA bxor A)>>;
        2 ->
            <<A:8, B:8>> = Payload,
            <<Acc/binary, (MA bxor A), (MB bxor B)>>;
        3 ->
            <<A:8, B:8, C:8>> = Payload,
            <<Acc/binary, (MA bxor A), (MB bxor B), (MC bxor C)>>;
        _Other ->
            <<A:8, B:8, C:8, D:8, Rest/binary>> = Payload,
            Acc1 = <<Acc/binary, (MA bxor A), (MB bxor B), (MC bxor C), (MD bxor D)>>,
            unmask(Rest, Masking, Acc1)
    end.


encode(Bin) ->
    encode(Bin, 1).

encode(Bin, Opcode) ->
    Len = size(Bin),
    case Len of
        Len when Len < 126 ->
            <<1:1, 0:3, Opcode:4, 0:1, Len:7, Bin/binary>>;
        Len when Len < 65535 ->
            <<1:1, 0:3, Opcode:4, 0:1, 126:7, Len:16/unsigned-big-integer, Bin/binary>>;
        Len ->
            <<1:1, 0:3, Opcode:4, 0:1, 127:7, Len:64/unsigned-big-integer, Bin/binary>>
    end.