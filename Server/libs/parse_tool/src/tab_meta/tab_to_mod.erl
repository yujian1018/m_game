%#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -I include/
%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%   emysql 返回值目前发现只有两种类型 1.int 2.binary
%%%         PRI主键约束；
%%%         UNI唯一约束；
%%%         MUL可以重复。
%%%
%%% select  1.根据主键/联合主键查
%%%         2.组装select条件查询（返回100条匹配的数据）
%%%
%%% 复杂查询自己写sql语句
%%%
%%%
%%% Created : 16. 五月 2016 上午11:35
%%%-------------------------------------------------------------------
-module(tab_to_mod).

-export([
    main/0
]).

-include("tab_meta.hrl").


main() ->
    crypto:start(),
    emysql:start(),
    {ok, Pools} = application:get_env(emysql, pools),
    
    Fun =
        fun({Pool, Config}, Acc) ->
            Key =
                case string:tokens(atom_to_list(Pool), "_") of
                    [H1, H2, _H3] -> string:join([H1, H2], "_");
                    _R -> string:join(_R, "_")
                end,
            case lists:keyfind(Key, 1, Acc) of
                false ->
                    {_, Database} = lists:keyfind(database, 1, Config),
                    [{Pool, Database} | Acc];
                _ -> Acc
            end
        end,
    case lists:foldl(Fun, [], Pools) of
        [] -> erlang:throw("no emysql .conf");
        DBPools ->
            file:make_dir("./src/auto/mysql"),
            AllRecord = lists:map(
                fun(I) ->
                    put(pool, I#tab_fields.pool),
                    TabName = I#tab_fields.tab_name,
                    {Data, Hrl} = to_erl(TabName, I#tab_fields.old_fields, I#tab_fields.fields),
                    file:write_file(<<"./src/auto/mysql/mysql_", TabName/binary, ".erl">>, Data),
                    Hrl
                end, tab_lookup:tab_fields(DBPools)),
            file:write_file(<<"./src/auto/mysql/mysql_tab_record.hrl">>, AllRecord)
    end.


to_erl(TableName, OldFields, Fields) ->
    ToRecord = [{Field#field.field, Field#field.default, Field#field.comment} || Field <- Fields],
    ToInsert = [{Field#field.field, Field#field.default, Field#field.comment} || Field <- Fields, Field#field.extra =/= <<"auto_increment">>],
    PRIList = [{Field, ErlType} || #field{field = Field, erl_type = ErlType, key = Key} <- Fields, Key =:= <<"PRI">>],
    OtherList = [{Field, Default} || #field{field = Field, key = Key, default = Default} <- Fields, Key =/= <<"PRI">> andalso Key =/= <<"MUL">> andalso Key =/= <<"UNI">>],
    FieldsRecord = [{K, DataType, TypeSize, IsNull, Default} || #field{field = K, erl_type = DataType, type_size = TypeSize, is_null = IsNull, default = Default} <- Fields],
    {
        [
            tab_to_mod_meta:to_module(TableName),
            tab_to_mod_meta:to_field(OldFields),
            tab_to_mod_meta:to_insert(TableName, ToInsert),
            tab_to_mod_meta:to_delete(TableName, PRIList),
            tab_to_mod_meta:to_update(TableName, PRIList, OtherList, ToRecord),
            tab_to_mod_meta:to_lookup(TableName, ToRecord, PRIList, OtherList),
            tab_to_mod_meta:to_select(TableName, ToRecord),
            tab_to_mod_meta:to_validate(),
            tab_to_mod_meta:to_validate(FieldsRecord),
            tab_to_mod_meta:to_default(TableName, [{Field#field.field, Field#field.erl_type, Field#field.default, Field#field.comment} || Field <- Fields])
        ],
        tab_to_mod_meta:to_record(TableName, ToRecord)
    }.
