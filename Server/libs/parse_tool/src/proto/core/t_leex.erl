%#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -I include/ -pa ebin/ ../common/ebin
%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 21. 三月 2016 下午5:27
%%%-------------------------------------------------------------------
-module(t_leex).

-include("t_scan.hrl").

-export([get_type/1]).

-export([
    'Nonterminals'/0,
    'Separators'/0,
    is_atom/1,
    is_char/1,
    is_integer/1,
    is_keywords/1,
    is_type/1
]).

'Nonterminals'() -> [].


'Separators'() -> binary:split(<<"{ } , = : < > [ ]">>, <<" ">>, [global, trim_all]).


'Keywords'() -> binary:split(<<"enum struct proto server client all_proto">>, <<" ">>, [global, trim_all]).


'Type'() ->
    binary:split(<<"u4 u8 u16 u32 u64 s4 s8 s16 s32 s64 sstr lstr atom binary string list llist">>, <<" ">>, [global, trim_all]).


atom() -> "[a-z][0-9a-zA-Z_]*".


char() -> "[A-Z_][0-9a-zA-Z_]*".


integer() -> "[+|-]?[0-9]*".


is_type(Chars) ->
    case lists:member(Chars, 'Type'()) of
        true -> type;
        false -> false
    end.

is_keywords(Chars) ->
    case lists:member(Chars, 'Keywords'()) of
        true -> keywords;
        false -> false
    end.

is_char(Chars) ->
    Size = byte_size(Chars),
    case re:run(Chars, char()) of
        {match, [{0, Size}]} -> 'char';
        _ -> false
    end.

is_atom(Chars) ->
    Size = byte_size(Chars),
    case re:run(Chars, atom()) of
        {match, [{0, Size}]} -> 'atom';
        _ -> false
    end.

is_integer(Chars) ->
    Size = byte_size(Chars),
    case re:run(Chars, integer()) of
        {match, [{0, Size}]} -> integer;
        _ -> false
    end.

get_type(Chars) ->
    case can([
        fun() -> is_type(Chars) end,
        fun() -> is_keywords(Chars) end,
        fun() -> t_leex:is_integer(Chars) end,
        fun() -> t_leex:is_atom(Chars) end,
        fun() -> is_char(Chars) end
    ]) of
        false -> ?ERROR("syntax error, canot find type :~p~n", [Chars]);
        Ret -> Ret
    end.


can([]) -> false;
can([Fun | FList]) ->
    case Fun() of
        false -> can(FList);
        Ret -> Ret
    end.