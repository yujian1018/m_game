%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 13. 七月 2016 上午11:26
%%%-------------------------------------------------------------------
-module(erl_httpc).

-export([
    get/2, post/4, request/4,
    
    urlsafe_base64/1
]).

get(Url, Head) ->
    case httpc:request(get, {Url, Head}, [{timeout, 30000}], []) of
        {ok, {{_, 200, "OK"}, _Head, Response}} ->
            {ok, Response};
        _Err ->
            {error, _Err}
    end.


%% "application/x-www-form-urlencoded"
post(Url, Head, ContentType, Body) ->
    case httpc:request(post, {Url, Head, ContentType, Body}, [{timeout, 30000}], []) of
        {ok, {{_, 200, _}, _Head, Response}} ->
            {ok, Response};
        _Err ->
            {error, _Err}
    end.

request(_Method, _Request, _HTTPOptions, _Options, 3) -> {error, timeout};
request(Method, Request, HTTPOptions, Options, N) ->
    case httpc:request(Method, Request, HTTPOptions, Options) of
        {ok, Body} -> {ok, Body};
        _Err ->
            io:format("httpc_get error:~p~n", [_Err]),
            if
                N =:= 0 -> timer:sleep(1000);
                N =:= 1 -> timer:sleep(3000);
                N =:= 2 -> timer:sleep(5000)
            end,
            request(Method, Request, HTTPOptions, Options, N + 1)
    end.

request(Method, Request, HTTPOptions, Options) ->
    case request(Method, Request, HTTPOptions, Options, 0) of
        {ok, {{_, 200, "OK"}, _Head, Response}} ->
            {ok, Response};
        _Err ->
            {error, _Err}
    end.

encode_mime(Bin) when is_binary(Bin) ->
    <<<<(urlencode_digit(D))>> || <<D>> <= base64:encode(Bin)>>.

urlencode_digit($/) -> $_;
urlencode_digit($+) -> $-;
urlencode_digit(D) -> D.

urlsafe_base64(Bin) ->
    encode_mime(Bin).