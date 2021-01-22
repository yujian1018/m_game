%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%%-------------------------------------------------------------------
-module(l2c_accept).

-include("network_pub.hrl").

-export([start_link/3, loop/3]).


-define(CHILD(I, Type, Arg), {I, {I, start_link, Arg}, temporary, 5000, Type, [I]}).

start_link(LSocket, CallBack, Proto) ->
    Pid = erlang:spawn_link(fun() -> loop(LSocket, CallBack, Proto) end),
    {ok, Pid}.


loop(LSocet, CallBack, Proto) ->
    case gen_tcp:accept(LSocet, infinity) of % 进程会停在这里,等待用户连接
        {ok, Socket} ->
            {ok, Pid} =
                case Proto of
                    tcp ->
                        l2c_tcp_sup:start_child([LSocet, Socket, CallBack]);
                    ws ->
                        l2c_ws_sup:start_child([LSocet, Socket, CallBack])
                end,
            gen_tcp:controlling_process(Socket, Pid);
        {error, _Reason} ->
            ?INFO("accept error:~p~n", [{error, _Reason}])
    end,
%%    flush(),
    ?MODULE:loop(LSocet, CallBack, Proto).


%%flush() ->
%%    receive Msg ->
%%        error_logger:error_msg("tcp received unexpected message: ~p~n", [Msg]),
%%        flush()
%%    after 0 ->
%%        ok
%%    end.
