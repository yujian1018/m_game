%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% tinyint     1byte   (-128,127)              (0, 255)        bit|bool
%%% smallint    2byte   (-32768,32767)          (0, 65535)
%%% mediumint   3byte   (-8388608,8388607)      (0,16777215)
%%% int         4byte   (-2,147,483,648,2,147,483,647)          integer
%%% bigint      8byte   ()
%%% float       4byte   单精度浮点数 取值范围：最小非零值为±1.75494351E -38; 最大非零值为±3.402823466E + 38
%%% 缺省值：如果列可为NULL，则为NULL；如果列为NOT NULL，则为0 存储需求：4 字节
%%% double      8byte   双精度  取值范围：最小非零值为±2 . 2 2 5 07 3 8 5 8 5 07 2 0 14 E -308; 最大非零值为±1。7 9 7 6 9 3 13 -4 8 6 2 3 15 7 E + 3 0 8
%%% 缺省值：如果列可为NULL，则为NULL；如果列为NOT NULL，则为0 存储需求：8 字
%%%
%%% Created : 15. 六月 2017 下午2:24
%%%-------------------------------------------------------------------
-module(mysql_int).

-export([
    in_type/1
]).

-define(ALL_TYPE, [<<"tinyint">>, <<"smallint">>, <<"bigint">>, <<"int">>]).



in_type(DataType) ->
    in_type(?ALL_TYPE, DataType).

in_type([], _) -> {int, 0};
in_type([Type | Types], DataType) ->
    case binary:match(DataType, Type) of
        nomatch ->
            in_type(Types, DataType);
        _ -> {int, 0}
    end.
