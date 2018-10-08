%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 玩家属性
%%%
%%% Created : 22. 七月 2016 下午5:07
%%%-------------------------------------------------------------------
-module(chat_proto).

-include("logic_pub.hrl").

-export([handle_info/2]).


handle_info(?PROTO_CHAT_HORN, MsgBin) ->
    Uid = erlang:get(?uid),
    IsChat =
        case config_prize:vip_fun_count(Uid, horn) of
            0 ->
                false;
            V ->
                Num = load_vip:get_v(Uid, <<"horn">>),
                if
                    Num >= V -> false;
                    true ->
                        load_vip:set_v(Uid, <<"horn">>),
                        true
                end
        end,
    if
        IsChat =:= ?true ->
            ok;
        IsChat =:= ?false ->
            asset_handler:del_asset(Uid, 1)
    end,
    Nick = load_attr:get_v(Uid, ?NICK),
    Str = cpn_mask_word:check(MsgBin),
    player_mgr:abcast(chat_handler, {abcast, notice, [10, Nick, Str]}),
    ?tcp_send(chat_sproto:encode(?PROTO_CHAT_HORN, 0));

handle_info(_Cmd, _RawData) ->
    ?INFO("handle_info no match ProtoId:~p~n Data:~p~n", [_Cmd, _RawData]).