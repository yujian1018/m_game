%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 17. 一月 2019 下午3:25
%%%-------------------------------------------------------------------
-module(t_zlib).

-export([
    t/0
]).

-define(MAX_COUNT, 100).


t() ->
    inets:start(),
    ssl:start(),
    t(1).

t(?MAX_COUNT) -> ok;
t(Index) ->
    io:format("Index:~p~n", [Index]),
    IndexStr = integer_to_list(Index),
    case storage_1:read("/media/yj/DOC/project/baike", "https://baike.baidu.com/view/" ++ IndexStr ++ ".htm") of
        {ok, Bin} ->
%%    case httpc:request(get, {"http://www.360baike.cn/html/wiki/doc-view-" ++ IndexStr ++ ".html", []}, [{timeout, 30000}], []) of
%%        {ok, {{_, 200, "OK"}, _Head, Bin}} ->
            Bin;
%%            zlib:compress(Bin);
%%            zlib:zip(Bin);
        _Err ->
            {error, _Err}
    end,
    t(Index + 1).