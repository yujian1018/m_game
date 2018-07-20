%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 公告缓存
%%%
%%% Created : 26. 十二月 2016 上午10:01
%%%-------------------------------------------------------------------
-module(cache_bulletin).


-behaviour(cache_srv).
-include("http_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").

-export([
    get_bulletin/1,
    select/0,
    refresh/0
]).


-record(bulletin, {
    id,
    channel_id,
    s_times,
    e_times,
    icon,
    title,
    content
}).

load_cache() ->
    [
        #cache_mate{
            name = cache_bulletin,
            key_pos = #bulletin.id
        }
    ].


get_bulletin(ChannelId) ->
    PlatformIds =
        case ets:lookup(cache_bulletin, {key, ?all_platform}) of
            [] -> [];
            [{_, _, Ids}] -> Ids
        end,
    AllIds =
        if
            ChannelId =:= ?all_platform ->
                PlatformIds;
            true ->
                case ets:lookup(cache_bulletin, {key, ChannelId}) of
                    [] -> PlatformIds;
                    [{_, _, Ids2}] -> PlatformIds ++ Ids2
                end
        end,
    
    Bulletins = lists:foldl(
        fun(Id, Acc) ->
            case ets:lookup(cache_bulletin, Id) of
                [] -> Acc;
                [#bulletin{title = Title, icon = Icon, content = Content}] ->
                    [{Title, Icon, Content} | Acc]
            end
        end, [], AllIds),
    lists:reverse(Bulletins).


select() ->
    ?rpc_db_call(sql_bulletin_board, sql_bulletin_board, []).


refresh() ->
    OldIds = case ets:lookup(cache_bulletin, all_ids) of
                 [] -> [];
                 [{_, _, IdList1}] -> IdList1
             end,
    
    Data = select(),
    
    FunFoldl =
        fun([Id, Channel, STime, ETime, Title, Icon, Content], {ChannelIds, InsertR, IdsAcc}) ->
            ChannelIds2 =
                case lists:keytake({key, Channel}, 2, ChannelIds) of
                    false ->
                        [{cache_bulletin, {key, Channel}, [Id]} | ChannelIds];
                    {_, {cache_bulletin, {key, Channel}, Ids}, R} ->
                        [{cache_bulletin, {key, Channel}, [Id | Ids]} | R]
                end,
            InsertR2 = [#bulletin{id = Id, channel_id = Channel, s_times = STime, e_times = ETime, title = Title, icon = Icon, content = Content} | InsertR],
            {ChannelIds2, InsertR2, [Id | IdsAcc]}
        end,
    
    {Channels, InsertRecords, AllIds} = lists:foldl(FunFoldl, {[], [], []}, Data),
    DelIds = erl_list:diff(OldIds, AllIds, []),
    
    ets:insert(cache_bulletin, InsertRecords),  %#bulletin{}
    ets:insert(cache_bulletin, {cache_bulletin, all_ids, AllIds}),  %{cache_bulletin, all_ids, ids}
    ets:insert(cache_bulletin, Channels),       %{channel, ids}
    
    [ets:delete(cache_bulletin, DelId) || DelId <- DelIds].