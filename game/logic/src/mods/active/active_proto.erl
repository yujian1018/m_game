%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 01. 八月 2017 下午2:47
%%%-------------------------------------------------------------------
-module(active_proto).


-include("logic_pub.hrl").

-export([handle_info/2]).

-export([
    online_send/1,
    send/1,
    get_prize/4
]).


handle_info(?PROTO_ACTIVE_GET_PRIZE, [ActiveId, GiftId]) ->
    Uid = erlang:get(?uid),
    get_prize(Uid, ActiveId, GiftId, ?ACTIVE_PRIZE_TYPE_CLIENT),
    ?tcp_send(active_sproto:encode(?PROTO_ACTIVE_GET_PRIZE, 1));

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).


online_send(Data) ->
    ?tcp_send(active_sproto:encode(?PROTO_ACTIVE_SEND_DATA, Data)).


send(Data) ->
    ?tcp_send(active_sproto:encode(?PROTO_ACTIVE_UPDATE_DATA, Data)).


get_prize(Uid, ActiveId, GiftId, IsClient) ->
    list_can:member(ActiveId, global_active:all_prize_type(IsClient), ?ERR_ACTIVE_NO_ID),
    case global_active:get_active(ActiveId) of
        [] -> ?return_err(?ERR_ACTIVE_NO_GIFT_ID);
        {_TimeType, ProgressType, _PrizeType} ->
            case global_active_gift:get_active_id(GiftId) of
                {ActiveId, Limit, PrizeId} ->
                    case Limit of
                        ["active", ConfigNum] -> load_active:limit(Uid, ActiveId, ConfigNum);
                        Limit -> cost_can:asset_can(Uid, Limit)
                    end,
                    if
                        ProgressType =:= ?ACTIVE_TYPE_EX_ADDUP ->
                            case load_active:set_active_2(Uid, ActiveId, GiftId) of
                                ?true -> ok;
                                ?false -> ?return_err(?ERR_ACTIVE_EXIT_GIFT_ID)
                            end;
                        true ->
                            active_can:is_open(ActiveId),
                            case load_active:set_active(Uid, ActiveId, GiftId) of
                                ?true -> ok;
                                ?false -> ?return_err(?ERR_ACTIVE_EXIT_GIFT_ID)
                            end
                    end,
                    asset_handler:add_asset(Uid, PrizeId);
                _ -> ?return_err(?ERR_ACTIVE_NO_GIFT_ID)
            end
    end.