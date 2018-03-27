%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 15. 九月 2017 下午2:52
%%%-------------------------------------------------------------------
-module(load_active_sql).


-include("load_active.hrl").
-include("obj_pub.hrl").

-export([
    sql/1,
    lookup/1,
    to_record/2,
    to_data/1,
    save_data/1
]).


sql(Uid) ->
    <<"select active_id, progress, prize from active where uid = ", (integer_to_binary(Uid))/binary, ";">>.


save_data(#active{uid = Uid, items = Items}) ->
    Fun =
        fun(Record) ->
            NewRecord = erl_record:diff_record(Record, #?tab_last_name{}),
            if
                NewRecord#?tab_last_name.prize =:= [] andalso NewRecord#?tab_last_name.op =:= ?OP_DEFAULT ->
                    <<>>;
                NewRecord#?tab_last_name.op =:= ?OP_ADD ->
                    <<"INSERT INTO active (uid, active_id, progress, prize) VALUES (",
                        (integer_to_binary(Uid))/binary, ", ",
                        (integer_to_binary(NewRecord#?tab_last_name.active_id))/binary, ", ",
                        (integer_to_binary(NewRecord#?tab_last_name.progress))/binary, ", '",
                        (?encode(NewRecord#?tab_last_name.prize))/binary, "') ON DUPLICATE KEY UPDATE progress = ",
                        (integer_to_binary(NewRecord#?tab_last_name.progress))/binary, ", prize = '",
                        (?encode(NewRecord#?tab_last_name.prize))/binary, "';">>;
                NewRecord#?tab_last_name.op =:= ?OP_DEL ->
                    <<"delete from active where uid = ", (integer_to_binary(Uid))/binary, " and active_id = ", (integer_to_binary(NewRecord#?tab_last_name.active_id))/binary, ";">>;
                NewRecord#?tab_last_name.op =:= ?OP_UPDATE ->
                    <<"UPDATE active SET progress = ",
                        (integer_to_binary(NewRecord#?tab_last_name.progress))/binary, ", prize = '",
                        (?encode(NewRecord#?tab_last_name.prize))/binary, "' WHERE  uid = ",
                        (integer_to_binary(Uid))/binary, " and active_id = ",
                        (integer_to_binary(NewRecord#?tab_last_name.active_id))/binary, ";">>;
                true ->
                    <<>>
            end
        end,
    lists:map(Fun, Items).


to_record(Uid, []) ->
    #active{uid = Uid};

to_record(Uid, VO) ->
    Fun =
        fun([ActiveId, Progress, Prize]) ->
            #?tab_last_name{active_id = ActiveId, progress = Progress, prize = ?decode(Prize)}
        end,
    Items = lists:map(Fun, VO),
    #active{uid = Uid, items = Items}.


to_data(Record) ->
    [[Item#?tab_last_name.active_id, Item#?tab_last_name.progress, Item#?tab_last_name.prize] || Item <- Record#active.items].


lookup(Uid) ->
    to_record(Uid, ?rpc_db_call(db_mysql, ea, [sql(Uid)])).
