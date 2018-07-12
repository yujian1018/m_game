%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 19. 四月 2016 上午9:33
%%%-------------------------------------------------------------------
-module(login_proto).

-include("http_pub.hrl").

-export([handle_client/3]).


handle_client(Req, ?GUEST, Arg) ->
    Udid = list_can:exit_v_not_null(<<"udid">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 udid"/utf8>>),
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 channel_id"/utf8>>),
    GMTOffSet =
        case proplists:get_value(<<"gmt_offset">>, Arg, <<"0">>) of
            <<"NaN">> -> <<"0">>;
            _V -> _V
        end,
    IpBin = cowboy_req:header(<<"x-real-ip">>, Req, <<"127.0.0.1">>),
    load_user:create_guest(ChannelId, Udid, <<>>, IpBin, GMTOffSet);

handle_client(Req, ?ACCOUNT, Arg) ->
    Udid = list_can:exit_v_not_null(<<"udid">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 udid"/utf8>>),
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 channel_id"/utf8>>),
    GMTOffSet =
        case proplists:get_value(<<"gmt_offset">>, Arg, <<"0">>) of
            <<"NaN">> -> <<"0">>;
            _V -> _V
        end,
    IpBin = cowboy_req:header(<<"x-real-ip">>, Req, <<"127.0.0.1">>),
    AccountName = list_can:exit_v_not_null(<<"account_name">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 account_name"/utf8>>),
    AccountPwd = list_can:exit_v_not_null(<<"account_pwd">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 account_pwd"/utf8>>),
    case re:run(AccountName, <<"^(\\w){1,32}$">>) of
        nomatch -> ?return_err(?ERR_ILLEGAL_CHATS);
        _ -> ok
    end,
    Size = byte_size(AccountPwd),
    if
        Size >= 32 -> ?return_err(?ERR_ILLEGAL_CHATS);
        true -> ok
    end,
    load_user:create_account(AccountName, AccountPwd, ChannelId, Udid, <<>>, IpBin, GMTOffSet);

handle_client(Req, ?SDK, Arg) ->
    IpBin = cowboy_req:header(<<"x-real-ip">>, Req, <<"127.0.0.1">>),
    GMTOffSet =
        case proplists:get_value(<<"gmt_offset">>, Arg, <<"0">>) of
            <<"NaN">> -> <<"0">>;
            _V -> _V
        end,
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 channel_id"/utf8>>),
    Mod = cache_channel:get_mod(binary_to_integer(ChannelId)),
    Udid = list_can:get_arg(<<"udid">>, Arg),
    DevicePf = list_can:get_arg(<<"device_pf">>, Arg),
    {SDKOpenId, SDKToken, UserInfo} = Mod:login(Arg),
    load_user:create_sdk(SDKOpenId, SDKToken, ChannelId, Udid, DevicePf, IpBin, GMTOffSet, UserInfo);

handle_client(Req, ?ACCOUNT_BIND, Arg) ->
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 channel_id"/utf8>>),
    Udid = list_can:exit_v_not_null(<<"udid">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 udid"/utf8>>),
    Uin = load_user:exit_guest(Udid, ChannelId),
    
    IpBin = cowboy_req:header(<<"x-real-ip">>, Req, <<"127.0.0.1">>),
    DevicePf = list_can:get_arg(<<"device_pf">>, Arg),
    GMTOffSet =
        case proplists:get_value(<<"gmt_offset">>, Arg, <<"0">>) of
            <<"NaN">> -> <<"0">>;
            _V -> _V
        end,
    Mod = cache_channel:get_mod(binary_to_integer(ChannelId)),
    {SDKOpenId, SDKToken, UserInfo} = Mod:login(Arg),
    load_user:bound_account(SDKOpenId, SDKToken, ChannelId, Udid, DevicePf, IpBin, integer_to_binary(Uin), GMTOffSet, UserInfo);

handle_client(_Req, ?ACCOUNT_IS_BIND, Arg) ->
    OpenId = list_can:exit_v_not_null(<<"open_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 open_id"/utf8>>),
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 channel_id"/utf8>>),
    load_user:exit_open_id(ChannelId, OpenId);


handle_client(_Req, ?ACCOUNT_ROLE_INFO, Arg) ->
    Udid = list_can:exit_v_not_null(<<"udid">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 udid"/utf8>>),
    LoginType = list_can:exit_v_not_null(<<"login_type">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 login_type"/utf8>>),
    list_can:member(LoginType, [<<"1">>, <<"2">>, <<"3">>], ?ERR_ARG_ERROR),
    load_user:account_role(Udid, LoginType);


handle_client(_Req, Cmd, Arg) ->
    ?DEBUG("handle_info no match ProtoId:~p...arg:~p~n", [Cmd, Arg]),
    ?return_err(?ERR_ARG_ERROR).

