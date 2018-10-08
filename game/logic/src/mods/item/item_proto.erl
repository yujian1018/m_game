%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 04. 八月 2017 上午11:25
%%%-------------------------------------------------------------------
-module(item_proto).


-include("logic_pub.hrl").


-export([
    handle_info/2,
    online_send/1,
    send_to_client/1, send_to_client/2
]).


handle_info(?PROTO_USE_ITEM, [ItemId, Num]) ->
    Uid = erlang:get(?uid),
    cost_can:asset_item(Uid, [[ItemId, Num]]),
    buff_handler:is_user_item(Uid, ItemId),
    load_item:use_item(Uid, ItemId, Num),
    ?tcp_send(item_sproto:encode(?PROTO_USE_ITEM, 1));

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).


online_send(Data) ->
    ?tcp_send(item_sproto:encode(?PROTO_ONLINE_ITEM, Data)).

send_to_client(Uid, Data) when is_integer(Uid) ->
    ?send_cast(Uid, ?to_client_msg(item_sproto:encode(?PROTO_UPDATE_ITEM, Data))).

send_to_client(Data) ->
    ?tcp_send(item_sproto:encode(?PROTO_UPDATE_ITEM, Data)).
