%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 五月 2016 下午4:13
%%%-------------------------------------------------------------------
-module(load_gm_account).


-export([
    get_token/1,
    update_token/3,
    get_account/1
]).

get_token(Token) ->
    erl_mysql:eg(<<"SELECT id, account_id, pms_role_id, packet_id, channel_id FROM gm_account WHERE token = '", Token/binary, "';">>).

update_token(Account, NewToken, Now) ->
    case erl_mysql:eg(
        <<"UPDATE gm_account SET token = '", NewToken/binary, "', token_c_times = ", Now/binary, " WHERE account_id = '", Account/binary, "';">>
    ) of
        {error, _Err} -> {error, _Err};
        _ -> ok
    end.

get_account(Account) ->
    erl_mysql:eg(<<"SELECT pwd, token, token_c_times, name FROM gm_account WHERE account_id = '", Account/binary, "';">>).