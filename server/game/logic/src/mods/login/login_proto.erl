%% Author: Administrator
%% Created: 2012-9-21
%% Description: 负责登陆,注册
%% 
-module(login_proto).

-include("obj_pub.hrl").

-export([
    handle_info/2,
    online_send_data/1
]).

%% 登录游戏
handle_info(?PROTO_LOGIN, [Uin, Token]) ->
    binary_can:illegal(Token),
    int_can:natural_num(Uin),
    ChannelId = redis_token:exit(Token, integer_to_binary(Uin)),
    Uid = load_attr:create_role(Uin, ChannelId),
    ?tcp_send(login_sproto:encode(?PROTO_LOGIN, 1)),
    is_online(Uin, Uid, binary_to_integer(ChannelId));

%% 断线重连
handle_info(?PROTO_RECONNECT, [Uin, Token]) ->
    binary_can:is_binary(Token),
    binary_can:illegal(Token),
    
    int_can:natural_num(Uin),
    
    ChannelId = redis_token:exit(Token, integer_to_binary(Uin)),
    Uid = load_attr:create_role(Uin, ChannelId),
    ?tcp_send(login_sproto:encode(?PROTO_RECONNECT, 1)),
    player_online2(Uin, Uid, binary_to_integer(ChannelId));

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).

is_online(Uin, Uid, ChannelId) ->
    case is_exit_online(Uin, Uid, ChannelId) of
        {ok, OldPid} ->
            ThisSocket = ?get(?c_socket),
            case catch gen_server:call(OldPid, {re_online, erlang:get(?pack_random), ThisSocket}, 10000) of
                {ok, OldSocket} ->
%%                    ?INFO("444:~p~n", [OldSocket]),
                    gen_tcp:controlling_process(ThisSocket, OldPid),
                    self() ! stop,
                    gen_tcp:close(OldSocket);
                _Other ->
                    gen_server:call(OldPid, {stop, ?ERR_OTHER_LOGIN}, 10000),
%%                    ?ERROR("555:~p~n", [_Other]),
                    online(Uin, Uid, ChannelId)
            end;
        State2 ->
            State2
    end.

is_exit_online(Uin, Uid, ChannelId) ->
    case redis_online:is_online(Uid) of
        {ok, OldPid} ->
%%            ?INFO("111:~p~n", [[OldPid]]),
            case erlang:is_process_alive(OldPid) of
                true ->
                    case catch gen_server:call(OldPid, ?ERR_OTHER_LOGIN, 10000) of
                        ok -> {ok, OldPid};
                        _Other ->
                            ?ERROR("err:~p~n", [_Other]),
                            catch gen_server:call(OldPid, {stop, ?ERR_OTHER_LOGIN}, 10000),
                            online(Uin, Uid, ChannelId)
                    end;
                false ->
                    online(Uin, Uid, ChannelId)
            end;
        {ok, Node, PidBin} ->
%%            ?INFO("222:~p~n", [[Uid]]),
            ?rpc_call(Node, Uid, PidBin, {stop, ?ERR_OTHER_LOGIN}),
            online(Uin, Uid, ChannelId);
        false ->
%%            ?INFO("333:~p~n", [[Uid]]),
            online(Uin, Uid, ChannelId)
    end.

player_online2(Uin, Uid, ChannelId) ->
%%    ?INFO("player_online2:~p~n", [[self(), State#player_state.uid]]),
    ?send_call(Uid, {stop, ?ERR_OTHER_LOGIN}),
    ?put(?uin, Uin),
    ?put(?uid, Uid),
    ?put(?channel_id, ChannelId),
    ?put(?login_times, erl_time:now()),
    player_mgr:add(self(), Uid),
    player_behaviour:load_data(Uid),
    player_behaviour:online(Uid),
    ?tcp_send(login_sproto:encode(?PROTO_DATA_OVER, 1)),
    ?put(?login_state, ?LOGIN_INIT_DONE).


online(Uin, Uid, ChannelId) ->
%%    ?INFO("online:~p~n", [[self(), State#player_state.uid]]),
    ?put(?uin, Uin),
    ?put(?uid, Uid),
    ?put(?channel_id, ChannelId),
    ?put(?login_times, erl_time:now()),
    player_mgr:add(self(), Uid),
    player_behaviour:load_data(Uid),
    player_behaviour:online(Uid),
    online_send_data(Uid).


online_send_data(Uid) ->
%%    ?INFO("online_send_data:~p~n", [[self(), State#player_state.uid]]),
    player_behaviour:online_send_data(Uid),
    ?tcp_send(login_sproto:encode(?PROTO_DATA_OVER, 1)),
    ?put(?login_state, ?LOGIN_INIT_DONE).