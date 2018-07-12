%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 九月 2017 下午2:57
%%%-------------------------------------------------------------------

-include_lib("common/include/erl_pub.hrl").


%% You can receive the redeemable bonus now
%%You haven't received the roulette reward
%% You haven't received the reward of  monthly vip card

-define(PUSH_MSG_1, <<"您的救济金奖励已经可以领取了!"/utf8>>).
-define(PUSH_MSG_1_EN, <<"You can receive the redeemable bonus now!">>).
-define(PUSH_MSG_2, <<"您的转盘奖励还没有领取!"/utf8>>).
-define(PUSH_MSG_2_EN, <<"You haven't received the roulette reward!">>).
-define(PUSH_MSG_3, <<"您的月卡奖励还没有领取!"/utf8>>).
-define(PUSH_MSG_3_EN, <<"You haven't received the reward of  monthly vip card!">>).
