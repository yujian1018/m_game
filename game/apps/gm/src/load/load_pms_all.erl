%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 十二月 2016 下午4:38
%%%-------------------------------------------------------------------
-module(load_pms_all).

-export([
    get_all_pms/0,
    get_all_pms/1,
    pms_update/2,
    pms_del/1
]).

get_all_pms() ->
    erl_mysql:eg(<<"SELECT id, top_id, `name` FROM pms_all where top_id=0 or top_id in (select id from pms_all where top_id = 0);">>).

get_all_pms(RoleId) ->
    Data = erl_mysql:eg(<<"SELECT id, top_id, `name`, url, pms_op FROM pms_all;">>),
    PmsIds = [list_to_tuple(I) || I <- erl_mysql:eg(<<"SELECT pms_id, pms_op FROM pms_role_permission WHERE role_id = ", RoleId/binary, ";">>)],
    
    lists:reverse(lists:foldl(
        fun([PmsId, TopId, Name, Url, PmsOpAll], Acc) ->
            case lists:keyfind(PmsId, 1, PmsIds) of
                false -> [[PmsId, TopId, Name, Url, 0, PmsOpAll, <<"">>] | Acc];
                {_, PmsOp} -> [[PmsId, TopId, Name, Url, 1, PmsOpAll, PmsOp] | Acc]
            end
        end,
        [],
        Data)).


pms_update(RoleId, Ids) ->
    erl_mysql:eg([
        <<"DELETE FROM pms_role_permission WHERE role_id = ", RoleId/binary, ";">>
        | [<<"INSERT INTO pms_role_permission (role_id, pms_id, pms_op) VALUES('", RoleId/binary, "', '", Id/binary, "', '", PmsOp/binary, "');">> || {Id, PmsOp} <- Ids]]).


pms_del(Ids) ->
    erl_mysql:eg([
        <<"DELETE FROM pms_all WHERE id = '", Id/binary, "';DELETE FROM pms_role_permission WHERE pms_id = ", Id/binary, ";">> || Id <- Ids]).