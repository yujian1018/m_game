%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 30. 五月 2018 下午3:09
%%%-------------------------------------------------------------------
-module(to_ets).

-define(no_cache_behaviour, 1).
-include("cache_pub.hrl").

-export([
    init/1,
    set/2,
    cache_data/4
]).

init(CacheConfig) ->
    ?ets_new(CacheConfig#cache_mate.name, CacheConfig#cache_mate.keypos, CacheConfig#cache_mate.type).


set(Config, Items) -> ets:insert(Config#cache_mate.name, Items).


cache_data(Config, _Md5, FileRecords, AllData) ->
    Md5 = erl_hash:md5_bin(term_to_binary(AllData)),

    All = cache_all_data(Config, FileRecords),
    DelIds =
        case All of
            [] -> [];
            [{_Name, Key, V} | _R] ->
                case ets:lookup(Config#cache_mate.name, Key) of
                    [] -> [];
                    [{_, _, V2}] -> V2 -- V
                end
        end,

    Group = cache_group_data(Config, FileRecords),
    ets:insert(Config#cache_mate.name, lists:flatten([All, Group])),
    ets:delete(Config#cache_mate.name, table_data),
    if
        Config#cache_mate.all =:= [] -> [];
        true -> ets:insert(Config#cache_mate.name, {Config#cache_mate.name, table_data, AllData})
    end,

    gen_server:call(?cache_tab_md5, {reset_md5, Config#cache_mate.name, Md5}),
    case DelIds of
        [] -> ok;
        DelIds -> lists:map(fun(Id) -> ets:delete(Config#cache_mate.name, Id) end, DelIds)
    end.


cache_all_data(Config, FileRecords) ->
    if
        Config#cache_mate.all =:= [] ->
            [];
        true ->
            FunIndex =
                fun(Index) ->
                    ets:delete(Config#cache_mate.name, {'all', Index}),
                    ColumnAll = lists:map(fun(Record) -> element(Index, Record) end, FileRecords),
                    {Config#cache_mate.name, {'all', Index}, ColumnAll}
                end,
            lists:map(FunIndex, Config#cache_mate.all)
    end.

cache_group_data(Config, FileRecords) ->
    if
        Config#cache_mate.group =:= [] ->
            [];
        true ->
            FunIndex2 =
                fun(Index2) ->
                    FunFoldl =
                        fun(Record2, NewVO) ->
                            GroupTypeId = element(Index2, Record2),
                            KeyId2 = element(Config#cache_mate.keypos, Record2),
                            ets:delete(Config#cache_mate.name, {'group', Index2, GroupTypeId}),
                            case lists:keytake({'group', Index2, GroupTypeId}, 2, NewVO) of
                                false ->
                                    [{Config#cache_mate.name, {'group', Index2, GroupTypeId}, [KeyId2]} | NewVO];
                                {value, {_, _, KeyIds}, TupleList2} ->
                                    [{Config#cache_mate.name, {'group', Index2, GroupTypeId}, [KeyId2 | KeyIds]} | TupleList2]
                            end
                        end,
                    [{TabName, GroupK, lists:reverse(GroupV)} || {TabName, GroupK, GroupV} <- lists:foldl(FunFoldl, [], FileRecords)]
                end,
            lists:map(FunIndex2, Config#cache_mate.group)
    end.