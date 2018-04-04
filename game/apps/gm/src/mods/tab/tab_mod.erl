%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 08. 六月 2016 下午3:35
%%%-------------------------------------------------------------------
-module(tab_mod).

-include("gm_pub.hrl").

-export([
    tab_list/3, add/2, lookup/2, update/2, delete/2,
    max_page/2, to_binary/1,
    default_select_list/6, default_lookup/2
]).

tab_list(TabName, Arg, SqlEx) ->
    TabNameMod = list_to_atom(binary_to_list(TabName)),
    {value, {_, Page}, Arg1} = lists:keytake(<<"form_list_c_page">>, 1, Arg),
    {value, {_, SeqKey}, Arg2} = lists:keytake(<<"form_list_sort_key">>, 1, Arg1),
    {value, {_, SeqType}, Arg3} = lists:keytake(<<"form_list_sort">>, 1, Arg2),
    Arg4 = [{K, V} || {K, V} <- Arg3, V =/= <<>>],
    {ok, PageInt} = type_can:is_t2t(Page, binary, integer),
    
    if
        PageInt >= 1 ->
            StartIndex = (PageInt - 1) * 60,
            select_list(TabNameMod, Arg4, StartIndex, SeqKey, SeqType, SqlEx);
        true ->
            {200, 1, 0, []}
    end.


select_list(Mod, List, StartIndex, SortKey, SortType, SqlEx) ->
    Select =
        case lists:keyfind(Mod, 1, ?SELECT_EX) of
            false ->
                default_select_list(Mod, List, StartIndex, SortKey, SortType, SqlEx);
            {_, Ex} ->
                Ex:select(Mod, List, StartIndex, SortKey, SortType, SqlEx)
        end,
    if
        is_binary(Select) -> Select;
        true ->
            {Count, PageList} = Select,
            MaxPage = max_page(Count, 60),
            {MaxPage, Count, to_binary(PageList)}
    end.


default_select_list(Mod, List, StartIndex, SortKey, SortType, SqlEx) ->
    FunMap = fun({K, V}) -> Mod:to_index(K, V) end,
    lists:map(FunMap, List),
    case SortKey of
        <<>> -> ok;
        _ -> Mod:to_default(SortKey)
    end,
    Sql = Mod:select(List, integer_to_binary(StartIndex), <<"60">>, SortKey, SortType, sql),
    NewSql =
        if
            SqlEx == [] -> Sql;
            List == [] ->
                SqlWhere = lists:foldl(
                    fun({_K, V}, SqlAcc) ->
                        if
                            SqlAcc == <<>> -> V;
                            true -> <<SqlAcc/binary, "AND", V/binary>>
                        end
                    end,
                    <<>>,
                    SqlEx),
                binary:replace(Sql, <<"limit ">>, <<"WHERE", SqlWhere/binary, "limit ">>);
            true ->
                lists:foldl(
                    fun({K, V}, SqlAcc) ->
                        case lists:keyfind(K, 1, List) of
                            false ->
                                binary:replace(SqlAcc, <<"limit ">>, <<" AND ", V/binary, "limit ">>);
                            _ ->
                                SqlAcc
                        end
                    end,
                    Sql,
                    SqlEx)
        end,
    Mod:select(NewSql).


add(TabName, R) ->
    TabNameMod = list_to_atom(binary_to_list(TabName)),
    case lists:keyfind(TabNameMod, 1, ?ADD_EX) of
        false ->
            R2 = [{K, V} || {K, V} <- R, V =/= <<>>],
            FunFoldl =
                fun({K, V}, Record) ->
                    {Index, NewV} = TabNameMod:to_index(K, V),
                    setelement(Index, Record, NewV)
                end,
            VO = lists:foldl(FunFoldl, TabNameMod:record(), R2),
            TabNameMod:insert(VO);
        {_, Ex} ->
            Ex:insert(TabNameMod, R)
    end.


lookup(TabName, Arg) ->
    TabNameMod = list_to_atom(binary_to_list(TabName)),
    case lists:keyfind(TabNameMod, 1, ?LOOKUP_EX) of
        false ->
            default_lookup(TabNameMod, Arg);
        {_, Ex} ->
            Ex:lookup(TabNameMod, Arg)
    end.

default_lookup(TabNameMod, [{K, V}]) ->
    {_Index, NewV} = TabNameMod:to_index(K, V),
    case TabNameMod:lookup(NewV) of
        [] -> [];
        RetRecord ->
            Size = tuple_size(RetRecord),
            
            NullRecord = TabNameMod:record_info(),
            FunZero =
                fun(Int) ->
                    if
                        Int < 10 -> <<"0", (integer_to_binary(Int))/binary>>;
                        true -> integer_to_binary(Int)
                    end
                end,
            lists:reverse(lists:foldl(
                fun(I, Acc) ->
                    Key = list_to_binary(atom_to_list(lists:nth(I - 1, NullRecord))),
                    ItemV =
                        case element(I, RetRecord) of
                            {date, {Y, M, D}} ->
                                <<(integer_to_binary(Y))/binary, "-", (FunZero(M))/binary, "-", (FunZero(D))/binary>>;
                            {datetime, {{Y, Mo, D}, {H, Mi, S}}} ->
                                <<(integer_to_binary(Y))/binary, "-", (FunZero(Mo))/binary, "-", (FunZero(D))/binary, " ",
                                    (FunZero(H))/binary, ":", (FunZero(Mi))/binary, ":", (FunZero(S))/binary>>;
                            ItemV1 ->
                                ItemV1
                        end,
                    [{Key, ItemV} | Acc]
                end,
                [],
                lists:seq(2, Size)))
    end.


update(TabName, R) ->
    TabNameMod = list_to_atom(binary_to_list(TabName)),
    case lists:keyfind(TabNameMod, 1, ?UPDATE_EX) of
        false ->
            R2 = [{K, V} || {K, V} <- R, V =/= <<>>],
            FunFoldl =
                fun({K, V}, Record) ->
                    {Index, NewV} = TabNameMod:to_index(K, V),
                    setelement(Index, Record, NewV)
                end,
            NewRecord = lists:foldl(FunFoldl, TabNameMod:record(), R2),
            TabNameMod:update(NewRecord);
        {_, Ex} ->
            Ex:update(TabNameMod, R)
    end.


delete(TabName, Keys) ->
    TabNameMod = list_to_atom(binary_to_list(TabName)),
    case lists:keyfind(TabNameMod, 1, ?DEL_EX) of
        false ->
            FunFoldl =
                fun({K, V}, Acc) ->
                    {_Index, NewV} = TabNameMod:to_index(K, V),
                    [NewV | Acc]
                end,
            case lists:foldl(FunFoldl, [], Keys) of
                [Id] ->
                    TabNameMod:delete(Id);
                Ids ->
                    TabNameMod:delete(list_to_tuple(lists:reverse(Ids)))
            end;
        {_, Ex} ->
            Ex:delete(TabNameMod, Keys)
    end.


max_page(Count, PageSize) ->
    LastPageCount = Count rem PageSize,
    AllPage = Count div PageSize,
    if
        LastPageCount == 0 -> AllPage;
        true ->
            AllPage + 1
    end.


to_binary(PageList) ->
    FunZero =
        fun(Int) ->
            if
                Int < 10 -> <<"0", (integer_to_binary(Int))/binary>>;
                true -> integer_to_binary(Int)
            end
        end,
    FunKV =
        fun({K, V}) ->
            NewV =
                case V of
                    {date, {Y, M, D}} ->
                        <<(integer_to_binary(Y))/binary, "-", (FunZero(M))/binary, "-", (FunZero(D))/binary>>;
                    {datetime, {{Y, Mo, D}, {H, Mi, S}}} ->
                        <<(integer_to_binary(Y))/binary, "-", (FunZero(Mo))/binary, "-", (FunZero(D))/binary, " ",
                            (FunZero(H))/binary, ":", (FunZero(Mi))/binary, ":", (FunZero(S))/binary>>;
                    V ->
                        V
                end,
            {K, NewV}
        end,
    Fun = fun({Item}) ->
        {lists:map(FunKV, Item)}
          end,
    lists:map(Fun, PageList).
