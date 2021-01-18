%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 二月 2017 下午5:58
%%%-------------------------------------------------------------------

-include_lib("common/include/erl_pub.hrl").


-define(ETS_TAB_NODE, cache_server_version).
-define(ETS_TAB_NODE_ON, ets_mgr_nodes).

-record(cache_server_version, {
    s_node,
    s_name,
    url,
    port,
    s_type,
    s_version,
    status = 0, % 0:服务未启动 1:服务已启动
    count = 0,
    count_ex = []
}).