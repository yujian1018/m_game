%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 28. 十二月 2017 下午5:20
%%%-------------------------------------------------------------------
-module(t_tpl).

-export([
    render/2
]).

render(Tpl, Datas) ->
    lists:foldl(
        fun({K, V}, Acc) ->
            binary:replace(Acc, K, V, [global])
        end,
        Tpl,
        Datas).
