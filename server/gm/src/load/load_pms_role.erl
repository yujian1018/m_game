%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 十二月 2016 下午4:38
%%%-------------------------------------------------------------------
-module(load_pms_role).

-include("gm_pub.hrl").

-export([
    pms_action/3,
    get_pms/2,
    pms_roles/0
]).


%PmsAction sys_def:all_pms_op().
-spec pms_action(TabName :: binary(), RoleId :: binary(), PmsAction :: integer()) -> true|false.

pms_action(TabName, RoleId, PmsAction) ->
    case pms_table(TabName, RoleId) of
        false -> false;
        PmsOp ->
            case binary:split(PmsOp, integer_to_binary(PmsAction)) of
                [_] -> false;
                _ ->
                    Fun =
                        fun(I) ->
                            binary:split(I, <<":">>, [global])
                        end,
                    [{Num, Field, V} || [Num, Field, V] <- lists:map(Fun, binary:split(PmsOp, <<"-">>, [global])), Num =:= <<"9">> orelse Num =:= <<"10">>]
            end
    end.


pms_roles() ->
    erl_mysql:eg(<<"select role_id, role_name from pms_role;">>).

pms_table(TabName, RoleId) ->
    case erl_mysql:eg(<<"SELECT a.pms_op FROM pms_role_permission AS a, pms_all AS b WHERE a.`role_id` = ", RoleId/binary,
        " AND a.`pms_id` = b.`id` AND b.`tab` = '", TabName/binary, "' ;">>) of
        [[PmsOp]] -> PmsOp;
        _ -> false
    end.


get_pms(RoleId, <<"0">>) ->
    List = erl_mysql:eg(<<"SELECT a.name, a.url FROM pms_all AS a, pms_role_permission AS b WHERE b.`role_id` = ", RoleId/binary, " AND b.`pms_id` = a.`id` AND a.top_id = 0;">>),
    [{<<>>, [{[{<<"name">>, Name1}, {<<"url">>, Url}]} || [Name1, Url] <- List]}];

get_pms(RoleId, Lv) ->
    case erl_mysql:eg(<<"SELECT a.id, a.name, a.tab FROM pms_all AS a, pms_role_permission AS b WHERE a.top_id = ", Lv/binary, " AND a.`id` = b.`pms_id` AND b.`role_id` = ", RoleId/binary, ";">>) of
        [[Id, Name, _Tab]] ->
            Ret = erl_mysql:eg(<<"select a.name, a.url, a.tab, b.pms_op from pms_all as a, pms_role_permission AS b where a.top_id = ", (integer_to_binary(Id))/binary, " AND a.`id` = b.`pms_id` AND b.`role_id` = ", RoleId/binary, ";">>),
            [{Name, [{[{<<"name">>, Name2}, {<<"url">>, Url}, {<<"tab">>, Tab}, {<<"pms_op">>, PmsOp}]} || [Name2, Url, Tab, PmsOp] <- Ret]}];
        List ->
            Ret = erl_mysql:eg([<<"select a.name, a.url, a.tab, b.pms_op from pms_all as a, pms_role_permission AS b where a.top_id = ", (integer_to_binary(Id))/binary, " AND a.`id` = b.`pms_id` AND b.`role_id` = ", RoleId/binary, ";">> || [Id, _Name, _Tab1] <- List]),
            Fun = fun([_Id, Name, _Tab], RetList) ->
                {Name, [
                    if
                        Tab =:= undefined ->
                            {[{<<"name">>, Name1}, {<<"url">>, Url}, {<<"tab">>, <<"">>}, {<<"pms_op">>, PmsOp}]};
                        true ->
                            {[{<<"name">>, Name1}, {<<"url">>, Url}, {<<"tab">>, Tab}, {<<"pms_op">>, PmsOp}]}
                    end || [Name1, Url, Tab, PmsOp] <- RetList]}
                  end,
            erl_list:foldl(Fun, List, Ret)
    end.
