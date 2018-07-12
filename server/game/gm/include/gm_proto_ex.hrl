%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 06. 五月 2016 下午2:21
%%%-------------------------------------------------------------------

-define(SELECT_EX, [
    {attr, attr_ex},
    {report_data_center, report_data_center_ex},
    {recharge_rank, recharge_rank_ex},
    {report_asset_diamond, report_asset_diamond_ex},
    {report_asset_gold, report_asset_gold_ex},
    {report_login_out, report_login_out_ex},
    {log_attr_lv, log_attr_lv_ex},
    {card, card_ex},
    {global_prize, global_prize_ex},
    {mail_mng, mail_mng_ex}
]).

-define(ADD_EX, [
    {log_send_mail, log_send_mail_ex},
    {role_ban, role_ban_ex},
    {mail_mng, mail_mng_ex}
]).
-define(LOOKUP_EX, [
    {mail_mng, mail_mng_ex}
]).
-define(DEL_EX, [
    {role_ban, role_ban_ex},
    {mail_mng, mail_mng_ex}
]).

-define(UPDATE_EX, [
    {role_ban, role_ban_ex},
    {global_active, global_active_ex},
    {attr, attr_ex},
    {mail_mng, mail_mng_ex}
]).

-define(IS_RELOAD_CONFIG, [
    <<"ai_control">>,
    <<"global_prize">>
]).