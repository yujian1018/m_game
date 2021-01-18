%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 19. 七月 2016 下午2:42
%%%-------------------------------------------------------------------
-module(load_attr_sql).

-include("load_attr.hrl").
-include("obj_pub.hrl").

-export([sql/1, lookup/1, to_record/2, save_data/1]).

-export([
    create_role/3,
    attr_vo/1, attr_v/2
]).


sql(Uid) ->
    <<"select is_ai, name, sex, icon, gold, diamond, lv, exp,
    room_pid, mtt_pid, address, bank_poll, infullmount, sng_score, sign, refresh_times,
    gmt_offset, client_setting, active_point, active_rewards,
    vip_lv, vip_exp, c_times from attr where uid = ", (integer_to_binary(Uid))/binary, ";">>.


save_data(Record) ->
    FunPid =
        fun(Pid) ->
            if
                Pid =:= ?undefined -> <<>>;
                Pid =:= <<>> -> <<>>;
                true -> list_to_binary(pid_to_list(Pid))
            end
        end,
    <<"UPDATE attr SET is_ai = ",
        (integer_to_binary(Record#?tab_last_name.is_ai))/binary, ",name= '",
        (Record#?tab_last_name.nick)/binary, "',sex= ",
        (integer_to_binary(Record#?tab_last_name.sex))/binary, ",icon= '",
        (Record#?tab_last_name.icon)/binary, "',gold= ",
        (integer_to_binary(Record#?tab_last_name.gold))/binary, ",diamond= ",
        (integer_to_binary(Record#?tab_last_name.diamond))/binary, ",lv= ",
        (integer_to_binary(Record#?tab_last_name.lv))/binary, ",exp= ",
        (integer_to_binary(Record#?tab_last_name.exp))/binary, ",room_pid= '",
        (FunPid(Record#?tab_last_name.room_pid))/binary, "',mtt_pid= '",
        (FunPid(Record#?tab_last_name.mtt_pid))/binary, "',address= '",
        (Record#?tab_last_name.address)/binary, "',bank_poll= '",
        (integer_to_binary(Record#?tab_last_name.bank_poll))/binary, "',infullmount= '",
        (integer_to_binary(Record#?tab_last_name.all_rmb))/binary, "',sng_score= '",
        (integer_to_binary(Record#?tab_last_name.sng_score))/binary, "',sign= '",
        (Record#?tab_last_name.sign)/binary, "',`refresh_times` = ",
        (integer_to_binary(Record#?tab_last_name.refresh_times))/binary, ",`offline_times` = ",
        (integer_to_binary(erl_time:now()))/binary, ", `client_setting` = '",
        (Record#?tab_last_name.client_setting)/binary, "', `active_point` = '",
        (integer_to_binary(Record#?tab_last_name.active_point))/binary, "', `active_rewards` = '",
        (?encode(Record#?tab_last_name.active_rewards))/binary, "', `vip_lv` = '",
        (integer_to_binary(Record#?tab_last_name.vip_lv))/binary, "', `vip_exp` = '",
        (integer_to_binary(Record#?tab_last_name.vip_exp))/binary, "' WHERE uid = ",
        (integer_to_binary(Record#?tab_last_name.uid))/binary, ";">>.


to_record(Uid, []) ->
    #?tab_last_name{uid = Uid, refresh_times = erl_time:now()};

to_record(Uid, [[IsAi, Nick, Sex, Icon, Gold, Diamond, Lv, Exp, RoomPid, MttPid, Address, BankPoll, AllAmount, SngScore,
    Sign, RefreshTimes, GMTOffset, ClientSetting, ActivePoint, ActivePrize, VipLv, VipExp, CTimes]]) ->
    FunPid =
        fun(Pid) ->
            if
                Pid =:= ?undefined -> <<>>;
                Pid =:= <<>> -> <<>>;
                true ->
                    NewPid = list_to_pid(binary_to_list(Pid)),
                    case erlang:is_process_alive(NewPid) of
                        true -> NewPid;
                        false -> <<>>
                    end
            end
        end,
    FunDecode =
        fun(BinKvList) ->
            if
                BinKvList =:= ?undefined -> [];
                BinKvList =:= <<>> -> [];
                true ->
                    ?decode(BinKvList)
            end
        end,
    FunBin = fun(Bin) ->
        if
            Bin =:= ?undefined -> <<>>;
            true -> Bin
        end
             end,
    #?tab_last_name{uid = Uid, is_ai = IsAi, nick = Nick, sex = Sex, icon = Icon, gold = Gold, diamond = Diamond, lv = Lv, exp = Exp,
        room_pid = FunPid(RoomPid), mtt_pid = FunPid(MttPid), address = Address,
        bank_poll = BankPoll, all_rmb = AllAmount, sng_score = SngScore, sign = Sign,
        refresh_times = RefreshTimes, gmt_offset = GMTOffset,
        client_setting = FunBin(ClientSetting), active_point = ActivePoint, active_rewards = FunDecode(ActivePrize),
        vip_lv = VipLv, vip_exp = VipExp, c_times = CTimes}.


lookup(Uid) ->
    to_record(Uid, ?rpc_db_call(erl_msyql, ed, [sql(Uid)])).

create_role(Uin, ChannelId, PacketId) ->
    UinBin = integer_to_binary(Uin),
    UinBin = integer_to_binary(Uin),
    [[Name, Sex, Icon, Address, GmtOffset]] = ?rpc_db_call(erl_msyql, ea, [<<"select nick, sex, head_img, address, gmt_offset from account_info where uin = ", UinBin/binary, ";">>]),
    Name2 =
        if
            Name =:= <<>> ->
                Rank = integer_to_binary(erl_random:random(999)),
                <<"Guest"/utf8, Rank/binary, (integer_to_binary(Uin))/binary>>;
            true ->
                Name
        end,
    NowBin = erl_time:now_bin(),
    Uid = ?rpc_db_call(erl_msyql, ed, [zt_sql:insert("player", [{"uin", Uin}])]),
    ?rpc_db_call(erl_msyql, ed, [<<"insert into attr (uid, gold, packet_id, channel_id, icon, name, sex, address, c_times, refresh_times, gmt_offset) VALUES (",
        (integer_to_binary(Uid))/binary, ", 2000, ",
        PacketId/binary, ",",
        ChannelId/binary, ",'",
        Icon/binary, "','",
        Name2/binary, "', ",
        (integer_to_binary(Sex))/binary, ", '",
        Address/binary, "', ", NowBin/binary, ", '", NowBin/binary, "', '", (integer_to_binary(GmtOffset))/binary, "');">>]),
    log_pub:add_id(?ATTR, Uid, 1, [[?GOLD, 2000]]),
    Uid.

attr_vo(Uid) ->
    <<"select uid, name, icon, sex, gold, diamond, lv, exp, sign, sng_score, vip_lv from attr where uid = ", (integer_to_binary(Uid))/binary, ";">>.


attr_v(Uid, Ks) ->
    NewSelect =
        if
            is_integer(Ks) -> to_mysql(Ks);
            is_list(Ks) ->
                lists:foldl(
                    fun(K, Acc) ->
                        KBin = to_mysql(K),
                        if
                            Acc =:= <<>> -> KBin;
                            true -> <<Acc/binary, ",", KBin/binary>>
                        end
                    end,
                    <<>>,
                    Ks)
        end,
    <<"select ", NewSelect/binary, " from attr where uid = ", (integer_to_binary(Uid))/binary, ";">>.


to_mysql(?UID) -> <<"`uid`">>;
to_mysql(?NICK) -> <<"`nick`">>;
to_mysql(?SEX) -> <<"`sex`">>;
to_mysql(?GOLD) -> <<"`gold`">>;
to_mysql(?ICON) -> <<"`icon`">>;
to_mysql(?DIAMOND) -> <<"`diamond`">>;
to_mysql(?LV) -> <<"`lv`">>;
to_mysql(?EXP) -> <<"`exp`">>;
to_mysql(?SIGN) -> <<"`sign`">>;
to_mysql(?GMT_OFFSET) -> <<"`gmt_offset`">>;
to_mysql(?ADDRESS) -> <<"`address`">>;
to_mysql(?ALL_RMB) -> <<"`all_rmb`">>;
to_mysql(?REFRESH_TIMES) -> <<"`refresh_times`">>;
to_mysql(?CLIENT_SETTING) -> <<"`client_setting`">>;
to_mysql(?ACTIVE_POINT) -> <<"`active_point`">>;
to_mysql(?ACTIVE_REWARDS) -> <<"`active_rewards`">>;
to_mysql(?VIP_LV) -> <<"`vip_lv`">>;
to_mysql(?VIP_EXP) -> <<"`vip_exp`">>.
