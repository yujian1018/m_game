%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 02. 十一月 2017 上午10:46
%%%-------------------------------------------------------------------
-module(report_data_center_ex).


-include("gm_pub.hrl").

-export([
    select/6
]).


select(_Mod, List, StartIndex, SortKey, SortType, _SqlEx) ->
    FunMap = fun({K, V}) -> report_data_center:to_index(K, V) end,
    lists:map(FunMap, List),
    case SortKey of
        <<>> -> ok;
        _ -> report_data_center:to_default(SortKey)
    end,
    Sql = report_data_center:select(List, integer_to_binary(StartIndex), <<"60">>, SortKey, SortType, sql),
    [Sql1, Sql2] = binary:split(Sql, [<<";">>]),
    NewSql = binary:replace(Sql1, <<"count(*)">>, <<"count(*), sum(c_roles), sum(recharge_amount)">>),
    [[[Count, CountRoles, CountAmount]], Ret] = erl_mysql:execute(pool_log_1, <<NewSql/binary, ";", Sql2/binary>>),
    Fun =
        fun([ID, TIMES, CHANNEL_ID, C_ROLES, C_DEVICES, C_ACCOUNTS, C_GUESTS, LOGIN_ROLES, LOGIN_COUNT, RECHARGE_AMOUNT, RECHARGE_ACCOUNTS, RECHARGE_COUNT, NEW_RECHARGE_ACCOUNTS, NEW_RECHARGE_AMOUNT, PCU, PCU_DATE, ACU, ACU_DURATION]) ->
            {[{<<"id">>, ID}, {<<"times">>, TIMES}, {<<"channel_id">>, CHANNEL_ID}, {<<"c_roles">>, C_ROLES}, {<<"c_devices">>, C_DEVICES}, {<<"c_accounts">>, C_ACCOUNTS}, {<<"c_guests">>, C_GUESTS}, {<<"login_roles">>, LOGIN_ROLES}, {<<"login_count">>, LOGIN_COUNT}, {<<"recharge_amount">>, RECHARGE_AMOUNT}, {<<"recharge_accounts">>, RECHARGE_ACCOUNTS}, {<<"recharge_count">>, RECHARGE_COUNT}, {<<"new_recharge_accounts">>, NEW_RECHARGE_ACCOUNTS}, {<<"new_recharge_amount">>, NEW_RECHARGE_AMOUNT}, {<<"pcu">>, PCU}, {<<"pcu_date">>, PCU_DATE}, {<<"acu">>, ACU}, {<<"acu_duration">>, ACU_DURATION}]}
        end,
    MaxPage = tab_mod:max_page(Count, 60),
    jiffy:encode({[
        {<<"code">>, 200},
        {<<"max_page">>, MaxPage},
        {<<"count">>, Count},
        {<<"ret">>, lists:map(Fun, Ret)},
        {<<"count_roles">>, CountRoles},
        {<<"count_amount">>, CountAmount}
    ]}).
