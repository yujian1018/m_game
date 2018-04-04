%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 25. 七月 2016 下午7:38
%%%-------------------------------------------------------------------
-module(tab_proto).


-include("gm_pub.hrl").

-export([handle_client/3]).


%% 只查询 10:op_state:1,2
handle_client(?TAB_LIST, #{pms_role_id:=RoleId, packet_id := PacketId, channel_id := ChannelId}, {[{?tab_name, TabName} | R]}) ->
    {NewR, PmsOp} = account_can:verify_pms(R, TabName, RoleId, ?OP_SELECT, PacketId, ChannelId),
    SqlEx = account_can:exit_v(PmsOp, NewR),
    tab_mod:tab_list(TabName, NewR, SqlEx);


%% 验证表名
handle_client(?TAB_ADD, #{pms_role_id:=RoleId, packet_id := PacketId, channel_id := ChannelId}, {[{?tab_name, TabName} | R]}) ->
    {NewR, PmsOp} = account_can:verify_pms(R, TabName, RoleId, ?OP_ADD, PacketId, ChannelId),
    account_can:exit_key(PmsOp, NewR),
    tab_mod:add(TabName, NewR),
    sys_handler:is_reload_config(TabName);

handle_client(?TAB_LOOKUP, #{pms_role_id:=RoleId, packet_id := PacketId, channel_id := ChannelId}, {[{?tab_name, TabName} | Keys]}) ->
    PmsOp = account_can:verify_pms(TabName, RoleId, ?OP_SELECT),
    VO = tab_mod:lookup(TabName, Keys),
    if
        PacketId =:= -1 andalso ChannelId =:= -1 -> {VO};
        true ->
            case lists:keyfind(<<"channel_id">>, 1, VO) of
                false -> ?return_err(?ERR_ARG_ERROR);
                {_, ChannelId} -> ok
            end,
            case account_can:exit_v(PmsOp, VO) of
                [] -> {VO};
                _ -> ?return_err(?ERR_ARG_ERROR)
            end
    end;

handle_client(?TAB_UPDATE, #{pms_role_id:=RoleId, packet_id := PacketId, channel_id := ChannelId}, {[{?tab_name, TabName} | R]}) ->
    {NewR, PmsOp} = account_can:verify_pms(R, TabName, RoleId, ?OP_EDIT, PacketId, ChannelId),
    account_can:exit_key(PmsOp, NewR),
    tab_mod:update(TabName, NewR),
    sys_handler:is_reload_config(TabName);

handle_client(?TAB_DELETE, #{pms_role_id:=RoleId, packet_id := PacketId, channel_id := ChannelId}, {[{?tab_name, TabName} | Keys]}) ->
    account_can:verify_pms(TabName, RoleId, ?OP_DEL),
    if
        PacketId =:= -1 andalso ChannelId =:= -1 -> ok;
        true ->
            account_can:verify_vo(TabName, PacketId, ChannelId),
            VO = tab_mod:lookup(TabName, Keys),
            case lists:keyfind(<<"channel_id">>, 1, VO) of
                false -> ?return_err(?ERR_ARG_ERROR);
                {_, ChannelId} -> ok
            end
    end,
    tab_mod:delete(TabName, Keys),
    sys_handler:is_reload_config(TabName);

handle_client(Paths, State, Qs) ->
    ?ERROR("not found this path:~p...uid:~p...qs:~p~n", [Paths, State, Qs]),
    <<"">>.

