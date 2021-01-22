%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 最小编辑距离算法
%%% 动态规划方程(done) https://blog.csdn.net/qq_34552886/article/details/72556242
%%% https://segmentfault.com/a/1190000004864746
%%% https://segmentfault.com/a/1190000012769863
%%% 列划分算法 https://www.cnblogs.com/haolujun/p/9527776.html
%%% Created : 05. 九月 2018 下午3:48
%%%-------------------------------------------------------------------
-module(erl_EditDistance).

%%-compile(export_all).

-export([
    edit_distance/2,
    min/2,
    edit_distance_item/2
]).

min(X, Y) ->
    if
        X < Y -> X;
        true -> Y
    end.

edit_distance(Bin, BinLists) ->
    BinSize = byte_size(Bin),
    lists:min(
        lists:map(
            fun(BinItem) ->
                if
                    (BinSize - byte_size(BinItem)) > 6 -> 7;
                    true -> algo:edit_distance(Bin, BinItem)
                end
            end,
            BinLists)).

edit_distance_item(List1, List2) ->
    if
        List1 =:= [] -> length(List2);
        List2 =:= [] -> length(List1);
        true ->
            if
                hd(List1) =:= hd(List2) ->
                    edit_distance_item(tl(List1), tl(List2));
                true ->
                    EdIns = edit_distance_item(List1, tl(List2)) + 1,
                    EdDel = edit_distance_item(tl(List1), List2) + 1,
                    EdRep = edit_distance_item(tl(List1), tl(List2)) + 1,
                    erl_EditDistance:min(erl_EditDistance:min(EdIns, EdDel), EdRep)
            end
    end.