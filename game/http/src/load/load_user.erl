%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 25. 七月 2016 上午9:20
%%%-------------------------------------------------------------------
-module(load_user).

-include("http_pub.hrl").

-export([
    create_guest/5, create_account/7, create_sdk/8,
    
    exit_guest/2, exit_open_id/2,
    
    bound_account/9,
    
    account_role/2

]).

%% @doc 游客登陆
create_guest(ChannelId, Udid, DevicePf, IpBin, GMTOfftime) ->
    if
        Udid =:= <<"win32">> -> %% 特殊情况，一直创建新用户
            new_guest(ChannelId, erl_bin:uuid_bin(), DevicePf, IpBin, GMTOfftime);
        true ->
            case ?rpc_db_call(db_mysql, ea, [<<"select uin, ban_times from user where udid='", Udid/binary, "' and login_type = 1 limit 0, 1;">>]) of
                [[Uin, BanTimes]] ->
                    NowTimes = erl_time:now(),
                    if
                        BanTimes =/= undefined andalso BanTimes > NowTimes ->
                            ?return_err(?ERR_CLOSURE, integer_to_binary(BanTimes));
                        true -> ok
                    end,
                    log_pub:log_db_device(Udid, integer_to_binary(Uin), DevicePf, IpBin, erl_time:now_bin()),
                    load_user_info:reset_token(Uin, ChannelId);
                _ ->
                    new_guest(ChannelId, Udid, DevicePf, IpBin, GMTOfftime)
            end
    end.

%% 游客，账户密码登陆
new_guest(ChannelId, Udid, DevicePf, IpBin, GMTOfftime) ->
    Now = erl_time:now_bin(),
    Uin = ?rpc_db_call(db_mysql, ea, [<<"INSERT INTO user (c_times, login_type, channel_id, udid) VALUES ('",
        Now/binary, "', '1', '",
        ChannelId/binary, "', '",
        Udid/binary, "');">>]),
    log_pub:log_db_device(Udid, integer_to_binary(Uin), DevicePf, IpBin, Now),
    load_user_info:create_info(Uin, ChannelId, GMTOfftime).


%% @doc 账户登陆
create_account(AccountName, AccountPwd, ChannelId, Udid, DevicePf, IpBin, GMTOfftime) ->
    case ?rpc_db_call(db_mysql, ea, [<<"select uin, pwd, ban_times from user where user_name = '", AccountName/binary, "' and login_type = 2 limit 0, 1;">>]) of
        [[Uin, Pwd, BanTimes]] ->
            NowTimes = erl_time:now(),
            if
                BanTimes =/= undefined andalso BanTimes > NowTimes ->
                    ?return_err(?ERR_CLOSURE, integer_to_binary(BanTimes));
                true -> ok
            end,
            if
                Pwd =:= AccountPwd ->
                    log_pub:log_db_device(Udid, integer_to_binary(Uin), DevicePf, IpBin, integer_to_binary(NowTimes)),
                    load_user_info:reset_token(Uin, ChannelId);
                true ->
                    ?return_err(?ERR_INVALID_PWD, <<"密码不正确"/utf8>>)
            end;
        _ ->
            Now = integer_to_binary(erl_time:now()),
            Uin = ?rpc_db_call(db_mysql, ea, [
                <<"INSERT INTO user (user_name, pwd, c_times, login_type, channel_id, udid) VALUES ('",
                    AccountName/binary, "','",
                    AccountPwd/binary, "','",
                    Now/binary, "', '2', '",
                    ChannelId/binary, "', '",
                    Udid/binary, "');">>]),
            log_pub:log_db_device(Udid, integer_to_binary(Uin), DevicePf, IpBin, Now),
            load_user_info:create_info(Uin, ChannelId, GMTOfftime)
    end.


%% @doc sdk登陆
%%      当是微信平台时需要openid=unionid
create_sdk(SDKOpenId, SDKToken, ChannelId, Udid, DevicePf, IpBin, GMTOffSet, UserInfo) ->
    ExecData =
        case SDKOpenId of
            <<>> -> [];
            SDKOpenId ->
                ?rpc_db_call(db_mysql, ea, [<<"select uin from user_band where open_id = '",
                    SDKOpenId/binary, "' and channel_id = ",
                    ChannelId/binary, ";select uin, ban_times from user where sdk_openid='",
                    SDKOpenId/binary, "' and channel_id = ",
                    ChannelId/binary, " and login_type = 3 limit 0, 1;">>])
        end,
    ExecUin =
        case ExecData of
            [[], [[ThisUin, BanTimes]]] ->
                NowTimes = erl_time:now(),
                if
                    BanTimes =/= undefined andalso BanTimes > NowTimes -> ?return_err(?ERR_CLOSURE, BanTimes);
                    true -> ok
                end,
                ThisUin;
            [[[BandUin]], [[ThisUin, BanTimes]]] ->
                NowTimes = erl_time:now(),
                if
                    BanTimes =/= undefined andalso BanTimes > NowTimes -> ?return_err(?ERR_CLOSURE, BanTimes);
                    true -> ok
                end,
                if
                    BandUin =/= [] -> BandUin;
                    true -> ThisUin
                end;
            _ ->
                -1
        end,
    if
        ExecUin =:= -1 ->
            new_sdk(ChannelId, SDKOpenId, SDKToken, Udid, DevicePf, IpBin, GMTOffSet, UserInfo);
        true ->
            Now = erl_time:now_bin(),
            log_pub:log_db_device(Udid, integer_to_binary(ExecUin), DevicePf, IpBin, Now),
            load_user_info:reset_token(ExecUin, ChannelId)
    end.


new_sdk(ChannelId, SDKOpenId, SDKToken, Udid, DevicePf, IpBin, GMTOffSet, UserInfo) ->
    Now = erl_time:now_bin(),
    Uin = ?rpc_db_call(db_mysql, ea, [
        <<"INSERT INTO user (channel_id, sdk_openid, sdk_token, c_times,udid, login_type) VALUES ('",
            ChannelId/binary, "', '",
            SDKOpenId/binary, "','",
            SDKToken/binary, "', '",
            Now/binary, "', '",
            Udid/binary, "', '3');">>]),
    log_pub:log_db_device(Udid, integer_to_binary(Uin), DevicePf, IpBin, Now),
    load_user_info:create_info(Uin, ChannelId, GMTOffSet, UserInfo).


exit_guest(Udid, ChannelId) ->
    case ?rpc_db_call(db_mysql, ea, [<<"SELECT uin, ban_times FROM user WHERE udid = '", Udid/binary, "' and channel_id = '", ChannelId/binary, "' and login_type = '1' limit 0, 1;">>]) of
        [[Uin, BanTimes]] ->
            NowTimes = erl_time:now(),
            if
                BanTimes =/= undefined andalso BanTimes > NowTimes -> ?return_err(?ERR_CLOSURE, BanTimes);
                true -> Uin
            end;
        _ ->
            ?return_err(?ERR_ARG_ERROR, <<"游客登陆验证设备号失败"/utf8>>)
    end.


exit_open_id(ChannelId, SDKOpenId) ->
    case ?rpc_db_call(db_mysql, ea, [<<"select uin from user_band where channel_id = ", ChannelId/binary, " and open_id = '",
        SDKOpenId/binary, "';select uin from user where channel_id = ", ChannelId/binary, " and sdk_openid='", SDKOpenId/binary, "' limit 0, 1;">>]) of
        [[], []] -> 200;
        [[[_Uin]], _] -> ?return_err(?ERR_BAND_ACCOUNT, <<"该fb账户，已经绑定了账户"/utf8>>);
        [_, [[_Uin]]] -> ?return_err(?ERR_ACCOUNT_LOGIN, <<"该fb账户，已经登陆过游戏"/utf8>>)
    end.


%% 游客绑定账户
bound_account(SDKOpenId, SDKToken, ChannelId, Udid, DevicePf, IpBin, UinBin, GMTOffSet, UserInfo) ->
    if
        SDKOpenId =:= <<>> -> ?return_err(?ERR_ARG_ERROR, <<"SDKOpenId 不能为空"/utf8>>);
        true -> exit_open_id(ChannelId, SDKOpenId)
    end,
    ?rpc_db_call(db_mysql, ea, [<<"insert into user_band (channel_id, open_id, uin) values (",
        ChannelId/binary, ", '",
        SDKOpenId/binary, "', ",
        UinBin/binary, ");">>]),
    new_sdk(ChannelId, SDKOpenId, SDKToken, Udid, DevicePf, IpBin, GMTOffSet, UserInfo).


account_role(Udid, LoginType) ->
    case ?rpc_db_call(db_mysql, ea, [<<"SELECT uin, ban_times FROM user WHERE udid = '",
        Udid/binary, "' and login_type = '", LoginType/binary, "' limit 0, 1;select b.uin from user_band as a, user as b where b.udid = '",
        Udid/binary, "' and b.login_type = '", LoginType/binary, "' AND b.`sdk_openid` = a.`open_id` AND b.`channel_id` = a.`channel_id` limit 0, 1;">>]) of
        [[[Uin, BanTimes]], []] ->
            NowTimes = erl_time:now(),
            if
                BanTimes =/= undefined andalso BanTimes > NowTimes -> ?return_err(?ERR_CLOSURE, BanTimes);
                true ->
                    case ?rpc_db_call(db_mysql, ed, [<<"select b.uid from player as a, attr as b where a.uin = ", (integer_to_binary(Uin))/binary, " and a.uid = b.uid;">>]) of
                        [[_Uid] | _R] -> 200;
                        _ -> ?return_err(?ERR_EXEC_SQL_ERR)
                    end
            end;
        [[[_Uin1, _BanTimes]], [[_Uin2]]] ->
            ?return_err(?ERR_BAND_SDK);
        _ ->
            ?return_err(?ERR_ARG_ERROR)
    end.