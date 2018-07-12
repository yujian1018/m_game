%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 10. 八月 2016 上午10:34
%%%-------------------------------------------------------------------
-module(attr_proto).

-include("obj_pub.hrl").
-include("../../db/load_attr.hrl").

-export([
    handle_info/2,
    online_send/1,
    send_attr/1, send_attr/2
]).

%%客户端更新协议
handle_info(?PROTO_ATTR_CLIENT_UPDATE, Data) ->
    Uid = erlang:get(?uid),
    NewData = attr_can:attr(Uid, Data),
    load_attr:set_v(Uid, NewData),
    ?tcp_send(attr_sproto:encode(?PROTO_ATTR_CLIENT_UPDATE, 1));

handle_info(?PROTO_ATTR_VO, Uid) ->
    int_can:is_int(Uid),
    AttrVO = load_attr:get_vo(Uid),
    ?tcp_send(attr_sproto:encode(?PROTO_ATTR_VO, AttrVO));


handle_info(?PROTO_ATTR_GET_ACTIVE_REWARDS, RewardsIndex) ->
    int_can:is_int(RewardsIndex),
    Uid = erlang:get(?uid),
    [ActivePoint, ActiveRewards] = load_attr:get_v(Uid, [?ACTIVE_POINT, ?ACTIVE_REWARDS]),
    case ActiveRewards of
        [] -> ok;
        ActiveRewards ->
            case lists:member(RewardsIndex, ActiveRewards) of
                true -> ?return_err(?ERR_ATTR_ACTIVE_REWARDS);
                false -> ok
            end
    end,
    AllPrize = global_config:get_v(?attr, ?active_rewards),
    [ConfigActivePoint, ConfigPrizeId] = lists:nth(RewardsIndex, AllPrize),
    if
        ActivePoint >= ConfigActivePoint ->
            asset_handler:add_asset(Uid, ConfigPrizeId),
            load_attr:set_v(Uid, [[?ACTIVE_REWARDS, "=", [RewardsIndex | ActiveRewards]]]);
        true -> ?return_err(?ERR_ATTR_NOT_ACTIVE_POINT)
    end,
    ?tcp_send(attr_sproto:encode(?PROTO_ATTR_GET_ACTIVE_REWARDS, 1));

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).


online_send(Data) ->
    ?tcp_send(attr_sproto:encode(?PROTO_ATTR_ONLINE_SEND, Data)).


%% @doc 自己进程调用
send_attr(Data) ->
    ?tcp_send(attr_sproto:encode(?PROTO_ATTR_UPDATE, Data)).

%% @doc 其他进程调用
send_attr(Uid, Data) when is_integer(Uid) ->
    ?send_cast(Uid, ?to_client_msg(attr_sproto:encode(?PROTO_ATTR_UPDATE, Data))).
