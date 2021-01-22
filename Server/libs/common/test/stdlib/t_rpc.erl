%%%-------------------------------------------------------------------
%%% @author admin
%%% @doc
%%%
%%% Created : 01. 三月 2017 16:48
%%%-------------------------------------------------------------------
-module(t_rpc).

-export([t/0, rpc/2]).

-define(SEQ, 1000).

t() ->
    Seq = lists:seq(1, ?SEQ),
    T1 = os:timestamp(),
    test(0, Seq),
    io:format("time cost:~p~n", [timer:now_diff(os:timestamp(), T1)]).


test(10, _Seq) -> ok;
test(Int, Seq) ->
%%    [spwn() || _I <- Seq],
    
    Fun =
        fun(_I) ->
%%            rpc:call('t2@192.168.2.21', t_rpc, rpc, [<<"Seq = lists:seq(1, 1000)T1 = os:timestamp(),test(0, Seq)io:format(time cost:~p~n, [timer:now_diff(os:timestamp(), T1)])">>, <<"Seq = lists:seq(1, 1000)T1 = os:timestamp(),test(0, Seq)io:format(time cost:~p~n, [timer:now_diff(os:timestamp(), T1)])">>])
%%            rpc:call('snake_obj_mgr@192.168.2.21', obj_server_mgr, get_addr, [<<"1.0.0">>, <<"192.168.2.19">>, 8084])
%%            rpc:call('snake_scene_mgr@192.168.2.21', scene_server_mgr, get_addr, [1, <<"1.0.0">>])
            
            Uid = integer_to_list(Int * ?SEQ + _I),
            Url = "http://192.168.2.19:8085/login/account?date=1488961780975&sign=9adf28a8bf402105edec0e78a41e70eb&packet_id=1&channel_id=-2&uuid=&device_pf=web&account_name=" ++ Uid ++ "&account_pwd=yujian",
            httpc:request(get, {Url, []}, [{timeout, 5000}], [])
        end,
    erl_list:lists_spawn(Fun, Seq),
    test(Int + 1, Seq).

rpc(A, B) ->
    {A, B}.

%%spwn() ->
%%    erlang:spawn_monitor(
%%        fun() ->
%%            rpc:call('t2@127.0.0.1', t_rpc, rpc, [<<"Seq = lists:seq(1, 1000)T1 = os:timestamp(),test(0, Seq)io:format(time cost:~p~n, [timer:now_diff(os:timestamp(), T1)])">>, <<"Seq = lists:seq(1, 1000)T1 = os:timestamp(),test(0, Seq)io:format(time cost:~p~n, [timer:now_diff(os:timestamp(), T1)])">>])
%%        end
%%    ).



