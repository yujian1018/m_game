%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 18. 一月 2018 下午4:29
%%%-------------------------------------------------------------------
-module(cache_token).


-include_lib("cache/include/cache_mate.hrl").
-include("im_pub.hrl").

-export([
    get/3,
    set/2
]).

-define(tab_name_1, cache_token).

-record(cache_token, {
    key,
    token,
    c_times
}).

load_cache() ->
    [
        #cache_mate{
            name = ?tab_name_1,
            type = mysql,
            fields = record_info(fields, ?tab_name_1),
            all = [#cache_token.key],
            group = []
        }
    ].


set(AppsId, Iid) ->
    Token = erl_bin:uuid_bin(),
    ets:insert(?tab_name_1, #cache_token{key = {AppsId, Iid}, token = Token, c_times = erl_time:now()}),
    Token.

get(AppsId, Iid, Token) ->
    case ets:lookup(?tab_name_1, {AppsId, Iid}) of
        [Record] ->
            Now = erl_time:now(),
            CTimes = Record#cache_token.c_times,
            if
                Record#cache_token.token =:= Token andalso (Now - CTimes) >= 0 andalso (Now - CTimes) < 180 ->
                    ets:delete(?tab_name_1, {AppsId, Iid}),
                    ok;
                true -> {error, ?ERR_LOGIN_TOKNE_OUTDATE}
            end;
        _ ->
            {error, ?ERR_LOGIN_TOKNE_OUTDATE}
    end.