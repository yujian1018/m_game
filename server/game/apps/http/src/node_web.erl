%%%-------------------------------------------------------------------
%%% @author yj 主节点
%%% @doc
%%%
%%% Created : 27. 七月 2016 下午3:06
%%%-------------------------------------------------------------------
-module(node_web).

-include("http_pub.hrl").


-export([
    send_to_game/3
]).


send_to_game(Uid, OrderId, IsSandbox) ->
    case redis_online:is_online(Uid) of
        false -> ok;
        {ok, _PidBin} -> ok;
        {ok, Node, PidBin} ->
            case net_adm:ping(Node) of
                pong ->
                    ?rpc_call(Node, Uid, PidBin, ?call_msg(asset_handler, {add_item, OrderId, IsSandbox}));
                pang ->
                    error
            end
    end.

