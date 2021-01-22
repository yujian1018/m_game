%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 21. 三月 2016 下午5:27
%%%-------------------------------------------------------------------


-record(proto, {
    index = 3,
    name,
    proto,
    client,
    server,
    anno
}).


-record(proto_item, {
    index = 3,
    k,
    v,
    anno
}).


-record(all_proto, {
    index = 3,
    options,
    list,
    anno
}).

-record(enum, {
    index = 3,
    name,
    list,
    anno
}).

-record(enum_item, {
    index = 3,
    k,
    v,
    v2,
    anno
}).


-record(line_constant, {
    index = 3,
    k,
    k2,
    v,
    v2,
    anno
}).

-record(atom_constant, {
    index = 3,
    k,
    v,
    anno
}).

-record(atom_constant_2, {
    index = 3,
    k,
    v,
    anno
}).