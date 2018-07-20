%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 06. 五月 2016 上午10:52
%%%-------------------------------------------------------------------
-module(gm_server).

-include("gm_pub.hrl").


-export([init/2]).

init(Req, Opts) ->
%%    ?INFO("111:~p~n", [[cowboy_req:path_info(Req)]]),
    Ret = case cowboy_req:path(Req) of
              <<"/">> -> {<<"url">>, <<"/index.html">>};
              <<"/favicon.ico">> ->
                  <<"data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==">>;
              _ ->
                  case cowboy_req:path_info(Req) of
                      [ModId, ProtoId] ->
                          case catch match_cookies(Req, ModId, ProtoId) of
                              {ok, State} ->
                                  catch dispath_handler(Req, ModId, ProtoId, State, arg(Req));
                              _ ->
                                  {<<"location">>, <<"/login.html">>}
                          end
                  end
          end,
%%    ?INFO("ret:~p~n", [Ret]),
    Req1 = response_json(Req, Ret),
    {ok, Req1, Opts}.


arg(Req) ->
    case cowboy_req:method(Req) of
        <<"GET">> -> {cowboy_req:parse_qs(Req)};
        <<"POST">> ->
            case cowboy_req:has_body(Req) of
                true ->
                    %% 需要区分这两种情况, 1 正常情况， 2 表单上传
                    ContentType = cowboy_req:header(<<"content-type">>, Req),
                    case binary:match(ContentType, <<"multipart/form-data">>) of
                        nomatch ->
                            {ok, PostVals, _Req2} = cowboy_req:read_body(Req),
                            {cow_qs:parse_qs(PostVals)};
                        _ ->
                            {Result, _Req2} = acc_multipart(Req, []),
                            Result
                    end;
                false ->
                    []
            end
    end.

acc_multipart(Req, Acc) ->
    case cowboy_req:read_part(Req) of
        {ok, Headers, Req2} ->
            {ok, Body, Req3} = cowboy_req:read_part_body(Req2),
            acc_multipart(Req3, [{Headers, Body} | Acc]);
        {done, Req2} ->
            {lists:reverse(Acc), Req2}
    end.


match_cookies(Req, ModId, ProtoId) ->
    case gm_can:no_need_login({ModId, ProtoId}) of
        {error, Err} ->
            #{client := _ClientCookie, server := ServerCookie} = cowboy_req:match_cookies([{client, [], <<>>}, {server, [], <<>>}], Req),
            case ServerCookie of
                <<>> ->
                    {error, Err};
                Token ->
                    {ok, Id, Uid, PmsRoleId, PacketId, ChannelId} = account_can:exit_token(Token),
                    {ok, #{id => Id, account_id=>Uid, pms_role_id=>PmsRoleId, packet_id=>PacketId, channel_id=>ChannelId}}
            end;
        ok ->
            {ok, #{account_id => <<>>}}
    end.


dispath_handler(_Req, ModId, ProtoId, State = #{account_id:=Uid}, Arg) ->
%%    ?INFO("aaa:~p~n", [[ModId, ProtoId, State, Arg]]),
    case proto_all:lookup_cmd(ModId) of
        {error, _ErrCode} -> ?return_err(?ERR_ARG_ERROR, <<"沒有对应的api"/utf8>>);
        {HandlerMod, ProtoMod} ->
            put(uid, Uid),
            NewArg =
                case gm_can:no_decode({ModId, ProtoId}) of
                    true -> Arg;
                    false -> ProtoMod:decode(ProtoId, Arg)
                end,
            case HandlerMod:handle_client(ProtoId, State, NewArg) of
                {<<"token">>, Token, Account} ->
                    {<<"token">>, Token, jiffy:encode({[{<<"code">>, 200} | ProtoMod:encode(ProtoId, Account)]})};
                Json when is_binary(Json) -> Json;
                Json ->
%%                    ?DEBUG("json:~p~n", [Json]),
                    jiffy:encode({[{<<"code">>, 200} | ProtoMod:encode(ProtoId, Json)]})
            end
    end.


response_json(Req, Data) ->
    Response =
        case Data of
            {<<"url">>, Url} -> cowboy_req:reply(301, cowboy_req:set_resp_header(<<"location">>, Url, Req));
            {<<"location">>, LocationUrl} -> <<"{\"location\":\"", LocationUrl/binary, "\"}">>;
            {throw, ErrCode} -> to_msg(ErrCode);
            {throw, ErrCode, Msg} -> to_msg(ErrCode, Msg);
            {<<"token">>, Token, AccountData} ->
                Req1 = cowboy_req:set_resp_cookie(<<"server">>, Token, #{path => <<"/">>, max_age => 3600}, Req),
                cowboy_req:reply(200, #{}, AccountData, Req1);
            Json when is_binary(Json) -> Json;
            _Catch ->
                ?ERROR("_Catch:~p~nret:~p~ntrace:~p~n", [_Catch, Data, erlang:get_stacktrace()]),
                <<"{\"code\":0}">>
        end,
    if
        is_map(Response) -> Response;
        true ->
            cowboy_req:reply(200,
                #{<<"Access-Control-Allow-Origin">> => <<"*">>, <<"Access-Control-Allow-Methods">> => <<"GET,POST">>, <<"Content-Type">> => <<"application/json">>},
                Response, Req)
    end.


to_msg(ErrCode) -> <<"{\"code\":", (integer_to_binary(ErrCode))/binary, "}"/utf8>>.
to_msg(ErrCode, Msg) ->
    <<"{\"code\":", (integer_to_binary(ErrCode))/binary, ", \"msg\":\"", Msg/binary, "\"}"/utf8>>.