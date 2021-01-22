%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 图灵机器人
%%%
%%% Created : 11. 六月 2018 下午4:27
%%%-------------------------------------------------------------------
-module(sdk_tuling).

-include("erl_pub.hrl").

-export([
    httpc/1
]).

-define(URL, "http://openapi.tuling123.com/openapi/api/v2").
-define(APP_KEY, <<"e0753dc023834419a6541c1e2da8ec3e">>).

httpc(Text) ->
    Json = <<"{\"reqType\":0,\"perception\": {\"inputText\": {\"text\": \"",
        Text/binary, "\"}},\"userInfo\": {\"apiKey\": \"",
        (?APP_KEY)/binary, "\",\"userId\": \"1\"}}">>,
    case erl_httpc:post(?URL, [], "application/x-www-form-urlencoded", Json) of
        {ok, L} ->
            case lists:keyfind(<<"results">>, 1, ?decode(list_to_binary(L))) of
                {_, [{L2}]} ->
                    case lists:keyfind(<<"values">>, 1, L2) of
                        {_, {[{<<"text">>, Answer}]}} -> Answer;
                        _ -> <<>>
                    end;
                _ -> <<>>
            end;
        _ ->
            <<>>
    end.

