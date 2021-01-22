%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 七月 2017 上午10:47
%%%-------------------------------------------------------------------
-include_lib("common/include/erl_pub.hrl").

%% 随机数种子
-define(pack_random, pack_random).

%% 客户端socket
-define(c_socket, c_socket).
-define(c_ip, c_ip).
-define(network_callback, network_callback).

%% 进程tcp连接状态 0:表示初始化 1:表示连接处理完成，可以交互数据
-define(TCP_CONNECT_STATE, tcp_connect_state).

-define(tcp_send(Data), tcp_mod:send(Data)).
-define(ws_send(Data), ws_mod:send(Data)).