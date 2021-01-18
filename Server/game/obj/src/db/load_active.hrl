%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 15. 九月 2017 下午2:41
%%%-------------------------------------------------------------------

-define(tab_name, player_active).
-define(tab_last_name, active_20170915).


-record(active, {
    uid,
    items = []
}).


-record(active_20170915, {
    active_id = 0,
    progress = 0,
    prize = [],
    op = 0  %0:表示不变 1:新增 2:删除 3:更新
}).