%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 30. 五月 2018 下午3:20
%%%-------------------------------------------------------------------


-define(pool_account_1, pool_account_1).
-define(pool_dynamic_1, pool_dynamic_1).
-define(pool_static_1, pool_static_1).
-define(pool_log_1, pool_log_1).
-define(pool_gm_1, pool_gm_1).
-define(pool_redis_1, pool_redis_1).


-define(mnesia_new(TabName, CacheCopies, Fields), mnesia:create_table(TabName, [{CacheCopies, [node()]}, {attributes, Fields}])).
-define(mnesia_new(TabName, CacheCopies, Type, Fields, Indexs), mnesia:create_table(TabName, [{CacheCopies, [node()]}, {type, Type}, {attributes, Fields}, {index, Indexs}])).


-define(ets_new(TabName, Pos), ets:new(TabName, [public, named_table, {keypos, Pos}, {read_concurrency, true}])).
-define(ets_new(TabName, Pos, TabType), ets:new(TabName, [public, named_table, TabType, {keypos, Pos}, {read_concurrency, true}])).