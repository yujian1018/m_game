%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 设计错误，小数据量可以接受，目前没有好想法
%%% Created : 08. 十二月 2015 上午11:26
%%%-------------------------------------------------------------------
-module(cache).

-define(no_cache_behaviour, 1).
-include("cache_pub.hrl").


-export([
    all_data/1,
    all_config_md5/0,
    lookup/2,
    insert/2, insert_new/2,
    delete/2]).


all_data(Tab) ->
    ets:lookup(Tab, table_data).


all_config_md5() ->
    case ets:lookup(?cache_tab_md5, all_config) of
        [] -> [];
        [{all_config, Data}] -> Data
    end.


lookup(Tab, Key) ->
    case catch ets:lookup(Tab, Key) of
        [] -> [];
        {'EXIT', _} -> [];
        Record -> Record
    end.


insert(Tab, Record) ->
    case catch ets:insert(Tab, Record) of
        [] -> [];
        {'EXIT', _} -> [];
        Ret -> Ret
    end.


insert_new(Tab, Record) ->
    case catch ets:insert_new(Tab, Record) of
        [] -> [];
        {'EXIT', _} -> [];
        Ret -> Ret
    end.


delete(Tab, Key) ->
    case catch ets:delete(Tab, Key) of
        [] -> [];
        {'EXIT', _} -> [];
        Ret -> Ret
    end.
