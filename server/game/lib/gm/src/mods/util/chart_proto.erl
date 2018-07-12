%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 五月 2016 下午4:13
%%%-------------------------------------------------------------------
-module(chart_proto).

-include("gm_pub.hrl").

-export([handle_client/3]).

handle_client(?CHART_INDEX, #{packet_id := PacketId, channel_id := ChannelId}, {}) ->
    [list_to_tuple(I) || I <- load_report_data_center_d:echarts_1(PacketId, ChannelId)];

handle_client(ProtoId, AccountId, Qs) ->
    ?ERROR("not found this path:~p...uid:~p...qs:~p~n", [ProtoId, AccountId, Qs]),
    <<"">>.