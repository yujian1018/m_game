%%% -------------------------------------------------------------------
%%% Author  : Administrator
%%% Description :
%%%
%%% Created : 2012-9-24
%%% -------------------------------------------------------------------
-module(player_server).

-include("logic_pub.hrl").


-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2]).

-export([
    rpc_cast/3,
    rpc_call/3
]).


init({_Socket}) ->
%%    ?INFO("start player process:~p~n", [[self(), Socket]]),
    ?put_new(?tick, 0),
    ?put_new(?login_state, ?LOGIN_CONNECT_INIT),
    erlang:start_timer(?TIMEOUT_S_30, self(), ?timeout_s_30),
    {ok, #{}}.

%% 移动socket监听的socket
handle_call({re_online, Random, NewSocket}, _From, State) ->
    OldSocket = erlang:get(?c_socket),
    Tick = erlang:get(?tick),
    erlang:put(?pack_random, Random),
    erlang:put(?c_socket, NewSocket),
    
    Uid = ?get(?uid),
    login_proto:online_send_data(Uid),
    inet:setopts(NewSocket, [{active, once}]),
    erlang:put(?tick, Tick + 1),
    {reply, {ok, OldSocket}, State};

%% 为了兼容老版本，保存两份socket
handle_call(?ERR_EXIT_LOGIN, _From, State) ->
    ?tcp_send([0, 0, ?ERR_EXIT_LOGIN]),
    Tick = erlang:get(?tick),
    LoginState = erlang:get(?login_state),
%%    ?INFO("err_code:~w~n", [[self(), ?ERR_EXIT_LOGIN, State]]),
    
    if
        LoginState =:= ?LOGIN_INIT_DONE ->
            erlang:put(?tick, Tick + 1),
            {reply, ok, State};
        true ->
            {stop, normal, ok, State}
    end;

handle_call({stop, ErrCode}, _From, State) ->
    ?tcp_send([0, 0, ErrCode]),
%%    ?INFO("err_code:~w~n", [[self(), ErrCode, State]]),
    {stop, normal, ok, State};

handle_call({stop, ErrCode, Msg}, _From, State) ->
    ?tcp_send([0, 0, [ErrCode, Msg]]),
%%    ?INFO("err_code:~w~n", [[self(), ErrCode, State]]),
    {stop, normal, ok, State};

handle_call({call, Mod, _FromNode, _FromModule, Msg}, _From, State) ->
%%    ?INFO("handle_call mod 111:~p~n", [{mod, Mod, _FromNode, _FromModule, Msg}]),
    LoginState = erlang:get(?login_state),
    Ret =
        if
            LoginState =:= ?LOGIN_INIT_DONE ->
                case catch Mod:handler_call(Msg) of
                    {throw, _ErrCode} -> error;
                    {'EXIT', _Exit} ->
                        ?ERROR("handler info mod:~p~n", [_Exit]),
                        error;
                    Call -> Call
                end;
            true ->
                error
        end,
%%    ?INFO("handle_call call:~p~n", [Ret]),
    {reply, Ret, State};

handle_call(_Msg, _From, State) ->
%%    ?INFO("handle_call:~p~n", [[self(), _Msg, _From, State]]),
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.


handle_info({tcp, _Socket, RecvBin}, State) ->
%%    ?INFO("RecvBin:~p...~n", [[self(), rfc4627:decode(RecvBin), State]]),
    case catch ?decode(RecvBin) of
        [Validity, ModId, ProtoId, Json] ->
            case catch network_mod:sign(Validity) of
                ok ->
                    LoginState = ?get(?login_state),
                    proto_dispatch:recv_dispatch(ModId, ProtoId, Json, LoginState),
                    {noreply, State};
                _Check ->
                    {stop, normal, State}
            end;
        [Validity, ModId, Data] ->
            case catch network_mod:sign(Validity) of
                ok ->
                    LoginState = ?get(?login_state),
                    case Data of
                        [ProtoId, Json] ->
                            proto_dispatch:recv_dispatch(ModId, ProtoId, Json, LoginState);
                        [ProtoId | Json] ->
                            proto_dispatch:recv_dispatch(ModId, ProtoId, Json, LoginState)
                    end,
                    {noreply, State};
                _Check ->
                    {stop, normal, State}
            end;
        _Other ->
            {stop, normal, State}
    end;

%% @doc 心跳
handle_info({timeout, _TimerRef, ?timeout_s_30}, State) ->
%%    ?INFO("tcp timeout tick:~p~n", [[self(), State]]),
    Tick = erlang:get(?tick),
    erlang:start_timer(?TIMEOUT_S_30, self(), ?timeout_s_30),
    if
        Tick =:= 0 ->
            err_code_proto:err_code({throw, ?ERR_TERMINATE}),
            Uid = erlang:get(?uid),
            if
                Uid =/= 0 ->
                    erlang:put(?login_state, ?PLAYER_TERMINATE),
                    {stop, normal, State};
                true ->
                    {stop, normal, State}
            end;
        true ->
            erlang:put(?tick, 0),
            {noreply, State}
    end;

%% 发数据包
handle_info({?send_to_client, Msg}, State) ->
    ?tcp_send(Msg),
    {noreply, State};

handle_info(stop, State) ->
%%    ?INFO("handle_info 111:~p~n", [{stop, State, self()}]),
    {stop, normal, State};

handle_info({stop, ErrCode}, State) ->
%%    ?INFO("handle_info 111:~p~n", [{stop, State, self()}]),
%%    err_code_proto:err_code(State, 0, {throw, ErrCode}),
    ?tcp_send([0, 0, ErrCode]),
    {stop, normal, State};

handle_info({error, ErrCode}, State) ->
    err_code_proto:err_code({throw, ErrCode}),
    {noreply, State};

handle_info({mod, Mod, From, FromModule, Msg}, State) ->
%%    ?INFO("handle_info 111:~p~n", [{mod, Mod, From, FromModule, Msg}]),
    LoginState = erlang:get(?login_state),
    if
        LoginState =:= ?LOGIN_INIT_DONE ->
            Uid = ?get(?uid),
            case catch Mod:handler_msg(Uid, From, FromModule, Msg) of
                {throw, _ErrCode} -> ok;
                {'EXIT', _Exit} ->
                    ?ERROR("handler info mod:~p~n", [_Exit]);
                State1 -> State1
            end;
        true ->
            ok
    end,
%%    ?INFO("handle_info 222:~p~n", [NewState]),
    {noreply, State};

handle_info({timeout, _TimerRef, {mod, Mod, From, FromModule, Msg}}, State) ->
%%    ?INFO("timer callback:~p~n", [{mod, Mod, From, FromModule, Msg}]),
    LoginState = erlang:get(?login_state),
    if
        LoginState =:= ?LOGIN_INIT_DONE ->
            Uid = ?get(?uid),
            case catch Mod:handler_timeout(Uid, From, FromModule, Msg) of
                {throw, _ErrCode} -> ok;
                {'EXIT', _Exit} ->
                    ?ERROR("handler info mod:~p~n", [_Exit]);
                State1 -> State1
            end;
        true ->
            ok
    end,
    {noreply, State};

handle_info(_Info, State) ->
%%    ?INFO("handle_info: ~w~nState:~p~n", [_Info, State]),
    {noreply, State}.


terminate(_Reason, State) ->
%%    ?DEBUG("player process terminate:~p~n", [[_Reason, self(), State]]),
    LoginState = erlang:get(?login_state),
    if
        LoginState =:= ?LOGIN_INIT_DONE orelse LoginState =:= ?PLAYER_TERMINATE ->
            Uid = ?get(?uid),
            player_behaviour:save_data(Uid),
            attr_handler:offlien_event(),
            player_behaviour:terminate(Uid),
            player_mgr:del(self(), Uid);
        true ->
            ok
    end,
%% @doc 登陆打点，可能存在无法登陆的情况
    log_login_log:log_login_save(),
    State.


rpc_cast(Uid, PidBin, Msg) ->
    PlayerPid = list_to_pid(binary_to_list(PidBin)),
    case erlang:is_process_alive(PlayerPid) of
        true ->
            PlayerPid ! Msg;
        false ->
            redis_online:del(Uid)
    end.

rpc_call(Uid, PidBin, Msg) ->
    PlayerPid = list_to_pid(binary_to_list(PidBin)),
    case erlang:is_process_alive(PlayerPid) of
        true -> catch gen_server:call(PlayerPid, Msg);
        false ->
            redis_online:del(Uid),
            {error, ?ERR_NOT_ONLINE}
    end.