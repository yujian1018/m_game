%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc  存储格式map  #{<<"怎"/utf8>> => #{}, tag => [{<<"F">>, 1070010001}, {<<"E">>, 1070010001}]}
%%%
%%% Created : 03. 九月 2018 上午10:33
%%%-------------------------------------------------------------------
-module(erl_trie).

-include("erl_pub.hrl").

%%-compile(export_all).

-export([
    new/2,
    search/2, search_max/3, search_max/2
]).

%% 初始化
new(Trie, Data) ->
    lists:foldl(
        fun({Item, Mark}, TrieAcc) ->
            if
                Item =:= [] -> TrieAcc;
                true -> add(TrieAcc, Item, Mark)
            end
        end, Trie, Data).


%% 1.计算分支中老的节点更新
%% 2.计算分支中新的节点
add(Dict, Keys, Mark) ->
%%    ?INFO("aaa:~tp", [[Dict, Keys, Mark]]),
    case add_item(Dict, Keys, Mark, []) of
        {nothing, _Tree, _KeysH} -> Dict;
        {new_branch, NewBranch, KeysH} ->
%%            ?INFO("new_branch:~tp", [[NewBranch, KeysH]]),
            if
                KeysH =:= [] -> NewBranch;
                true ->
                    {_, KVDicts} = lists:foldl(
                        fun(Key, {DictAcc, NewBranchDictAcc}) ->
                            {ok, DictChild} = dict:find(Key, DictAcc),
                            {DictChild, [DictChild | NewBranchDictAcc]}
                        end, {Dict, []}, KeysH),
                    {NewTree, _} = lists:foldl(
                        fun(KV, {TreeAcc, [H | SkipWords]}) ->
%%                            ?INFO("bbb:~tp", [[TreeAcc, H, KV]]),
                            NewTreeAcc =
                                if
                                    length([H | SkipWords]) =:= length(KeysH) ->
                                        dict:store(H, NewBranch, dict:new());
                                    true ->
                                        Val = dict:fold(fun(K, V, DictAcc) ->
                                            dict:store(K, V, DictAcc) end, KV, TreeAcc),
                                        dict:store(H, Val, dict:new())
                                end,

                            {NewTreeAcc, SkipWords}
                        end, {dict:new(), lists:reverse(KeysH)}, KVDicts),
%%                    ?INFO("ccc:~tp", [[Dict, NewTree]]),
                    dict:fold(fun(K, V, DictAcc) -> dict:store(K, V, DictAcc) end, Dict, NewTree)
            end;

        {reset, NewBranch, KeysH} ->
%%            ?INFO("reset:~tp", [[NewBranch, KeysH]]),
            if
                KeysH =:= [] ->
                    dict:fold(fun(K, V, DictAcc) -> dict:store(K, V, DictAcc) end, Dict, NewBranch);
                true ->
%%                    ?INFO("ddd:~tp", [[NewBranch, KeysH]]),
                    {_, KVs} = lists:foldl(
                        fun(Key, {DictAcc, NewBranchDictAcc}) ->
                            {ok, DictChild} = dict:find(Key, DictAcc),
                            {DictChild, [DictChild | NewBranchDictAcc]}
                        end, {Dict, []}, KeysH),

                    {NewTree, _} = lists:foldl(
                        fun(KV, {TreeAcc, [H | SkipWords]}) ->
                            NewTreeAcc =
                                if
                                    length([H | SkipWords]) =:= length(KeysH) ->
                                        dict:store(H, NewBranch, dict:new());
                                    true ->
                                        Val = dict:fold(fun(K, V, DictAcc) ->
                                            dict:store(K, V, DictAcc) end, KV, TreeAcc),
                                        dict:store(H, Val, dict:new())
                                end,
                            {NewTreeAcc, SkipWords}
                        end, {dict:new(), lists:reverse(KeysH)}, KVs),
%%                    ?INFO("eee:~tp", [NewTree]),
                    dict:fold(fun(K, V, DictAcc) -> dict:store(K, V, DictAcc) end, Dict, NewTree)
            end
    end.


add_item(Dict, [H | RWords], Mark, KeysH) ->
    case dict:find(H, Dict) of
        {ok, DictChild} ->
            if
                RWords =:= [] ->
                    case dict:find(mark, DictChild) of
                        error ->
                            Val = dict:store(mark, [Mark], dict:new()),
                            {reset, dict:store(H, Val, Dict), KeysH};
                        {ok, OldMark} ->
                            case lists:member(Mark, OldMark) of
                                true ->
                                    {nothing, Dict, KeysH};
                                false ->
                                    Val = dict:store(mark, [Mark | OldMark], DictChild),
                                    {reset, dict:store(H, Val, Dict), KeysH}
                            end
                    end;
                true -> add_item(DictChild, RWords, Mark, KeysH ++ [H])
            end;
        error ->
            NewBranch =
                if
                    RWords =:= [] ->
                        dict:store(mark, [Mark], dict:new());
                    true -> new_branch(lists:reverse(RWords), Mark)
                end,
            {new_branch, dict:store(H, NewBranch, Dict), KeysH}
    end.


new_branch([Char], Mark) ->
    D1 = dict:store(mark, [Mark], dict:new()),
    dict:store(Char, D1, dict:new());
new_branch([Char | R], Markup) ->
    D1 = dict:store(mark, [Markup], dict:new()),
    Dict = dict:store(Char, D1, dict:new()),
    new_acc(R, Dict).

new_acc([Char], DictAcc) -> dict:store(Char, DictAcc, dict:new());
new_acc([Char | R], DictAcc) -> new_acc(R, dict:store(Char, DictAcc, dict:new())).


search(Dict, Input) -> search(Dict, Input, []).

search(_Dict, [], Acc) -> lists:reverse(Acc);
search(Dict, [H | Lists], Acc) ->
    case search(Dict, [H | Lists], [], []) of
        [] -> search(Dict, Lists, [{skip, H} | Acc]);
        MatchWords -> [search(Dict, RLists, [{match, Words, Markup} | Acc]) || {RLists, Words, Markup} <- MatchWords]
    end.


%% @doc 一次匹配中匹配出的所有情况
search(_Dict, [], _Words, Acc) -> Acc;
search(Dict, [H | Lists], Words, Acc) ->
    case dict:find(H, Dict) of
        error ->
            if
                Acc == [] -> Acc;
                true -> Acc
            end;
        {ok, DictChild} ->
            case dict:find(mark, DictChild) of
                error ->
                    search(DictChild, Lists, Words ++ [H], Acc);
                {ok, Markup} ->
                    search(DictChild, Lists, Words ++ [H], [{Lists, Words ++ [H], Markup} | Acc])
            end
    end.


search_max(Dict, Input) -> search_max(Dict, Input, []).

search_max(_Dict, [], Acc) -> lists:reverse(Acc);
search_max(Dict, Lists, Acc) ->
    case search_max(Dict, Lists, <<>>, []) of
        error ->
            [H | R] = Lists,
            search_max(Dict, R, [{skip, H} | Acc]);
        {RLists, Words, Markup} ->
            search_max(Dict, RLists, [{match, Words, Markup} | Acc])
    end.


search_max(_Tree, [], Words, Acc) -> {[], Words, Acc};
search_max(Tree, [Char | R], Words, Acc) ->
    case maps:find(Char, Tree) of
        error ->
            if
                Acc == [] -> error;
                true -> {[Char | R], Words, Acc}
            end;
        {ok, TreeChild} ->
            case maps:find(mark, TreeChild) of
                error -> search_max(TreeChild, R, Words ++ [Char], Acc);
                {ok, Markup} -> search_max(TreeChild, R, Words ++ [Char], Markup)
            end
    end.
