%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 14. 六月 2017 下午4:46
%%%-------------------------------------------------------------------

-define(NEW_TABLE(TabName, Cache), mnesia:create_table(TabName, [{Cache, [node()]}, {attributes, record_info(fields, TabName)}])).
-define(NEW_TABLE(TabName, Cache, TabType), mnesia:create_table(TabName, [{Cache, [node()]}, {type, TabType}, {attributes, record_info(fields, TabName)}])).
