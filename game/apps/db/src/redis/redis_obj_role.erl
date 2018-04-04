%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc redis 操作
%%%
%%% Created : 14. 九月 2016 下午3:56
%%%-------------------------------------------------------------------
-module(redis_obj_role).

-include("db_pub.hrl").

-define(TAB(UidBin), <<"role:", UidBin/binary>>).

-define(attr_vo, <<"attr_vo">>).
-define(career_vo, <<"career_vo">>).

-export([
    set_role_vo/2,
    get_attr_vo/1,
    get_career_vo/1
]).

set_role_vo(Uids, RankType) ->
    UidIntS = [binary_to_integer(UidBin) || UidBin <- Uids],
    AttrVOs = load_attr:get_vo(UidIntS),
    CareerVOs = load_career:get_vo(UidIntS),
    {RoleVO, RankData} = foldl(AttrVOs, CareerVOs, RankType, {[], []}),
    db_redis:call_qp(?obj, RoleVO),
    ?encode(RankData).


foldl([], _CareerVO, _RankType, {Acc, RankAcc}) -> {Acc, lists:reverse(RankAcc)};
foldl([[Uid | AttrVO] | AttrVOR], [CareerVO | CareerVOR], RankType, {Acc, RankAcc}) ->
    UidBin = integer_to_binary(Uid),
    Key = ?TAB(UidBin),
    V = 0,
    NewAcc =
        {
            [[<<"HMSET">>, Key, ?attr_vo, ?encode([Uid | AttrVO]), ?career_vo, ?encode(CareerVO)], [<<"EXPIRE">>, Key, 300] | Acc],
            [[[Uid | AttrVO], CareerVO, V] | RankAcc]
        },
    foldl(AttrVOR, CareerVOR, RankType, NewAcc).


get_attr_vo(Uid) ->
    UidBin = integer_to_binary(Uid),
    Key = ?TAB(UidBin),
    case db_redis:q([<<"HMGET">>, Key, ?attr_vo]) of
        {ok, [?undefined]} -> <<"[]">>;
        {ok, [AttrVO]} -> AttrVO;
        _ -> <<"[]">>
    end.


get_career_vo(Uid) ->
    UidBin = integer_to_binary(Uid),
    Key = ?TAB(UidBin),
    case db_redis:q([<<"HMGET">>, Key, ?career_vo]) of
        {ok, [?undefined]} -> <<"[]">>;
        {ok, [CareerVO]} -> CareerVO;
        _ -> <<"[]">>
    end.