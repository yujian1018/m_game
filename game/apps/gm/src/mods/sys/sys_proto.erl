%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 五月 2016 下午4:13
%%%-------------------------------------------------------------------
-module(sys_proto).

-include("gm_pub.hrl").

-export([handle_client/3]).

handle_client(?GAME_LIST_INFO, #{pms_role_id:=RoleId}, {}) ->
    if
        RoleId =:= 1 -> true;
        true -> ?return_err(?ERR_PERMISSION_DENIED)
    end,
    {Data, Size} = mgr_srv:get_lists(),
    {tab_mod:max_page(Size, 60), Size, Data};

handle_client(?GET_OPTIONS, #{pms_role_id:=RoleId, packet_id := PacketId, channel_id := ChannelId}, {Type}) ->
    TypeInt = binary_to_integer(Type),
    if
        TypeInt =:= ?options_pms_role andalso RoleId =:= 1 -> load_pms_role:pms_roles();
        TypeInt =:= ?options_channel ->
            case load_account:get_channel(ChannelId) of
                [[Channel]] ->
                    [[ChannelId, Channel]];
                Data ->
                    Data
            end;
        TypeInt =:= ?options_packet ->
            case load_account:get_packet(PacketId) of
                [[Packet]] ->
                    [[PacketId, Packet]];
                Data ->
                    Data
            end;
        TypeInt =:= ?options_prize ->
            load_asset:asset_key();
        TypeInt =:= ?options_item ->
            load_asset:item_ids();
        TypeInt =:= ?options_mail_prize_id ->
            load_asset:mail_keys();
        true ->
            []
    end;

handle_client(?UPDATE_CONFIG_TAB, #{pms_role_id:=RoleId}, {TabName}) ->
    if
        RoleId =:= 1 -> true;
        true -> ?return_err(?ERR_PERMISSION_DENIED)
    end,
    sys_handler:reload_tabs(TabName);

handle_client(ProtoId, State, Qs) ->
    ?ERROR("not found this path:~p...uid:~p...qs:~p~n", [ProtoId, State, Qs]),
    <<"">>.
