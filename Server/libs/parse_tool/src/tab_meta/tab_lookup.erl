%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% PRI主键约束；
%%% UNI唯一约束；
%%% MUL可以重复。
%%%
%%% Created : 12. 十月 2017 下午4:30
%%%-------------------------------------------------------------------
-module(tab_lookup).

-include("tab_meta.hrl").

-export([
    tab_fields/1
]).


tab_fields(Databases) ->
    Fun =
        fun({Pool, Database}) ->
            AllTabNames = db_mysql:execute(Pool, <<"select TABLE_NAME from information_schema.`TABLES` where TABLE_SCHEMA = '",
                (list_to_binary(Database))/binary, "';">>),
            AllFields = db_mysql:execute(Pool, [<<"SHOW FULL FIELDS  FROM `", TabName/binary, "`;">> || [TabName] <- AllTabNames]),
            tab(Pool, lists:zip(AllTabNames, AllFields))
        end,
    lists:append(lists:map(Fun, Databases)).


tab(Pool, AllTabFields) ->
    lists:map(
        fun({[TabName], Fields}) ->
            {NewPri, NewFields} =
                lists:foldl(
                    fun([Field, Type, _Encode, IsNull, Index, Default, _Extra, _Privileges, _Comment], {PriAcc, FiledAcc}) ->
                        {DataType, TypeSize} = check_type(Type),
                        %% 默认值 int，binary
                        NewDefault = if
%%                                         Default =:= undefined andalso DataType =:= int -> 0;
                                         Default =:= undefined -> <<>>;
%%                                         is_binary(Default) andalso DataType =:= int ->
%%                                             binary_to_integer(Default);
                                         is_binary(Default) -> Default
                                     end,
                        %% 主键提出来
                        NewPriAcc = if
                                        Index =:= <<"PRI">> -> [Field | PriAcc];
                                        true -> PriAcc
                                    end,
                        {NewPriAcc, [#field{field = Field, type = Type, erl_type = DataType,
                            type_size = TypeSize, collation = _Encode,
                            is_null = IsNull, key = Index, default = NewDefault,
                            extra = _Extra, privileges = _Privileges, comment = _Comment} | FiledAcc]}
                    end,
                    {[], []},
                    Fields),
            #tab_fields{tab_name = TabName, pool = Pool, pri = lists:reverse(NewPri), fields = lists:reverse(NewFields), old_fields = Fields}
        end, AllTabFields).


%% 目前只识别常用的格式
%%int -2^31 (-2,147,483,648) 到 2^31 - 1 (2,147,483,647) 的整型数据
-define(ALL_TYPE, [<<"int">>, <<"char">>, <<"varchar">>, <<"binary">>]).
-spec check_type(DataType :: binary()) -> {int, integer()} | {binary, integer()}.
check_type(DataType) ->
    case binary:match(DataType, <<"int">>) of
        nomatch ->
            check_type(?ALL_TYPE, DataType);
        _ ->
            {int, 0}
    end.

check_type([], _) -> {binary, null};
check_type([Type | Types], DataType) ->
    case binary:match(DataType, Type) of
        {0, Len} ->
            {binary, binary:part(DataType, Len + 1, byte_size(DataType) - Len - 2)};
        _ ->
            check_type(Types, DataType)
    end.