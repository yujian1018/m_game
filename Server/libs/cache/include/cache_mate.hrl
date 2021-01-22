%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十月 2017 下午12:25
%%%-------------------------------------------------------------------

-define(cache_behaviour, cache_behaviour).

-define(cache_tab_md5, cache_tab_md5).

-record(cache_mate, {
    store           = ets   :: ets | mnesia,
    name            = none  :: atom(),
    type            = set   :: set|bag,
    keypos          = 2     :: integer(),

    index           = [],
    cache_copies    = disc_copies :: disc_copies|disc_only_copies|ram_copies,
    fields          = none  :: list(),

    db_type         = mysql :: atom(), %文件类型， mysql、file
    mysql_pool      = pool_static_1 :: atom(),

    rewrite                 :: fun(),    %数据格式重写
    verify                  :: fun(),  %fun() -> boolean().

    all             = [2]   :: [integer()], %默认把该表的所有key值维护去来，用来热更数据时使用
    group           = []    :: [integer()],   %

    priority        = 1     ::integer(),       %数据加载优先级,越小越优先加载
    callback                ::fun()     %回调函数
}).



-ifndef(no_cache_behaviour).

-behaviour(?cache_behaviour).
-export([load_cache/0]).

-endif.
