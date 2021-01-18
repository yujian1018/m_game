%%%-------------------------------------------------------------------
%%% @author yj 战斗节点管理器
%%% @doc
%%%
%%% Created : 27. 七月 2016 下午3:06
%%%-------------------------------------------------------------------
-module(cache_server_version).

-behaviour(cache_srv).
-include("mgr_pub.hrl").
-include_lib("cache/include/cache_mate.hrl").


-export([
    select/0,
    refresh/0,
    addrs/0, addrs/2,
    node_set/2, node_del/1
]).


load_cache() ->
    [
        #cache_mate{
            name = ?ETS_TAB_NODE,
            key_pos = #?ETS_TAB_NODE.s_node
        },
        #cache_mate{
            name = ?ETS_TAB_NODE_ON,
            key_pos = 1
        }
    ].


addrs() ->
    ets:foldl(
        fun(R, {Acc, Count}) ->
            if
                is_record(R, cache_server_version) ->
                    {[{[
                        {<<"node">>, R#cache_server_version.s_node},
                        {<<"name">>, R#cache_server_version.s_name},
                        {<<"url">>, R#cache_server_version.url},
                        {<<"port">>, R#cache_server_version.port},
                        {<<"version">>, R#cache_server_version.s_version},
                        {<<"count">>, R#cache_server_version.count}
                    ]} | Acc], Count + 1};
                true -> {Acc, Count}
            end
        end,
        {[], 0}, ?ETS_TAB_NODE).


addrs(SType, CVersion) ->
    [SV1, SV2, _SV3] = binary:split(CVersion, <<".">>, [global]),
    SVersion = <<SV1/binary, ".", SV2/binary, ".*">>,
    
    case ets:lookup(?ETS_TAB_NODE_ON, {SType, SVersion}) of
        [] -> [];
        [{{SType, SVersion}, Nodes}] ->
            NewRecords =
                [Record || [Record] <-
                    [ets:lookup(?ETS_TAB_NODE, Node) || Node <- Nodes], Record#cache_server_version.status =:= ?TRUE],
            FunBreak = fun(Record) ->
                
                if
                    Record#cache_server_version.count =< 2000 ->
                        {Record#cache_server_version.url, Record#cache_server_version.port};
                    true -> false
                end
                       end,
            case erl_list:map_break(FunBreak, NewRecords) of
                false ->
                    ?ERROR("all server busy!"),
                    case NewRecords of
                        [] -> [];
                        L ->
                            [SorRecord | _R] = lists:keysort(#cache_server_version.count, L),
                            {SorRecord#cache_server_version.url, SorRecord#cache_server_version.port}
                    end;
                Ret -> Ret
            end
    end.


select() ->
    ?rpc_db_call(db_mysql, es, [<<"SELECT s_node, s_name, url, port, s_type, s_version from server_client;">>]).


refresh() ->
    Data = select(),
    FunFoldl =
        fun([SnodeBin, Sname, Url, Port, SType, SVersionBin], {RecordsAcc, IdsAcc, Tab2RecordsAcc, Tab2IdsAcc}) ->
            SNode = binary_to_atom(SnodeBin, utf8),
            if
                SType =:= ?NODE_OBJ ->
                    [SV1, SV2, _SV3] = binary:split(SVersionBin, <<".">>, [global]),
                    SVersion = <<SV1/binary, ".", SV2/binary, ".*">>,
                    NewTa2RecordsAcc =
                        case lists:keytake({SType, SVersion}, 2, Tab2RecordsAcc) of
                            false ->
                                [{{SType, SVersion}, [SNode]} | Tab2RecordsAcc];
                            {value, {{SType, SVersion}, Nodes}, R} ->
                                [{{SType, SVersion}, [SNode | Nodes]} | R]
                        end,
                    Status = case net_adm:ping(SNode) of
                                 pong -> ?TRUE;
                                 pang -> ?FALSE
                             end,
                    {
                        [#cache_server_version{s_node = SNode, s_name = Sname, url = Url, port = Port, s_type = SType, s_version = SVersion, status = Status} | RecordsAcc],
                        [SNode | IdsAcc],
                        NewTa2RecordsAcc,
                        [{SType, SVersion} | Tab2IdsAcc]
                    };
                true ->
                    {
                        [#cache_server_version{s_node = SNode, s_name = Sname, s_type = SType} | RecordsAcc],
                        [SNode | IdsAcc],
                        Tab2RecordsAcc, Tab2IdsAcc
                    }
            end
        end,
    {AllRecords, AllIds, AllTab2Records, AllTab2Ids} = lists:foldl(FunFoldl, {[], [], [], []}, Data),
    cache_srv:reset_record(?ETS_TAB_NODE, AllRecords, AllIds),
    
    OldIds = case ets:lookup(?ETS_TAB_NODE_ON, all_ids) of
                 [] -> [];
                 [{_, IdList1}] -> IdList1
             end,
    DelIds = erl_list:diff(OldIds, AllTab2Ids, []),
    ets:insert(?ETS_TAB_NODE_ON, AllTab2Records),
    ets:insert(?ETS_TAB_NODE_ON, {all_ids, AllTab2Ids}),
    [ets:delete(?ETS_TAB_NODE_ON, DelId) || DelId <- DelIds].


node_set(Node, Args) ->
    case ets:lookup(?ETS_TAB_NODE, Node) of
        [] ->
            ?ERROR("tab server_client no node:~p~n", [[Node, Args]]);
        [Record] ->
            case Args of
                {Count, CountEx} ->
                    ets:insert(?ETS_TAB_NODE, Record#cache_server_version{count = Count, count_ex = CountEx, status = ?TRUE});
                Count ->
                    ets:insert(?ETS_TAB_NODE, Record#cache_server_version{count = Count, status = ?TRUE})
            end,
            if
                Record#cache_server_version.s_type =:= ?NODE_OBJ ->
                    node_on(Record#cache_server_version.s_type, Record#cache_server_version.s_version, Node);
                true -> ok
            end
    end.


node_del(Node) ->
    case ets:lookup(?ETS_TAB_NODE, Node) of
        [] -> ok;
        [Record] ->
            ets:insert(?ETS_TAB_NODE, Record#cache_server_version{status = ?FALSE}),
            if
                Record#cache_server_version.s_type =:= ?NODE_OBJ ->
                    node_off(Record#cache_server_version.s_type, Record#cache_server_version.s_version, Node);
                true ->
                    ok
            end
    end.

node_on(SType, SVersionBin, Node) ->
    [SV1, SV2, _SV3] = binary:split(SVersionBin, <<".">>, [global]),
    SVersion = <<SV1/binary, ".", SV2/binary, ".*">>,
    case ets:lookup(?ETS_TAB_NODE_ON, {SType, SVersion}) of
        [] ->
            ets:insert(?ETS_TAB_NODE_ON, {{SType, SVersion}, [Node]});
        [{_Id, Nodes}] ->
            ets:insert(?ETS_TAB_NODE_ON, {{SType, SVersion}, lists:usort([Node | Nodes])})
    end.


node_off(SType, SVersionBin, Node) ->
    [SV1, SV2, _SV3] = binary:split(SVersionBin, <<".">>, [global]),
    SVersion = <<SV1/binary, ".", SV2/binary, ".*">>,
    case ets:lookup(?ETS_TAB_NODE_ON, {SType, SVersion}) of
        [] -> ok;
        [{_Id, Nodes}] ->
            ets:insert(?ETS_TAB_NODE_ON, {{SType, SVersion}, lists:delete(Node, Nodes)})
    end.