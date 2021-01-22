%#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -I include/ -pa ebin/ ../erl/ebin
%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 21. 三月 2016 下午5:27
%%%-------------------------------------------------------------------
-module(t_yecc).

-include("t_scan.hrl").

-export([parse/2, set_grammar/1]).


parse(Tokens, Annos) ->
    parse(Tokens, [], Annos).


parse([], Chunks, _Annos) ->
    lists:reverse(Chunks);

parse([{keywords, Key, Line} | Tokens], Chunks, Annos) ->
    case parse_keywords([{keywords, Key, Line} | Tokens], Annos) of
        {NewTokens, _, Chunk} ->
            parse(NewTokens, [Chunk | Chunks], Annos);
        false ->
            ?ERROR("syntax error, line:~p~n", [Line])
    end;


parse([{_LineKey, Key, Line} | Tokens], Chunks, Annos) ->
    case parse_line([{_LineKey, Key, Line} | Tokens], Annos) of
        {NewTokens, _, Chunk} ->
            parse(NewTokens, [Chunk | Chunks], Annos);
        false ->
            ?ERROR("syntax error, TOKEN:~p~nCHUNKS:~p~n", [{_LineKey, Key, Line}, Chunks])
    end.


%% @doc 根据关键字 解析语法，注意注释
parse_keywords([{keywords, Key, Line} | Tokens], Annos) ->
    Grammars = get_grammar(Key),
    NewR = t_record:set_anno(t_record:get_record(Key), Line, Annos),
    parse_grammars([{keywords, Key, Line} | Tokens], Grammars, Grammars, [], Annos, NewR).


%% @doc 解析行
parse_line([{_LineKey, Key, Line} | Tokens], Annos) ->
    Grammars = get_grammar(<<"line_constant">>),
    NewR = t_record:set_anno(t_record:get_record(<<"line_constant">>), Line, Annos),
    parse_grammars([{_LineKey, Key, Line} | Tokens], Grammars, Grammars, [], Annos, NewR).

%% @doc 根据语法定义解析token
parse_grammars(_Tokens, [], _AllGrammars, _Acc, _Annos, _Record) -> false;
parse_grammars(Tokens, [Grammar | Grammars], AllGrammars, Acc, Annos, Record) ->
    case parse_grammar(Tokens, Grammar, AllGrammars, Acc, Annos, Record) of
        false ->
            parse_grammars(Tokens, Grammars, AllGrammars, Acc, Annos, Record);
        Ret ->
            Ret
    end.


parse_grammar([], [], _AllGrammars, _Acc, _Annos, _Record) ->
    {[], [_Record | _Acc], _Record};

parse_grammar([{'Separators', <<",">>, _} | Tokens], [], AllGrammars, Acc, _Annos, _Record) ->
    H = element(1, _Record),
    Size = size(_Record),
    _NewRecord = list_to_tuple([H, 3 | [undefined || _I <- lists:seq(3, Size)]]),
    parse_grammars(Tokens, AllGrammars, AllGrammars, [_Record | Acc], _Annos, _NewRecord);

parse_grammar(Tokens, [], _AllGrammars, _Acc, _Annos, _Record) ->
    {Tokens, [_Record | _Acc], _Record};

parse_grammar([], _Items, _AllGrammars, _Acc, _Annos, _Record) ->
    false;

parse_grammar([{Type, Token, Line} | Tokens], [Item | ItemR], AllGrammars, Acc, Annos, Record) ->
    case Item of
        <<"'", _O/binary>> ->
            if
                Item =:= <<"'", Token/binary, "'">> ->
                    parse_grammar(Tokens, ItemR, AllGrammars, Acc, Annos, Record);
                true ->
                    false
            end;
        _ ->
            case list_to_binary(atom_to_list(Type)) of
                Item ->
                    Index = element(2, Record),
                    NewR = setelement(Index, Record, Token),
                    NewR1 = setelement(2, NewR, Index + 1),
                    GramsVO = t_record:set_anno(NewR1, Line, Annos),
                    parse_grammar(Tokens, ItemR, AllGrammars, Acc, Annos, GramsVO);
                _ ->
                    case get_grammar(Item) of
                        false ->
                            false;
                        GetGrammars ->
                            GramsVO = t_record:set_anno(t_record:get_record(Item), Line, Annos),
                            case parse_grammars([{Type, Token, Line} | Tokens], GetGrammars, GetGrammars, [], Annos, GramsVO) of
                                false ->
                                    false;
                                {NewTokens, NewAcc, _GrasRecord} ->
                                    Index = element(2, Record),
                                    NewR = setelement(Index, Record, lists:reverse(NewAcc)),
                                    NewR1 = setelement(2, NewR, Index + 1),
                                    parse_grammar(NewTokens, ItemR, AllGrammars, Acc, Annos, NewR1)
                            end
                    end
            end
    end.


get_grammar(Key) ->
    case get(Key) of
        undefined -> false;
        V -> V
    end.


set_grammar(S) ->
%%    {ok, S} = file:read_file(PathFile),
%%    ?LOG("aaaaaaaaaaaaaaaa:~p", [S]),
    %% windows换行符 \r\n -> \n
    S2 = binary:replace(S, <<"\r\n">>, <<"\n">>, [global]),

    FunFoldl =
        fun
            (<<>>, KvList) -> KvList;
            (<<"%", _Other/binary>>, KvList) -> KvList;
            (Line, KvList) ->
                case binary:split(Line, [<<".">>, <<";">>, <<" ">>], [global, trim_all]) of
                    [Key, <<"->">> | R] ->
                        case lists:keytake(Key, 1, KvList) of
                            false ->
                                [{Key, [R]} | KvList];
                            {value, {Key, Rs}, RItems} ->
                                FunSort = fun(R1, R2) -> length(R1) >= length(R2) end,
                                [{Key, lists:sort(FunSort, [R | Rs])} | RItems]
                        end;
                    _Other ->
                        ?ERROR("syntax error, line:~p~n", [Line])
                end
        end,
    List = lists:foldl(FunFoldl, [], binary:split(S2, ?RETURN_CHAR, [global, trim_all])),
    [put(K, V) || {K, V} <- List].
