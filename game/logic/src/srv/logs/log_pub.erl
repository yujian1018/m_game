%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 12. 八月 2016 上午9:44
%%%-------------------------------------------------------------------
-module(log_pub).

-include("logic_pub.hrl").

-export([
    sup/0, save_data/2,
    add_id/4, to_attr_pid/1, to_item_pid/1, to_skin_pid/1,
    
    s_count/2,
    login_op/3,
    log_role_op/2
]).


sup() ->
    [
        {?MODULE, log_s_count},
        {?MODULE, log_login_op},
        {?MODULE, log_role_op}
    ].


save_data(LogType, Data) ->
    if
        LogType =:= log_s_count ->
            Sql = lists:foldl(fun(I, Acc) ->
                if Acc =:= <<>> -> I;true -> <<Acc/binary, ",", I/binary>> end end, <<>>, Data),
            ?rpc_db_call(db_mysql, el, [<<"INSERT INTO `log_s_count` (`times`, `server_id`, `player_num`) VALUES ">>, Sql, <<";">>]);
        
        LogType =:= log_login_op ->
            Sql = lists:foldl(fun(I, Acc) ->
                if Acc =:= <<>> -> I;true -> <<Acc/binary, ",", I/binary>> end end, <<>>, Data),
            ?rpc_db_call(db_mysql, el, [<<"insert into log_login_op (uid, type, v, c_times) values ">>, Sql, <<";">>]);
        
        LogType =:= log_role_op ->
            Sql = lists:foldl(fun(I, Acc) ->
                ISql = erl_bin:sql(I),
                if Acc =:= <<>> -> ISql;true -> <<Acc/binary, ",", ISql/binary>> end end, <<>>, Data),
            ?rpc_db_call(db_mysql, el, [<<"insert into log_role_op (uid, op, times) values ">>, Sql, <<";">>]);
        
        true ->
            TabNameBin = list_to_binary(atom_to_list(LogType)),
            Sql = lists:foldl(fun(I, Acc) ->
                if Acc =:= <<>> -> erl_bin:sql(I);true ->
                    <<Acc/binary, ",", (erl_bin:sql(I))/binary>> end end, <<>>, Data),
            ?rpc_db_call(db_mysql, el, [<<"INSERT INTO `", TabNameBin/binary, "` (`player_id`, `type_id`, `v`, `times`) VALUES">>, Sql, <<";">>])
    end.


%% 服务器人数
s_count(Num, ServerId) ->
    CTimes = integer_to_binary(erl_time:now()),
    log_s_count ! erl_bin:sql([CTimes, (integer_to_binary(ServerId)), (integer_to_binary(Num))]).


%% 上下线
login_op(Uid, Type, V) ->
    log_login_op ! erl_bin:sql([(integer_to_binary(Uid)), Type, V, (integer_to_binary(erl_time:now()))]).


log_role_op(Uid, Op) ->
    log_role_op ! erl_bin:sql([(integer_to_binary(Uid)), ?encode(Op)]).


%% 资源
to_attr_pid(K) -> list_to_atom("log_attr_id_" ++ integer_to_list(K)).
to_item_pid(K) -> list_to_atom("log_item_id_" ++ integer_to_list(K)).
to_skin_pid(K) -> list_to_atom("log_skin_id_" ++ integer_to_list(K)).


%% AssetType = ?ATTR||?ITEM||?SKIN
%% AssetId = 资源id
%% KVList = [[资源id, 数量]|...]
-spec add_id(AssetType :: ?ATTR|?ITEM, Uid :: integer(), AssetId :: integer(), KVList :: list()) -> ok.
add_id(AssetType, Uid, AssetId, KVList) ->
    lists:map(
        fun([K, V]) ->
            if
                V == 0 -> ok;
                true ->
                    PidName = if
                                  AssetType =:= ?ATTR -> to_attr_pid(K);
                                  AssetType =:= ?ITEM -> to_item_pid(K)
                              end,
                    case whereis(PidName) of
                        undefined -> ok;
                        _ -> PidName ! [Uid, AssetId, V, erl_time:now()]
                    end
            end
        end,
        KVList).