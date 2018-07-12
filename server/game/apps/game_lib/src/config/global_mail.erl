%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 04. 九月 2017 下午2:07
%%%-------------------------------------------------------------------
-module(global_mail).


-include_lib("cache/include/cache_mate.hrl").

-export([
    get_v/1
]).


-define(tab_name_1, global_mail).

-record(global_mail, {
    id,
    title,
    content,
    prize_id
}).


load_cache() ->
    [
        #cache_mate{
            name = ?tab_name_1,
            fields = record_info(fields, ?tab_name_1)
        }
    ].


get_v(Id) ->
    case ets:lookup(?tab_name_1, Id) of
        [] -> [];
        [Record] -> {Record#global_mail.title, Record#global_mail.content, Record#global_mail.prize_id}
    end.