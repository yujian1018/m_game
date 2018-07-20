%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 玩家模块，行为规范
%%%
%%% @end
%%% Created : 24. 六月 2016 下午2:55
%%%-------------------------------------------------------------------

-behaviour(player_behaviour).

-export([
    load_data/1,
    online/1,
    online_send_data/1,
    save_data/1,
    terminate/1,
    handler_msg/4,
    handler_call/2
]).
