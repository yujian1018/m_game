%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 19. 七月 2016 下午1:25
%%%-------------------------------------------------------------------
-module(sys_proto).

-include("obj_pub.hrl").


-export([
    handle_info/2,
    send_tips/0,
    send_tips/1,
    send_reset_time/0
]).

%% 获取系统时间
handle_info(?PROTO_SERVER_TIMER, []) ->
    Times = erl_time:now(),
    ?tcp_send(sys_sproto:encode(?PROTO_SERVER_TIMER, Times));


handle_info(?PROTO_GET_CLIENT_SETTING, []) ->
    ?tcp_send(sys_sproto:encode(?PROTO_GET_CLIENT_SETTING, []));

handle_info(?PROTO_SET_CLIENT_SETTING, []) ->
    ?tcp_send(sys_sproto:encode(?PROTO_SET_CLIENT_SETTING, 0));

handle_info(?PROTO_SERVER_PING, []) ->
    ?tcp_send(sys_sproto:encode(?PROTO_SERVER_PING, erl_time:m_now()));


handle_info(?PROTO_LOG_LOGIN, Op) ->
    case Op of
        [6, Udid] ->
            {ok, {Ip, _Port}} = inet:peername(?get(?c_socket)),
            log_login_log:log_login_init(list_to_binary(inet:ntoa(Ip)), Udid);
        Op1 when is_integer(Op1) -> log_login_log:log_login_add(Op1);
        _Other -> ok
    end;

handle_info(?PROTO_OPEN_LAYER, LayerId) ->
    int_can:is_int(LayerId),
    erlang:put(?log_offline, LayerId),
    case erlang:get(?log_offlines) of
        undefined ->
            erlang:put(?log_offlines, [LayerId]);
        Data ->
            case length(Data) of
                100 ->
                    Uid = ?get(?uid),
                    log_pub:log_role_op(Uid, lists:reverse(Data)),
                    erlang:erase(?log_offlines);
                _ ->
                    erlang:put(?log_offlines, [LayerId | Data])
            end
    end,
    ?tcp_send(sys_sproto:encode(?PROTO_OPEN_LAYER, 1));

handle_info(?LOG_ALL_SHARE, [PlatformType, CssType, OpState]) ->
    Op = erlang:erase(?log_share),
    Uid = ?get(?uid),
    if
        OpState =:= 2 andalso Op =:= 1 ->
            log_ex:log_share(Uid, PlatformType, CssType, OpState);
        OpState =:= 1 andalso Op =:= 1 ->
            log_ex:log_share(Uid, PlatformType, CssType, 1),
            put(?log_share, 1);
        OpState =:= 1 ->
            put(?log_share, 1);
        true ->
            ok
    end;

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).

send_tips() ->
    FunFoldl =
        fun(I, Acc) ->
            case erlang:get(I) of
                1 -> [sys_def:tips(I) | Acc];
                _ -> Acc
            end
        end,
    Data = lists:foldl(FunFoldl, [], sys_def:tips_a()),
    ?tcp_send(sys_sproto:encode(?PROTO_SEND_TIPS, Data)).

send_tips(TipsId) ->
    ?tcp_send(sys_sproto:encode(?PROTO_SEND_TIPS, [TipsId])).

send_reset_time() ->
    ?tcp_send(sys_sproto:encode(?PROTO_SEND_RESET_TIME, [])).