%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 五月 2016 下午4:13
%%%-------------------------------------------------------------------
-module(account_proto).

-include("gm_pub.hrl").

-export([handle_client/3]).

-define(TOKEN_EXPIRES, 86400 * 7).

handle_client(?ACCOUNT_LOGIN, #{account_id := <<>>}, {Account, Pwd}) ->
    case account_can:exit_account(Account) of
        {ok, Pwd, Token, TokenCTime, Name} ->
            Now = erl_time:now(),
            if
                Token =:= <<>> orelse Token =:= undefined ->
                    NewToken = list_to_binary(erl_string:uuid()),
                    load_gm_account:update_token(Account, NewToken, integer_to_binary(Now)),
                    {<<"token">>, NewToken, {Name, <<>>}};
                true ->
                    ExpiresTime = TokenCTime + ?TOKEN_EXPIRES,
                    if
                        ExpiresTime > Now -> {<<"token">>, Token, {Name, <<>>}};
                        true ->
                            NewToken = list_to_binary(erl_string:uuid()),
                            load_gm_account:update_token(Account, NewToken, integer_to_binary(Now)),
                            {<<"token">>, NewToken, {Name, <<>>}}
                    end
            end;
        _ ->
            ?return_err(?ERR_PWD_ERROR)
    end;



handle_client(?GET_PMS, #{pms_role_id:=RoleId}, {TopPmsId}) ->
    {
        load_pms_role:get_pms(integer_to_binary(RoleId), <<"0">>),
        load_pms_role:get_pms(integer_to_binary(RoleId), TopPmsId)
    };



handle_client(?PMS_MY_ALL, #{pms_role_id:=RoleId}, {}) ->
    if
        RoleId =:= 1 ->
            load_pms_all:get_all_pms();
        true ->
            ?return_err(?ERR_PERMISSION_DENIED)
    end;

handle_client(?PMS_ALL, #{pms_role_id:=RoleId}, {_RoleId}) ->
    if
        RoleId =:= 1 ->
            load_pms_all:get_all_pms(_RoleId);
        true ->
            ?return_err(?ERR_PERMISSION_DENIED)
    end;

handle_client(?PMS_UPDATE, #{pms_role_id:=AccountRoleId}, {[{<<"role_id">>, RoleId} | Arg]}) ->
    if
        AccountRoleId =:= 1 ->
            FunFoldl =
                fun({I, Op}, {Acc1, Acc2}) ->
                    case binary:split(I, <<"_">>) of
                        [I] ->
                            {[I | Acc1], Acc2};
                        [I1, I2] ->
                            if
                                Op =:= <<"off">> -> {Acc1, Acc2};
                                true ->
                                    case lists:keytake(I1, 1, Acc2) of
                                        false ->
                                            {Acc1, [{I1, [I2]} | Acc2]};
                                        {value, {_, Acc2I2}, Acc2R} ->
                                            {Acc1, [{I1, [I2 | Acc2I2]} | Acc2R]}
                                    end
                            end
                    end
                end,
            {AllPms, AllPmsOp} = lists:foldl(FunFoldl, {[], []}, Arg),
            Fun =
                fun(I) ->
                    case lists:keyfind(I, 1, AllPmsOp) of
                        false -> {I, <<>>};
                        {_, Ops} ->
                            OpsBin = lists:foldl(
                                fun(IOp, Acc) ->
                                    if Acc =:= <<>> -> IOp; true -> <<IOp/binary, "-", Acc/binary>> end
                                end,
                                <<>>,
                                Ops),
                            {I, OpsBin}
                    end
                end,
            load_pms_all:pms_update(RoleId, lists:reverse(lists:map(Fun, AllPms)));
        true ->
            ?return_err(?ERR_PERMISSION_DENIED)
    end;

handle_client(?PMS_DEL, #{pms_role_id:=AccountRoleId}, {Arg}) ->
    if
        AccountRoleId =:= 1 ->
            load_pms_all:pms_del([I || {I, <<"on">>} <- Arg]);
        true ->
            ?return_err(?ERR_PERMISSION_DENIED)
    end;


handle_client(Paths, State, Qs) ->
    ?ERROR("not found this path:~p...uid:~p...qs:~p~n", [Paths, State, Qs]),
    <<"">>.