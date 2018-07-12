%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 21. 九月 2017 下午3:19
%%%-------------------------------------------------------------------
-module(load_asset).

-export([
    asset_key/0,
    item_ids/0,
    mail_keys/0
]).

asset_key() ->
    prize_key() ++ cost_key().

prize_key() ->
    erl_mysql:execute(pool_static_1, <<"select prize_id, comment from global_prize;">>).

cost_key() ->
    erl_mysql:execute(pool_static_1, <<"select -cost_id, comment from global_cost;">>).

item_ids() ->
    erl_mysql:execute(pool_static_1, <<"select item_id, comment from config_item;">>).

mail_keys() ->
    [[PrizeId, <<Comment/binary, ":", Prize/binary>>] || [PrizeId, Comment, Prize] <- erl_mysql:execute(pool_static_1, <<"select prize_id, comment, prize from global_prize where prize_id >= 100701001 and prize_id < 100799999;">>)].