%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2016 上午10:01
%%%-------------------------------------------------------------------
-module(cache_client_version).

-behaviour(cache_srv).
-include("http_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").

-define(min_version, min_version).

-export([
    get_v/3,
    select/0,
    refresh/0
]).

-define(ETS_TAB, cache_client_version).

-record(client_version, {
    key,    %{channel_id, version}
    goto_link = <<"">>,
    s_url,
    s_port
}).

load_cache() ->
    [
        #cache_mate{
            name = ?ETS_TAB,
            key_pos = #client_version.key
        }
    ].


get_v(ChannelId, CV1, CV2) ->
    VO =
        case ets:lookup(?ETS_TAB, {ChannelId, <<CV1/binary, ".", CV2/binary, ".*">>}) of
            [] ->
                case ets:lookup(?ETS_TAB, {ChannelId, <<CV1/binary, ".*.*">>}) of
                    [] -> [];
                    [VO2] -> VO2
                end;
            [VO1] -> VO1
        end,
    if
        VO =:= [] -> [];
        true ->
            if
                VO#client_version.goto_link =:= <<>> andalso VO#client_version.s_url =:= <<>> -> [];
                VO#client_version.goto_link =:= <<>> -> {VO#client_version.s_url, VO#client_version.s_port};
                true -> VO#client_version.goto_link
            end
    end.


select() ->
    ?rpc_db_call(db_mysql, ea, [<<"SELECT channel_id, version, goto_link, s_url, s_port from client_version WHERE op_state = 1;">>]).


refresh() ->
    Data = select(),
    
    FunFoldl =
        fun([ChannelId, Version, GotoUrl, SUrl, SPort], {InsertR, IdsAcc}) ->
            InsertR2 = [#client_version{key = {ChannelId, Version}, goto_link = GotoUrl, s_url = SUrl, s_port = SPort} | InsertR],
            {InsertR2, [{ChannelId, Version} | IdsAcc]}
        end,
    {InsertRecords, AllIds} = lists:foldl(FunFoldl, {[], []}, Data),
    cache_srv:reset_record(?ETS_TAB, InsertRecords, AllIds).