%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 19. 四月 2016 上午9:33
%%%-------------------------------------------------------------------
-module(api_proto).

-include("http_pub.hrl").

-export([handle_client/3]).

handle_client(_Req, ?BULLETIN, Arg) ->
    ChannelId = binary_to_integer(proplists:get_value(<<"channel_id">>, Arg, <<"-999">>)),
    cache_bulletin:get_bulletin(ChannelId);

handle_client(Req, ?GET_SERVER, Arg) ->
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 channel_id"/utf8>>),
    CVersion = list_can:exit_v_not_null(<<"version">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 version"/utf8>>),
    Ip = cowboy_req:header(<<"x-real-ip">>, Req, <<"127.0.0.1">>),
    case binary:split(CVersion, <<".">>, [global]) of
        [CV1, CV2, _CV3] ->
            case cache_client_version:get_v(binary_to_integer(ChannelId), CV1, CV2) of
                [] ->
                    case ?rpc_mgr_call(mgr, get_addr, [?NODE_OBJ, CVersion]) of
                        {RetUrl, RetPort} ->
                            Switchs = cache_switch:get_v(ChannelId),
                            {RetUrl, RetPort, Switchs, Ip};
                        _Other ->
                            ?ERROR("arg:~p~n", [[ChannelId, CVersion, _Other]]),
                            ?return_err(?ERR_MAINTAIN_SYSTEM)
                    end;
                {Url, Port} ->
                    Switchs = cache_switch:get_v(ChannelId),
                    {Url, Port, Switchs, Ip};
                Url ->
                    ?return_err(?ERR_NEED_FORCE_UPDATE, Url)
            end;
        _ ->
            ?return_err(?ERR_ARG_ERROR, <<"客户端版本号不正确"/utf8>>)
    end;

handle_client(_Req, ?LOGIN_LOG, Arg) ->
    Udid = list_can:exit_v_not_null(<<"udid">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 udid"/utf8>>),
    Num = list_can:exit_v_not_null(<<"num">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 num"/utf8>>),
    list_can:member(Num, [<<"1">>, <<"2">>, <<"3">>, <<"4">>, <<"5">>], ?ERR_ARG_ERROR),
    log_login_srv:add(Udid, Num);



handle_client(Req, ?FEEDBACK, Arg) ->
    Uid = list_can:exit_v_not_null(<<"uid">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 Uid"/utf8>>),
    Udid = list_can:exit_v_not_null(<<"udid">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 udid"/utf8>>),
    Ip = cowboy_req:header(<<"x-real-ip">>, Req, <<"127.0.0.1">>),
    Version = list_can:exit_v_not_null(<<"version">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 version"/utf8>>),
    Msg = list_can:exit_v_not_null(<<"msg">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 msg"/utf8>>),
    Contact = list_can:exit_v_not_null(<<"contact">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 contact"/utf8>>),
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Arg, ?ERR_ARG_ERROR, <<"参数中没有 channel_id"/utf8>>),
    log_pub:log_feedback(Uid, Udid, Ip, ChannelId, Version, Msg, Contact);

handle_client(_Req, ?WX_JSAPI_SIGN, _Arg) ->
    sdk_weixin_sign:jsapi_sign();

handle_client(_Req, Cmd, Arg) ->
    ?INFO("handle_info no match ProtoId:~p...arg:~p~n", [Cmd, Arg]),
    ?return_err(?ERR_ARG_ERROR).
