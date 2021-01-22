%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc  ets表中all_data不能超过5w条数据
%%% Created : 26. 十一月 2015 下午5:46
%%%-------------------------------------------------------------------
-module(aof_mysql).

-define(no_cache_behaviour, 1).
-include("cache_pub.hrl").


-define(PAGE_SIZE, 50000).

-export([
    load_file/1,
    cache_data/4
]).

load_file(Config) ->
    Tab = atom_to_binary(Config#cache_mate.name, unicode),
    Sel =
        lists:foldl(fun(Field, SelectAcc) ->
            FieldBin = atom_to_binary(Field, unicode),
            if
                SelectAcc =:= <<>> -> <<"`", FieldBin/binary, "`">>;
                true -> <<SelectAcc/binary, ",`", FieldBin/binary, "`">>
            end
                    end,
            <<>>,
            Config#cache_mate.fields),
    Md5Context = erlang:md5_init(),
    {Md5, FieldRecords, AllData} = tab(Config, Tab, Sel, 0, Md5Context),
    cache_behaviour:cache_data(Config, Md5, FieldRecords, AllData).


tab(Config, Tab, Sel, N, Md5Context) ->
    SIndex =
        if
            N >= 1 -> N * ?PAGE_SIZE + 1;
            true -> 0
        end,
    Sql =
        if
            Config#cache_mate.store =:= mnesia ->
                <<"SELECT '';
            select ", Sel/binary, " from ", Tab/binary, " limit ", (integer_to_binary(SIndex))/binary, ", ", (integer_to_binary(?PAGE_SIZE))/binary, ";">>;
            true ->
                <<"select * from ", Tab/binary, " limit ", (integer_to_binary(SIndex))/binary, ", ", (integer_to_binary(?PAGE_SIZE))/binary, ";
          select ", Sel/binary, " from ", Tab/binary, " limit ", (integer_to_binary(SIndex))/binary, ", ", (integer_to_binary(?PAGE_SIZE))/binary, ";">>
        end,
    case db_mysql:execute(Config#cache_mate.mysql_pool, Sql) of
        [AllData, FieldData] ->
            Len = length(FieldData),
            {NewMd5Context, FieldRecords} = cache_data(Config, AllData, Md5Context, FieldData),
            if
                Len < ?PAGE_SIZE ->
                    {erlang:md5_final(NewMd5Context), FieldRecords, AllData};
                true ->
                    tab(Config, Tab, Sel, N + 1, NewMd5Context)
            end;
        _ -> ok
    end.


cache_data(Config, AllData, Md5Context, Data) ->
    Fun =
        fun(Item, Acc) ->
            TabRecord = list_to_tuple([Config#cache_mate.name | Item]),
            TabRecord2 =
                if
                    is_function(Config#cache_mate.rewrite) -> (Config#cache_mate.rewrite)(TabRecord);
                    true -> TabRecord
                end,
            TabRecord3 =
                if
                    is_function(Config#cache_mate.verify) -> (Config#cache_mate.verify)(TabRecord2);
                    true -> TabRecord2
                end,
            if
                is_tuple(TabRecord3) ->
                    cache_behaviour:set(Config, [TabRecord3]),
                    [TabRecord3 | Acc];
                is_list(TabRecord3) ->
                    cache_behaviour:set(Config, TabRecord3),
                    TabRecord3 ++ Acc;
                true ->
                    Acc
            end
        end,
    {erlang:md5_update(Md5Context, term_to_binary(AllData)), lists:foldl(Fun, [], Data)}.