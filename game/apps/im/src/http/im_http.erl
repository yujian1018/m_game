%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 28. 六月 2017 上午10:09
%%%-------------------------------------------------------------------
-module(im_http).


-include("im_pub.hrl").

-export([init/2]).

-export([arg/1]).

init(Req, Opts) ->
    Ret =
        case cowboy_req:path_info(Req) of
            [Mod, Proto] ->
                ?INFO("111:~p~n", [[Mod, Proto, get_arg(Req)]]),
                catch dispath_handler(Req, Mod, Proto, get_arg(Req));
            [<<"favicon.ico">>] ->
                <<"data:image/gif;base64,R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==">>;
            _Other ->
                ?INFO("path:~p", [_Other]),
                {throw, ?ERR_ARG_ERROR}
        end,
    ?INFO("222:~p~n", [Ret]),
    {ok, response_json(Req, Ret), Opts}.

get_arg(Req) ->
    cowboy_req:parse_qs(Req).

arg(Req) ->
    case cowboy_req:has_body(Req) of
        true ->
            %% 需要区分这两种情况, 1 正常情况， 2 表单上传
            ContentLen = cowboy_req:header(<<"content-length">>, Req),
            if
                ContentLen > 1048576 ->
                    ?return_err(?ERR_EXCEED_LIMIT);
                true ->
                    ContentType = cowboy_req:header(<<"content-type">>, Req),
                    case binary:match(ContentType, <<"multipart/form-data">>) of
                        nomatch ->
                            {ok, PostVals, _Req2} = cowboy_req:read_body(Req),
                            PostVals;
                        _ ->
                            {Result, _Req2} = acc_multipart(Req, []),
                            Result
                    end
            end;
        false ->
            <<>>
    end.

acc_multipart(Req, Acc) ->
    case cowboy_req:read_part(Req) of
        {ok, Headers, Req2} ->
            {ok, Body, Req3} = cowboy_req:read_part_body(Req2),
            acc_multipart(Req3, [{Headers, Body} | Acc]);
        {done, Req2} ->
            {lists:reverse(Acc), Req2}
    end.


response_json(Req, Ret) ->
    Body =
        case Ret of
            {throw, ErrCode} -> to_msg(ErrCode);
            {'EXIT', _Exit} ->
                ?ERROR("EXIT:~p~n", [_Exit]),
                to_msg(?ERR_SERVER_CRASH);
            BodyBin when is_binary(BodyBin) -> BodyBin
        end,
    cowboy_req:reply(200, #{
        <<"Access-Control-Allow-Origin">> => <<"*">>,
        <<"Access-Control-Allow-Methods">> => <<"GET,POST">>,
        <<"Content-Type">> => <<"application/json">>}, Body, Req).


dispath_handler(Req, ModId, ProtoId, Arg) ->
    AppsId = sign(Arg),
    if
        ModId =:= <<"user">> -> im_user_proto:handle_client(Req, ProtoId, AppsId, Arg);
        ModId =:= <<"chat">> -> im_chat_proto:handle_client(Req, ProtoId, AppsId, Arg);
        ModId =:= <<"file">> -> im_file_proto:handle_client(Req, ProtoId, AppsId, Arg);
        true -> ok
    end.


sign(Arg) ->
    Sign = proplists:get_value(<<"sign">>, Arg),
    AppId = proplists:get_value(<<"app_id">>, Arg),
    {AppsId, AppSecret} = load_apps:get_app(AppId),
    case list_to_binary(erl_hash:md5(<<AppId/binary, ".", AppSecret/binary>>)) of
        Sign -> integer_to_binary(AppsId);
        _ -> ?return_err(?ERR_BAD_SIGN)
    end.


to_msg(Err) ->
    case Err of
        {ErrCode, ErrMsg} ->
            <<"{\"code\":", (integer_to_binary(ErrCode))/binary, ", \"msg\":\"", ErrMsg/binary, "\"}"/utf8>>;
        ErrCode ->
            NewMsg =
                case err_code:err_code(ErrCode) of
                    <<>> -> err_code_im:err_code(ErrCode);
                    ErrMsg -> ErrMsg
                end,
            <<"{\"code\":", (integer_to_binary(ErrCode))/binary, ", \"msg\":\"", NewMsg/binary, "\"}"/utf8>>
    end.