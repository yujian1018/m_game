-module(t_ws).

-behaviour(websocket_client_handler).

-include("t_pub.hrl").

-export([
    start_link/1,
    init/2,
    websocket_handle/3,
    websocket_info/3,
    websocket_terminate/3
]).

-export([
    send/2
]).


start_link(Action) ->
    ?INFO("start_link:~p~n", [Action]),
    GameAddr = t_http_api:get_server(),
    websocket_client:start_link(GameAddr, ?MODULE, Action).

init(Action, _Req) ->
    ?put_new(?login_state, 0),
    ?INFO("player pid:~p...action:~p...totle:~p~n", [self(), Action, ets:info(ets_player, size)]),
    erlang:start_timer(?TIMEOUT_S_30, self(), ?timeout_s_30),
    {Uin, Token} = t_http_login:login(),
    ?put(?uin, Uin),
    ?put(?token, Token),
    {ok, #{}}.

websocket_handle({pong, _}, _Req, State) ->
    ?LOG("websocket_handle/3 arg:~p~n", [_Req]),
    {ok, State};

websocket_handle({binary, _Msg}, _Req, State) ->
    {ok, State};

websocket_handle({text, Msg}, _Req, State) ->
    DecodeData = ?decode(Msg),
    case erlang:get(?login_state) of
        0 ->
            [T1, T2, T3] = DecodeData,
            erlang:put(?pack_random, {T1, T2, T3}),
            Uin = ?get(?uin),
            Token = ?get(?token),
            Data = login_sproto:encode(?PROTO_LOGIN, [Uin, Token]),
            erlang:put(?tick, 0),
            erlang:put(?login_state, 1),
            {reply, {text, ?encode([network_mod:ws_uniform() | Data])}, State};
        1 ->
            case DecodeData of
                [ModId, ProtoId, Data] ->
                    case proto_dispatch:recv_dispatch(ModId, ProtoId, Data) of
                        error ->
                            {ok, State};
                        Data ->
                            Tick = erlang:get(?tick),
                            erlang:put(?tick, Tick + 1),
                            {reply, {text, ?encode([network_mod:ws_uniform() | Data])}, State}
                    end;
                _ ->
                    ?ERROR("arg err:~p~n", [DecodeData]),
                    {ok, State}
            end
    end.

websocket_info(start, _Req, State) ->
    ?LOG("start arg:~p~n", [_Req]),
    {ok, State};

websocket_info({timeout, _Ref, ?timeout_s_30}, _Req, State) ->
    Tick = erlang:get(?tick),
    Ret =
        if
            Tick =:= 0 ->
                ?INFO("tick~n"),
                {reply, {text, ?encode([network_mod:ws_uniform() | err_code_sproto:encode(?PROTO_SYS_TICK, [])])}};
            true ->
                erlang:put(?tick, 0),
                {ok, State}
        end,
    erlang:start_timer(?TIMEOUT_S_30, self(), ?timeout_s_30),
    Ret;

websocket_info({send, Data}, Req, State) ->
    websocket_client:send({text, ?encode([network_mod:ws_uniform() | Data])}, Req),
    Tick = erlang:get(?tick),
    erlang:put(?tick, Tick + 1),
    {ok, State};

websocket_info(InfoMsg, _Req, State) ->
    ?WARN("info msg:~p~n", [InfoMsg]),
    {ok, State}.


websocket_terminate(_Reason, _Req, _State) ->
    ?LOG("Websocket closed in state ~p wih reason ~p~n", [_State, _Reason]),
    ok.


send(Uid, Data) ->
    case player_mgr:get(Uid) of
        [] ->
            ?ERROR("send error:no uid:~p~n", [Uid]);
        Pid ->
            Pid ! {send, Data}
    end.