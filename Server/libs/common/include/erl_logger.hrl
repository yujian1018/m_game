%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 26. 四月 2016 下午4:55
%%%-------------------------------------------------------------------

%% \e[背景色;前景色;高亮m
%%字体背景色 40:黑色 41:红色 42:绿色 43:黄色 44:蓝色 45:紫色 46:墨绿色 47:白色
%%字体颜色 0:重置 30:黑色 31:红色 32:绿色 33:黄色 34:蓝色 35:紫色 36:墨绿 37:浅灰 38~39:白色
%%效果代码：1:高亮  2:加下划线  5:闪烁  7:背景取反 2J:清屏


%% R16 suport color term
-define(color_none, "\e[m").
-define(color_black, "\e[0;30m").
-define(color_red, "\e[0;31;1m").
-define(color_green, "\e[0;32m").
-define(color_yellow, "\e[0;33;1m").
-define(color_blue, "\e[0;34m").
-define(color_purple, "\e[0;35m").
-define(color_cyan, "\e[0;36m").
-define(color_white, "\e[0;37m").



-ifdef(prod).
    -define(LOGGER_INIT, logger:set_primary_config(level, info)).
-else.
    -define(LOGGER_INIT, logger:set_primary_config(level, debug)).
-endif.

-ifdef(linux).
    -define(DEBUG(MSG),         logger:debug("\e[0;35m[DEBUG] ~p [~s:~b ~w]~n"  MSG"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self()])).
    -define(DEBUG(FMT, ARGS),   logger:debug("\e[0;35m[DEBUG] ~p [~s:~b ~w]~n"  FMT"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -define(INFO(MSG),          logger:info("\e[0;32m[INFO] ~p [~s:~b ~w]~n"  MSG"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self()])).
    -define(INFO(FMT, ARGS),    logger:info("\e[0;32m[INFO] ~p [~s:~b ~w]~n"  FMT"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -define(NOTICE(MSG),        logger:notice("\e[0;34m[NOTICE] ~p [~s:~b ~w]~n"  MSG"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self()])).
    -define(NOTICE(FMT, ARGS),  logger:notice("\e[0;34m[NOTICE] ~p [~s:~b ~w]~n"  FMT"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -ifdef(prod).
        -define(WARN(MSG),          logger:warning("[WARN] ~p [~s:~b ~w]~n"  MSG"~n~n", [calendar:local_time(), ?FILE, ?LINE, self()])).
        -define(WARN(FMT, ARGS),    logger:warning("[WARN] ~p [~s:~b ~w]~n"  FMT"~n~n", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
        -define(ERROR(MSG),         logger:error("[ERROR] ~p [~s:~b ~w]~n"  MSG"~n~n", [calendar:local_time(), ?FILE, ?LINE, self()])).
        -define(ERROR(FMT, ARGS),   logger:error("[ERROR] ~p [~s:~b ~w]~n"  FMT"~n~n", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -else.
        -define(WARN(MSG),          logger:warning("\e[0;33;1m[WARN] ~p [~s:~b ~w]~n"  MSG"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self()])).
        -define(WARN(FMT, ARGS),    logger:warning("\e[0;33;1m[WARN] ~p [~s:~b ~w]~n"  FMT"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
        -define(ERROR(MSG),         logger:error("\e[0;31;1m[ERROR] ~p [~s:~b ~w]~n"  MSG"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self()])).
        -define(ERROR(FMT, ARGS),   logger:error("\e[0;31;1m[ERROR] ~p [~s:~b ~w]~n"  FMT"~n\e[0m", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -endif.

-else.

    -define(DEBUG(MSG),         io:format("[DEBUG] ~p [~s:~b ~w]~n"  MSG"~n", [calendar:local_time(), ?FILE, ?LINE, self()])).
    -define(DEBUG(FMT, ARGS),   io:format("[DEBUG] ~p [~s:~b ~w]~n"  FMT"~n", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -define(INFO(MSG),          io:format("[INFO] ~p [~s:~b ~w]~n"  MSG"~n", [calendar:local_time(), ?FILE, ?LINE, self()])).
    -define(INFO(FMT, ARGS),    io:format("[INFO] ~p [~s:~b ~w]~n"  FMT"~n", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -define(NOTICE(MSG),        io:format("[NOTICE] ~p [~s:~b ~w]~n"  MSG"~n", [calendar:local_time(), ?FILE, ?LINE, self()])).
    -define(NOTICE(FMT, ARGS),  io:format("[NOTICE] ~p [~s:~b ~w]~n"  FMT"~n", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -define(WARN(MSG),          io:format("[WARN] ~p [~s:~b ~w]~n"  MSG"~n", [calendar:local_time(), ?FILE, ?LINE, self()])).
    -define(WARN(FMT, ARGS),    io:format("[WARN] ~p [~s:~b ~w]~n"  FMT"~n", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).
    -define(ERROR(MSG),         io:format("[ERROR] ~p [~s:~b ~w]~n"  MSG"~n", [calendar:local_time(), ?FILE, ?LINE, self()])).
    -define(ERROR(FMT, ARGS),   io:format("[ERROR] ~p [~s:~b ~w]~n" FMT"~n", [calendar:local_time(), ?FILE, ?LINE, self() | ARGS])).

-endif.
