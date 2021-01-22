%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 12. 十月 2017 下午5:48
%%%-------------------------------------------------------------------


%% [<<"uid">>,<<"int(11)">>,undefined,<<"NO">>,<<"PRI">>,undefined, <<"auto_increment">>,<<"select,insert,update,references">>,<<>>]
-record(tab_fields, {
    tab_name = <<>>,
    pool = <<>>,
    pri = [],%0:该表中只存在一条数据 1:该表中存在多条数据; 判断条件:有且只有uid作为主键
    fields = [],
    old_fields = []
}).


-record(field, {
    field,      %列名
    type,       %数据类型
    type_size,  %数据类型长度
    erl_type,   %转换成erlang的类型
    collation,  %编码
    is_null,    %是否为空
    key,        %索引
    default,    %默认值， 如果是undefined默认为<<>>
    extra,      %auto_increment
    privileges, %特权 select,insert,update,references
    comment     %注释
}).