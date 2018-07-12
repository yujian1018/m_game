%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 10. 五月 2016 下午4:13
%%%-------------------------------------------------------------------
-module(im_file_proto).

-include("im_pub.hrl").

-export([handle_client/4]).


handle_client(Req, <<"upload">>, AppsId, Args) ->
    Iid = proplists:get_value(<<"i_id">>, Args),
    Token = proplists:get_value(<<"token">>, Args),
    case cache_token:get(AppsId, Iid, Token) of
        {error, Err} -> ?return_err(Err);
        _ ->
            PostVals = im_http:arg(Req),
            FileName = erl_hash:md5(PostVals),
            NewPath = "/var/www/file/" ++ FileName,
            file:write_file(NewPath, PostVals),
            NewFileUrl =
                case application:get_env(?im, file_url) of
                    {ok, FileUrl} -> FileUrl;
                    _ -> <<"http://test.dz.01cs.cc/">>
                end,
            Url = <<NewFileUrl/binary, "file/", (list_to_binary(FileName))/binary>>,
            jiffy:encode({[{<<"code">>, 200}, {<<"url">>, Url}]})
    end;


handle_client(_Req, ProtoId, _AppsId, Arg) ->
    ?ERROR("not found this path:~p...uid:~p...qs:~p~n", [ProtoId, _AppsId, Arg]),
    <<"">>.
