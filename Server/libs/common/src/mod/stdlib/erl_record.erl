%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 28. 七月 2016 上午11:22
%%%-------------------------------------------------------------------
-module(erl_record).

-export([diff_record/2]).

diff_record(OldRecord, NewRecord) ->
    OldName = element(1, OldRecord),
    NewName = element(1, NewRecord),
    if
        OldName =:= NewName -> OldRecord;
        true ->
            OldLen = tuple_size(OldRecord),
            NewLen = tuple_size(NewRecord),
            diff(OldLen, NewLen, OldRecord, NewRecord, 2)
    end.

diff(OldLen, _NewLen, OldRecord, NewRecord, Len) when OldLen =:= Len ->
    V = element(Len, OldRecord),
    setelement(Len, NewRecord, V);

diff(OldLen, NewLen, OldRecord, NewRecord, Len) ->
    V = element(Len, OldRecord),
    diff(OldLen, NewLen, OldRecord, setelement(Len, NewRecord, V), Len + 1).