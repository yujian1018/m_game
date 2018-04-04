%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 十二月 2017 上午10:29
%%%-------------------------------------------------------------------
-module(sql_bulletin_board).

-export([
    sql_bulletin_board/0
]).


sql_bulletin_board() ->
    Now = erl_time:now_bin(),
    db_mysql:ea(<<"SELECT id, channel_id, s_times, e_times, icon, title, content FROM bulletin_board WHERE s_times <= ",
        Now/binary, " AND e_times > ",
        Now/binary, " AND op_state = 1 ORDER BY sort DESC;">>).
