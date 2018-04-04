%% Feel free to use, reuse and abuse the code in this file.

-module(file_proto).

-include("http_pub.hrl").

-export([handle_client/3]).


handle_client(Req, ?UPLOAD, _GetArg) ->
%%    ?INFO("000:~p~n", [[_GetArg, cowboy_req:method(Req), cowboy_req:body_length(Req), cowboy_req:has_body(Req)]]),
    {ok, PostVals, _Req2} = cowboy_req:read_body(Req),
    FileName = erl_hash:md5(PostVals),
    NewPath = "/var/www/file/" ++ FileName,
    file:write_file(NewPath, PostVals),
    NewFileUrl =
        case application:get_env(?http, file_url) of
            {ok, FileUrl} -> FileUrl;
            _ -> <<"http://test.dz.01cs.cc/">>
        end,
    Url = <<NewFileUrl/binary, "file/", (list_to_binary(FileName))/binary>>,
    jiffy:encode({[{<<"code">>, 200}, {<<"url">>, Url}]});


handle_client(Req, ?UPLOAD_AOF, _GetArg) ->
    Ret =
        case cowboy_req:has_body(Req) of
            true ->
                %% 需要区分这两种情况, 1 正常情况， 2 表单上传
                ContentType =
                    case cowboy_req:header(<<"content-type">>, Req) of
                        undefined -> <<>>;
                        ContentType1 -> ContentType1
                    end,
                case binary:match(ContentType, <<"multipart/form-data">>) of
                    nomatch ->
                        {ok, PostVals, _Req2} = cowboy_req:read_body(Req),
                        PostVals;
                    _ ->
                        {Result, _Req2} = acc_multipart(Req, []),
                        Result
                end;
            false ->
                []
        end,
    ImgBase =
        case Ret of
            [] -> ?return_err(?ERR_ARG_ERROR);
            [_, {_K, V}] ->
                V;
            [{_K, V}] ->
                V;
            Ret ->
                Ret
        end,
    
    ImgBin =
        case ImgBase of
            <<"data:image/jpeg;base64,", ImgBase64Bin/binary>> ->
                ImgBase64Bin;
            <<"data:image/jpg;base64,", ImgBase64Bin/binary>> ->
                ImgBase64Bin;
            <<"data:image/png;base64,", ImgBase64Bin/binary>> ->
                ImgBase64Bin;
            ImgBase64Bin ->
                ImgBase64Bin
        end,
    case sdk_qiniu:post(ImgBin) of
        {ok, Url} ->
            jiffy:encode({[{<<"code">>, 200}, {<<"url">>, Url}]});
        _ ->
            ?return_err(?ERR_ARG_ERROR)
    end;

handle_client(_Req, Cmd, Arg) ->
    ?DEBUG("handle_info no match ProtoId:~p...arg:~p~n", [Cmd, Arg]),
    ?return_err(?ERR_ARG_ERROR).


acc_multipart(Req, Acc) ->
    case cowboy_req:read_part(Req) of
        {ok, Headers, Req2} ->
            {ok, Body, Req3} = cowboy_req:read_part_body(Req2),
            acc_multipart(Req3, [{Headers, Body} | Acc]);
        {done, Req2} ->
            {lists:reverse(Acc), Req2}
    end.