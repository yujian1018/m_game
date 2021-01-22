%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% char            0-255byte           定长
%%% varchar         0-255byte           变长
%%% tinyblob        0-255byte           二进制
%%% tinytext        0-255byte           短文本
%%% blob            0-65535(64k)
%%% text            0-65535
%%% mediumblob      0-16777215(16M)
%%% mediumtext      0-16777215
%%% longblob        0-4294967295（4G）
%%% longtext        0-4294967295
%%%VARCHAR(M)
%%%说明：0 到M 字节长的可变长字符串。M 应该为1到255 之间的一个整数，或者自MySQL3.23 后为0 到255 之间的一个整数。存储时后跟的空格被去掉。存储时，大于M 个字符的串剪断为M 个字符。 允许的属性：B I N A RY 允许的长度：0 到M 字节
%%%缺省值：如果列可为NULL，则为NULL；如果列为NOT NULL，则为“” 存储需求：值的长度，加上1字节用来记录长度
%%%比较：不区分大小写（如果具有B I N A RY 属性，则区分大小写）

%%% Created : 15. 六月 2017 下午2:24
%%%-------------------------------------------------------------------
-module(mysql_char).

-export([
    in_type/1
]).

-define(ALL_TYPE, [
    <<"varchar">>, <<"tinyblob">>, <<"tinytext">>,
    <<"blob">>, <<"text">>,
    <<"mediumblob">>, <<"mediumtext">>,
    <<"longblob">>, <<"longtext">>,
    <<"char">>
]).

in_type(DataType) ->
    in_type(?ALL_TYPE, DataType).

in_type([], _) -> {binary, 0};
in_type([Type | Types], DataType) ->
    case binary:match(DataType, Type) of
        {0, Len} ->
            {binary, binary:part(DataType, Len + 1, byte_size(DataType) - Len - 2)};
        _ ->
            in_type(Types, DataType)
    end.

