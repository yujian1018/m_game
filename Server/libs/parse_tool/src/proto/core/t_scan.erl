%#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -I include/ -pa ebin/ ../common/ebin
%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% 0.过滤出注释
%%% 1.解析成token，注意分隔符\n前后一定有分隔符
%%% 2.根据配置的公式，直接从token中取值
%%% 3.大括号里面每行结束后，一定需要分隔符
%%% Created : 21. 三月 2016 下午5:27
%%%-------------------------------------------------------------------
-module(t_scan).

-include("t_scan.hrl").

-export([main/1]).

main(_Arg) ->
    FilePath = lists:nth(1, _Arg),
    YrlFile = lists:nth(2, _Arg),
    
    put(?file_name, FilePath),
    
    case file:read_file(FilePath) of
        {ok, S} ->
            t_yecc:set_grammar(YrlFile),
            {NewS, Annos} = scan_anno(S, 1, #col{}, <<>>, []),
            Tokens = string(NewS, 1, #col{}, [], 0),
            t_yecc:parse(Tokens, Annos);
        _ ->
            ?ERROR("not found file :~p~n", [FilePath]),
            halt()
    end.


scan_anno(<<>>, Line, Col, CharAcc, Annos) ->
    NewAnnos = if
                   Col#col.type =:= anno -> [{Line, Col#col.char} | Annos];
                   true -> Annos
               end,
    {CharAcc, lists:reverse(NewAnnos)};

scan_anno(<<"\n", Chars/binary>>, Line, Col, CharAcc, Annos) ->
    NewAnnos = if
                   Col#col.type =:= anno -> [{Line, Col#col.char} | Annos];
                   true -> Annos
               end,
    scan_anno(Chars, Line + 1, #col{}, <<CharAcc/binary, "\n">>, NewAnnos);

scan_anno(<<"%", Chars/binary>>, Line, _Col, CharAcc, Annos) when _Col#col.is_scan andalso _Col#col.type =:= anno ->
    scan_anno(Chars, Line, _Col#col{char = <<(_Col#col.char)/binary>>}, CharAcc, Annos);

scan_anno(<<" ", Chars/binary>>, Line, Col, CharAcc, Annos) when Col#col.type =:= anno ->
    scan_anno(Chars, Line, Col#col{char = <<(Col#col.char)/binary, " ">>}, CharAcc, Annos);

scan_anno(<<"%", Chars/binary>>, Line, _Col, CharAcc, Annos) ->
    scan_anno(Chars, Line, _Col#col{type = anno, char = <<>>, is_scan = true}, CharAcc, Annos);

scan_anno(<<Char:1/binary, Chars/binary>>, Line, Col, CharAcc, Annos) when Col#col.type =:= anno ->
    scan_anno(Chars, Line, Col#col{char = <<(Col#col.char)/binary, Char/binary>>}, CharAcc, Annos);

scan_anno(<<Char:1/binary, Chars/binary>>, Line, Col, CharAcc, Annos) ->
    scan_anno(Chars, Line, Col, <<CharAcc/binary, Char/binary>>, Annos).


string(<<>>, Line, Col, Toks, _IsTuple) ->
    Ret = if
              Col#col.char =:= <<>> -> Toks;
              true -> scan_token(Col, Line, Toks)
          end,
    lists:reverse([I || I <- Ret, I =/= []]);

string(<<"\r", Chars/binary>>, Line, Col, Toks, IsTuple) ->
    string(Chars, Line, Col, Toks, IsTuple);

string(<<"\n", Chars/binary>>, Line, Col, Toks, IsTuple) ->
    {NewChars, NewToks, NewLine, NewIsTuple} =
        if
            IsTuple > 0 ->
                if
                    Col#col.char =:= <<>> ->
                        if
                            Toks =:= [] ->
                                {Token2, Chars1, Line1, IsTuple1} = first_char(Chars, Line, IsTuple),
                                {Chars1, [Token2 | Toks], Line1, IsTuple1};
                            true ->
                                if
                                    element(1, hd(Toks)) =:= 'Separators' ->
                                        {Chars, Toks, Line, IsTuple};
                                    true ->
                                        {Token2, Chars1, Line1, IsTuple1} = first_char(Chars, Line, IsTuple),
                                        {Chars1, [Token2 | Toks], Line1, IsTuple1}
                                end
                        end;
                    
                    true ->
                        Toks2 = scan_token(Col, Line, Toks),
                        {Token2, Chars1, Line1, IsTuple1} = first_char(Chars, Line, IsTuple),
                        {Chars1, [Token2 | Toks2], Line1, IsTuple1}
                end;
            true ->
                if
                    Col#col.char =:= <<>> -> {Chars, Toks, Line, IsTuple};
                    true -> {Chars, scan_token(Col, Line, Toks), Line, IsTuple}
                end
        end,
    string(NewChars, NewLine + 1, #col{}, NewToks, NewIsTuple);

string(<<" ", Chars/binary>>, Line, Col, Toks, IsTuple) ->
    string(Chars, Line, #col{}, scan_token(Col, Line, Toks), IsTuple);

string(<<Char:1/binary, Chars/binary>>, Line, Col, Toks, IsTuple) ->
    NewIsTuple = if
                     Char =:= <<"{">> -> IsTuple + 1;
                     Char =:= <<"}">> -> IsTuple - 1;
                     true -> IsTuple
                 end,
    
    case lists:member(Char, t_leex:'Separators'()) of
        true -> %% 特殊符号 分隔符
            Toks2 = scan_token(Col, Line, Toks),
            Toks3 = scan_token(#col{type = 'Separators', char = Char}, Line, Toks2),
            string(Chars, Line, #col{}, Toks3, NewIsTuple);
        false ->
            string(Chars, Line, Col#col{char = <<(Col#col.char)/binary, Char/binary>>}, Toks, NewIsTuple)
    end.


scan_token(Col, Line, Toks) ->
    if
        Col#col.char =:= <<>> -> Toks;
        Col#col.type =:= undefined ->
            Type = t_leex:get_type(Col#col.char),
            [{Type, Col#col.char, Line} | Toks];
        true ->
            [{Col#col.type, Col#col.char, Line} | Toks]
    end.


first_char(<<" ", Chars/binary>>, Line, IsTuple) -> first_char(Chars, Line, IsTuple);
first_char(<<"\r", Chars/binary>>, Line, IsTuple) -> first_char(Chars, Line, IsTuple);
first_char(<<"\n", Chars/binary>>, Line, IsTuple) -> first_char(Chars, Line + 1, IsTuple);
first_char(<<"{", Chars/binary>>, Line, IsTuple) -> {{'Separators', <<"{">>, Line}, Chars, Line, IsTuple + 1};
first_char(<<"}", Chars/binary>>, Line, IsTuple) -> {{'Separators', <<"}">>, Line}, Chars, Line, IsTuple - 1};
first_char(<<Char:1/binary, Chars/binary>>, Line, IsTuple) ->
    case lists:member(Char, t_leex:'Separators'()) of
        true ->
            {{'Separators', Char, Line}, Chars, Line, IsTuple};
        false ->
            ?ERROR("syntax error, no Separators in line:~p char:~p......~n", [Line, binary:part(<<Char:1/binary, Chars/binary>>, 0, 20)])
    end.