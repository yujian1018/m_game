%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 22. 七月 2016 下午5:20
%%%-------------------------------------------------------------------
-module(global_err_code).

-include_lib("cache/include/cache_mate.hrl").


-define(tab_name1, err_code_cn).
-define(tab_name2, err_code_en).
-define(tab_name3, err_code_ts).


-record(err_code_cn, {
    err_id,
    alert,
    language
}).


load_cache() ->
    [
        #cache_mate{
            name = ?tab_name1,
            record = #err_code_cn{},
            fields = record_info(fields, ?tab_name1)
        }
    ].

