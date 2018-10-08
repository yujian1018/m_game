%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 19. 七月 2016 下午2:42
%%%-------------------------------------------------------------------
-module(load_attr).

-include_lib("cache/include/cache_mate.hrl").
-include("load_attr.hrl").
-include("logic_pub.hrl").

-export([load_data/1, save_data/1, del_data/1]).


-export([
    get_v/2, set_v/2, change/3, change_no_log/3,
    
    is_vip/1, reset_v/1,
    
    get_v_gm/2
]).


load_cache() ->
    [
        #cache_mate{
            name = ?tab_name,
            keypos = #?tab_last_name.uid
        }
    ].


is_vip(Uid) ->
    VipLv =
        case ?rpc_db_call(redis_online, is_online, [Uid]) of
            {ok, _Pid} -> get_v(Uid, ?VIP_LV);
            {ok, Node, _Pid} ->
                case rpc:call(Node, load_attr, get_v, [Uid, ?VIP_LV]) of
                    {badrpc, _} -> 0;
                    _VipLv -> _VipLv
                end;
            false -> 0
        end,
    if
        VipLv =:= 0 -> ?false;
        true -> VipLv
    end.


load_data(Uid) ->
    Fun =
        fun([VO | VOAcc]) ->
            Record = load_attr_sql:to_record(Uid, VO),
            insert(Record),
            VOAcc
        end,
    {load_attr_sql:sql(Uid), Fun}.


save_data(Uid) ->
    Record = lookup(Uid),
    load_attr_sql:save_data(Record).


del_data(Uid) ->
    cache:delete(?tab_name, Uid).


lookup(Uid) ->
    [Record] = cache:lookup(?tab_name, Uid),
    erl_record:diff_record(Record, #?tab_last_name{}).


insert(Record) ->
    cache:insert(?tab_name, Record).


get_v(Uid, K) when is_integer(K) ->
    Record = lookup(Uid),
    element(to_record(K), Record);

get_v(Uid, Ks) when is_list(Ks) ->
    Record = lookup(Uid),
    [element(to_record(K), Record) || K <- Ks].

set_v(Uid, KvList) ->
%%    ?DEBUG("set_v:~p~n", [[Uid, KvList]]),
    Record = lookup(Uid),
    {NewRecord, SendKv} =
        lists:foldl(
            fun(Kv, {RecordAcc, SendAcc}) ->
                {NewRecord, Data} =
                    case Kv of
                        [K, V] -> change_v(Uid, RecordAcc, K, V, []);
                        [K, Op, V] -> change_v(Uid, RecordAcc, K, Op, V)
                    end,
                {NewRecord, Data ++ SendAcc}
            end,
            {Record, []}, KvList),
    attr_proto:send_attr(Uid, SendKv),
    load_active:change(Uid, SendKv),
    insert(NewRecord).


%% @doc 改变属性。
change(StateOrUid, PrizeId, Assets) ->
%%    ?DEBUG("change start :~p~n", [[StateOrUid, PrizeId, Assets]]),
    {Uid, NewAssets3, _Record, SendKv} = change_no_log(StateOrUid, PrizeId, Assets),
    
    FunFoldl1 =
        fun(Kv, Acc) ->
            case Kv of
                [?GOLD, Gold] ->
                    [[?GOLD, Gold] | Acc];
                [K, V] -> [[K, V] | Acc];
                [K, _Op, V] -> [[K, V] | Acc]
            end
        end,
    NewAssets4 = lists:foldl(FunFoldl1, [], NewAssets3),
    
    FunFoldl2 =
        fun(Kv, Acc) ->
            case Kv of
                [?LV, Lv] -> [[?LV, Lv] | Acc];
                [?VIP_LV, VipLv] -> [[?VIP_LV, VipLv] | Acc];
                _ -> Acc
            end
        end,
    LogSendKv = lists:foldl(FunFoldl2, [], SendKv),
    
    log_pub:add_id(?ATTR, Uid, PrizeId, NewAssets4),
    log_pub:add_id(?ATTR, Uid, PrizeId, LogSendKv).

change_no_log(StateOrUid, PrizeId, Assets) ->
%%    ?DEBUG("change_no_log:~p~n", [[StateOrUid, PrizeId, Assets]]),
    {Uid, IsOnline, Record} =
        case ?rpc_db_call(redis_online, is_online, [StateOrUid]) of
            {ok, _Pid} ->
                {StateOrUid, ?true, lookup(StateOrUid)};
            {ok, _Node, _Pid} ->
                {error, <<"跨服的情况，不会出现这种情况"/utf8>>};
            false ->
                {StateOrUid, ?false, load_attr_sql:lookup(StateOrUid)}
        end,
    %% 是否周卡
%%    NewAssets1 = config_prize:card_asset(Uid, PrizeId, ?ATTR, Assets),
    %% 是否vip
    NewAssets2 = config_prize:vip_asset(Uid, PrizeId, ?ATTR, Assets),
%%    ?INFO("222:~p~n", [NewAssets2]),
    %% 是否buff
    NewAssets3 =
        if
            IsOnline =:= ?false -> Assets;
            true -> load_buff:asset_buff(Uid, PrizeId, NewAssets2)
        end,
%%    ?INFO("333:~p~n", [NewAssets3]),
    {NewRecord, SendKv} =
        lists:foldl(
            fun(Kv, {RecordAcc, SendAcc}) ->
                {NewRecord, Data} =
                    case Kv of
                        [K, V] -> change_v(StateOrUid, RecordAcc, K, V, []);
                        [K, Op, V] -> change_v(StateOrUid, RecordAcc, K, Op, V)
                    end,
                {NewRecord, Data ++ SendAcc}
            end,
            {Record, []}, NewAssets3),
    if
        IsOnline -> insert(NewRecord);
        true -> ?rpc_db_call(db_mysql, ed, [load_attr_sql:save_data(NewRecord)])
    end,
    attr_proto:send_attr(StateOrUid, SendKv),
    load_active:change(Uid, SendKv),
    {Uid, NewAssets3, NewRecord, SendKv}.

change_v(_StateOrUid, Record, ?EXP, AddExp, []) ->
    Lv = Record#?tab_last_name.lv,
    Exp = Record#?tab_last_name.exp,
    case config_lvup:lvup(Lv, Exp + AddExp) of
        {Lv, NewExp} ->
            {setelement(#?tab_last_name.exp, Record, NewExp), [[?EXP, NewExp]]};
        {NewLv, NewExp} ->
            Record2 = setelement(#?tab_last_name.exp, Record, NewExp),
            {setelement(#?tab_last_name.lv, Record2, NewLv), [[?LV, NewLv], [?EXP, NewExp]]}
    end;

change_v(_StateOrUid, Record, ?VIP_EXP, AddExp, []) ->
    Lv = Record#?tab_last_name.vip_lv,
    Exp = Record#?tab_last_name.vip_exp,
    case config_lvup:vip_lvup(Lv, Exp + AddExp) of
        {Lv, NewExp} ->
            {setelement(#?tab_last_name.vip_exp, Record, NewExp), [[?VIP_EXP, NewExp]]};
        {NewLv, NewExp} ->
            player_mgr:abcast(chat_handler, {abcast, notice, [5, Record#?tab_last_name.nick, NewLv]}),
            ?send_cast_msg(self(), ?attr_handler, {?event_lvup_vip, Lv}),
            Record2 = setelement(#?tab_last_name.vip_exp, Record, NewExp),
            {setelement(#?tab_last_name.vip_lv, Record2, NewLv), [[?VIP_LV, NewLv], [?VIP_EXP, NewExp]]}
    end;

change_v(_StateOrUid, Record, K, Op, V) ->
    Index = to_record(K),
    OldV = element(Index, Record),
    NewV =
        if
            Op =:= 0 -> OldV;
            Op =:= "=" orelse Op =:= <<"=">> -> V;
            Op =:= "+" orelse Op =:= <<"+">> -> V + OldV;
            Op =:= "-" orelse Op =:= <<"-">> -> OldV - V;
            Op =:= "fun" orelse Op =:= <<"fun">> ->
                [Fun, V2] = V,
                Fun(V2, OldV);
            Op =:= "max" orelse Op =:= <<"max">> -> erlang:max(V, OldV);
            Op =:= "min" orelse Op =:= <<"min">> -> erlang:min(V, OldV);
            true ->
                Op + OldV
        end,
    if
        OldV =:= NewV -> {Record, []};
        true ->
            case lists:member(K, attr_handler:send_to_client_key()) of
                true ->
                    {setelement(Index, Record, NewV), [[K, NewV]]};
                false ->
                    {setelement(Index, Record, NewV), []}
            end
    end.


reset_v(Uid) ->
    Record = lookup(Uid),
    insert(Record#?tab_last_name{active_point = 0, active_rewards = []}).

to_record(?UID) -> #?tab_last_name.uid;
to_record(?NICK) -> #?tab_last_name.nick;
to_record(?SEX) -> #?tab_last_name.sex;
to_record(?GOLD) -> #?tab_last_name.gold;
to_record(?ICON) -> #?tab_last_name.icon;
to_record(?DIAMOND) -> #?tab_last_name.diamond;
to_record(?LV) -> #?tab_last_name.lv;
to_record(?EXP) -> #?tab_last_name.exp;
to_record(?SIGN) -> #?tab_last_name.sign;
to_record(?GMT_OFFSET) -> #?tab_last_name.gmt_offset;   %时区偏移量
to_record(?ADDRESS) -> #?tab_last_name.address;
to_record(?ALL_RMB) -> #?tab_last_name.all_rmb;
to_record(?REFRESH_TIMES) -> #?tab_last_name.refresh_times;   %刷新时间
to_record(?CLIENT_SETTING) -> #?tab_last_name.client_setting;
to_record(?ACTIVE_POINT) -> #?tab_last_name.active_point;
to_record(?ACTIVE_REWARDS) -> #?tab_last_name.active_rewards;
to_record(?VIP_LV) -> #?tab_last_name.vip_lv;
to_record(?VIP_EXP) -> #?tab_last_name.vip_exp;
to_record(?C_TIMES) -> #?tab_last_name.c_times.


get_v_gm(Uid, PidBin) ->
    Record = lookup(Uid),
    PlayerPid = list_to_pid(binary_to_list(PidBin)),
    case erlang:is_process_alive(PlayerPid) of
        true ->
            ChannelId = gen_server:call(PlayerPid, ?call_msg(?attr_handler, get_channel_id)),
            [
                Record#?tab_last_name.uid,
                ChannelId,
                Record#?tab_last_name.is_ai,
                Record#?tab_last_name.nick,
                Record#?tab_last_name.sex,
                Record#?tab_last_name.icon,
                Record#?tab_last_name.gold,
                Record#?tab_last_name.bank_poll,
                Record#?tab_last_name.diamond,
                Record#?tab_last_name.lv,
                Record#?tab_last_name.exp,
                Record#?tab_last_name.room_pid,
                Record#?tab_last_name.address,
                Record#?tab_last_name.all_rmb,
                Record#?tab_last_name.sng_score,
                Record#?tab_last_name.sign,
                Record#?tab_last_name.refresh_times,
                Record#?tab_last_name.offline_times,
                Record#?tab_last_name.gmt_offset,
                Record#?tab_last_name.client_setting,
                Record#?tab_last_name.active_point,
                Record#?tab_last_name.active_rewards,
                Record#?tab_last_name.vip_lv,
                Record#?tab_last_name.vip_exp
            ];
        false ->
            false
    end.