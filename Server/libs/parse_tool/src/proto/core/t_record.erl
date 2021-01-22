%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 组装
%%%
%%% Created : 21. 十一月 2016 下午1:28
%%%-------------------------------------------------------------------
-module(t_record).


-include("t_record.hrl").
-include("t_scan.hrl").


-export([
    get_record/1,
    set_anno/3,
    get_anno/3
]).

get_record(<<"proto">>) -> #proto{};
get_record(<<"client">>) -> #proto_item{};
get_record(<<"server">>) -> #proto_item{};

get_record(<<"all_proto">>) -> #all_proto{};

get_record(<<"enum">>) -> #enum{};

get_record(<<"line_constant">>) -> #line_constant{};
get_record(<<"atom_constant">>) -> #atom_constant{};
get_record(<<"atom_constant_2">>) -> #atom_constant_2{};

get_record(_KeyWords) -> ?LOG("no this keyword_record:~p~n", [_KeyWords]).


set_anno(VO, Line, Annos) ->
    case lists:keyfind(Line, 1, Annos) of
        {_, Anno} ->
            Size = tuple_size(VO),
            setelement(Size, VO, Anno);
        _ ->
            VOAnno = get_anno(Line - 1, Annos, <<>>),
            Size = tuple_size(VO),
            setelement(Size, VO, VOAnno)
    end.


get_anno(0, _Annos, _LineAnno) -> _LineAnno;
get_anno(Line, Annos, _LineAnno) ->
    case lists:keyfind(Line, 1, Annos) of
        {_, Anno} ->
            get_anno(Line - 1, Annos, <<Anno/binary, _LineAnno/binary>>);
        _ ->
            _LineAnno
    end.
