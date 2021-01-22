%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十月 2017 上午11:39
%%%-------------------------------------------------------------------
-module(cache_tab_md5).

-include("cache_pub.hrl").


load_cache() ->
    [
        #cache_mate{
            name = ?cache_tab_md5,
            keypos = 1,
            priority = -1
        }
    ].