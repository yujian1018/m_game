%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% datetime        格式：'YYYY-MM-DD HH:MM:SS'，范围：'1000-01-01 00:00:00'到'9999-12-31 23:59:59'
%%% date            格式：'YYYY-MM-DD'，范围：'1000-01-01'到'9999-12-31'
%%% timestamp       格式：'YYYYMMDDHHMMSS'、'YYMMDDHHMMSS'、'YYYYMMDD'、'YYMMDD'，范围：'1970-01-01 00:00:00'到'2037-01-01 00:00:00'
%%% time            格式：'HH:MM:SS'
%%% year            格式：'YYYY，范围：'1901'到'2155'
%%% Created : 15. 六月 2017 下午2:25
%%%-------------------------------------------------------------------
-module(mysql_date).

-export([
    in_type/1
]).

-define(ALL_TYPE, [
    <<"datetime">>, <<"date">>, <<"timestamp">>,
    <<"time">>, <<"year">>
]).

in_type(DataType) ->
    in_type(?ALL_TYPE, DataType).

in_type([], _) -> {date, 0};
in_type([Type | Types], DataType) ->
    case binary:match(DataType, Type) of
        {0, Len} ->
            {date, binary:part(DataType, Len + 1, byte_size(DataType) - Len - 2)};
        _ ->
            in_type(Types, DataType)
    end.
