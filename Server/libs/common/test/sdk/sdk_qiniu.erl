%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 22. 六月 2017 下午8:44
%%%-------------------------------------------------------------------
-module(sdk_qiniu).

-include("erl_pub.hrl").

-export([
    post/1,
    etag/1
]).


-define(AK, <<"111">>).
-define(SK, <<"DbL-222">>).

-define(FILE_URL, <<"http://otbyaomht.bkt.clouddn.com/">>).
-define(SCORE, <<"fk-dz">>).
-define(UPLOAD_URL, "http://up-z2.qiniu.com").

up_token() ->
    Deadline = erl_time:now() + 3600,
    Arg = <<"{\"scope\":\"", (?SCORE)/binary, "\",\"deadline\":", (integer_to_binary(Deadline))/binary, "}">>,
    Key = erl_httpc:urlsafe_base64(Arg),
    Sign = erl_httpc:urlsafe_base64(crypto:hmac(sha, ?SK, Key)),
    <<(?AK)/binary, ":", Sign/binary, ":", Key/binary>>.

etag(Content) ->
    Digest = crypto:hash(sha, Content),
    erl_httpc:urlsafe_base64(<<22, Digest/binary>>).

post(Content) ->
    UpToken = up_token(),
    Boundary = boundary(),
    Body = format_multipart_formdata(Boundary, UpToken, Content),
    ContentType = binary_to_list(<<"multipart/form-data; boundary=", Boundary/binary>>),
    Headers = [{"Content-Length", byte_size(Body)}],
    case erl_httpc:post(?UPLOAD_URL, Headers, ContentType, Body) of
        {ok, Json} ->
            {KeyList} = jiffy:decode(Json),
            case lists:keyfind(<<"key">>, 1, KeyList) of
                {_, Key} -> {ok, <<(?FILE_URL)/binary, Key/binary>>};
                _ ->
                    ?ERROR("post error:~p~n", [Json]),
                    error
            end;
        _Other ->
            ?ERROR("post error:~p~n", [_Other]),
            error
    end.

format_multipart_formdata(Boundary, Token, Content) ->
    <<"--", Boundary/binary, "\r\n",
        "Content-Disposition: form-data; name=\"token\"",
        "\r\n\r\n",
        Token/binary,
        "\r\n",
        "--", Boundary/binary, "\r\n",
        "Content-Disposition: form-data; name=\"file\"; filename=\"img\"",
        "\r\n",
        "Content-Type: application/octet-stream",
        "\r\n\r\n", Content/binary, "\r\n",
        "--", Boundary/binary, "--\r\n">>.

boundary() ->
    Unique = unique(16),
    <<"----------------------", Unique/binary>>.
unique(Size) -> unique(Size, <<>>).
unique(0, Acc) -> Acc;
unique(Size, Acc) ->
    Random = $a + rand:uniform($z - $a),
    unique(Size - 1, <<Acc/binary, Random>>).