%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 13. 一月 2017 上午11:10
%%%-------------------------------------------------------------------
-module(load_account).

-export([
    get_channel/1,
    get_packet/1
]).



get_channel(-1) ->
    erl_mysql:execute(pool_account_1, <<"select channel_id, channel_name from channel;">>);
get_channel(ChannelId) ->
    erl_mysql:execute(pool_account_1, <<"select channel_name from channel where channel_id = ", (integer_to_binary(ChannelId))/binary, ";">>).


get_packet(-1) ->
    erl_mysql:execute(pool_account_1, <<"select packet_id, packet from packet;">>);
get_packet(PacketId) ->
    erl_mysql:execute(pool_account_1, <<"select packet from packet where packet_id = ", (integer_to_binary(PacketId))/binary, ";">>).