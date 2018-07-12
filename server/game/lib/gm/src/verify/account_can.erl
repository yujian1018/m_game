%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 五月 2016 下午4:13
%%%-------------------------------------------------------------------
-module(account_can).

-include("gm_pub.hrl").

-export([
    exit_account/1,
    exit_token/1,
    
    verify_pms/6,
    verify_pms/3,
    verify_vo/3,
    
    exit_v/2, exit_key/2
]).


exit_account(Account) ->
    case load_gm_account:get_account(Account) of
        [[Pwd, Token, TokenCTime, Name]] -> {ok, Pwd, Token, TokenCTime, Name};
        [] -> ?return_err(?ERR_NOT_EXIT_ACCOUNT)
    end.

exit_token(Token) ->
    case load_gm_account:get_token(Token) of
        [[Id, Account, PmsRoleId, PacketId, ChannelId]] -> {ok, Id, Account, PmsRoleId, PacketId, ChannelId};
        [] -> ?return_err(?ERR_LOGIN_TOKNE_OUTDATE)
    end.


verify_pms(Arg, TabName, RoleId, PmsAction, PacketId, ChannelId) ->
    {
        verify_arg(Arg, TabName, PacketId, ChannelId),
        verify_pms(TabName, RoleId, PmsAction)
    }.

verify_pms(TabName, RoleId, PmsAction) ->
    case load_pms_role:pms_action(TabName, integer_to_binary(RoleId), PmsAction) of
        false -> ?return_err(?ERR_PERMISSION_DENIED);
        _PmsOpo -> _PmsOpo
    end.

verify_arg(Arg, _TabName, -1, -1) -> Arg;
verify_arg(Arg, TabName, PacketId, ChannelId) ->
    TabNameMod = list_to_atom(binary_to_list(TabName)),
    RecordInfo = TabNameMod:record_info(),
    Arg1 =
        case lists:member('packet_id', RecordInfo) of
            true -> lists:keystore(<<"packet_id">>, 1, Arg, {<<"packet_id">>, integer_to_binary(PacketId)});
            false -> Arg
        end,
    case lists:member('channel_id', RecordInfo) of
        true -> lists:keystore(<<"channel_id">>, 1, Arg1, {<<"channel_id">>, integer_to_binary(ChannelId)});
        false -> Arg1
    end.

verify_vo(_TabName, -1, -1) -> ok;
verify_vo(TabName, _PacketId, _ChannelId) ->
    TabNameMod = list_to_atom(binary_to_list(TabName)),
    RecordInfo = TabNameMod:record_info(),
    case lists:member('channel_id', RecordInfo) of
        true -> ok;
        false -> ?return_err(?ERR_ARG_ERROR)
    end.


%% [{<<"10">>, <<"op_state">>, <<"1,2">>}]

%% 对应的表, 限制查询內容
exit_v(Fields, VO) ->
    Fun =
        fun({PmsNum, Field, V}, Acc) ->
            if
                PmsNum =:= <<"10">> ->
                    FunFoldl =
                        fun(I, SqlBin) ->
                            if
                                SqlBin =:= <<>> -> <<"`", Field/binary, "` = '", I/binary, "'">>;
                                true -> <<SqlBin/binary, " or `", Field/binary, "` = '", I/binary, "'">>
                            end
                        end,
                    Sql = lists:foldl(FunFoldl, <<>>, binary:split(V, <<",">>, [global])),
                    case lists:keyfind(Field, 1, VO) of
                        false -> [{Field, <<" (", Sql/binary, ") ">>} | Acc];
                        {_, <<"">>} -> [{Field, <<" (", Sql/binary, ") ">>} | Acc];
                        {_, VoValue} ->
                            case lists:member(VoValue, binary:split(V, <<",">>, [global])) of
                                true -> Acc;
                                _ -> ?return_err(?ERR_ARG_ERROR)
                            end
                    end;
                true ->
                    Acc
            end
        end,
    lists:foldl(Fun, [], Fields).

%% 对应的表, 限制插入內容
%% [{<<"9">>, <<"op_state">>, <<"1,2">>}]
exit_key(Fields, VO) ->
    Fun =
        fun({PmsNum, Field, V}) ->
            if
                PmsNum =:= <<"9">> ->
                    case lists:keyfind(Field, 1, VO) of
                        false -> true;
                        {_, <<"">>} -> true;
                        {_, VoValue} ->
                            if
                                is_integer(VoValue) ->
                                    case lists:member(integer_to_binary(VoValue), binary:split(V, <<",">>, [global])) of
                                        true -> true;
                                        _ -> ?return_err(?ERR_ARG_ERROR)
                                    end;
                                true ->
                                    case lists:member(VoValue, binary:split(V, <<",">>, [global])) of
                                        true -> true;
                                        _ -> ?return_err(?ERR_ARG_ERROR)
                                    end
                            end
                    end;
                true ->
                    true
            end
        end,
    lists:map(Fun, Fields).
