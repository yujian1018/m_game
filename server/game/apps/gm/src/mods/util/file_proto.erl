%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 五月 2016 下午4:13
%%%-------------------------------------------------------------------
-module(file_proto).

-include("gm_pub.hrl").

-export([handle_client/3]).

handle_client(?UPLOAD, #{pms_role_id:=_RoleId}, [{_Key, ImgBase64Ex}]) ->
    ImgBase64 =
        case ImgBase64Ex of
            <<"data:image/jpeg;base64,", ImgBase64Bin/binary>> ->
                ImgBase64Bin;
            <<"data:image/jpg;base64,", ImgBase64Bin/binary>> ->
                ImgBase64Bin;
            <<"data:image/png;base64,", ImgBase64Bin/binary>> ->
                ImgBase64Bin;
            _ ->
                ?return_err(?ERR_ARG_ERROR)
        end,
    ImgBin = base64:decode(ImgBase64),
    case sdk_qiniu:post(ImgBin) of
        {ok, Url} ->
            Url;
        _ ->
            ?return_err(?ERR_SERVER_CRASH)
    end;

handle_client(ProtoId, State, Qs) ->
    ?ERROR("not found this path:~p...uid:~p...qs:~p~n", [ProtoId, State, Qs]),
    <<"">>.
