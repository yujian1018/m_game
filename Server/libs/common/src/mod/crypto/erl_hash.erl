%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc 摘要加密算法
%%% Created : 15. 三月 2016 下午2:45
%%%-------------------------------------------------------------------
-module(erl_hash).

-export([
    md5/1, md5_bin/1,
    
    sha1/1, sha1_bin/1,
    
    hash/2,
    hmac/3

]).

%%[element(C+1, {$0,$1,$2,$3,$4,$5,$6,$7,$8,$9,$A,$B,$C,$D,$E,$F}) || <<C:4>> <= crypto:hash(sha256,"somenewstring")].
%% <<X:256/big-unsigned-integer>> = crypto:hash(sha256,"somenewstring"). integer_to_list(X, 16).

md5(S) ->
    <<M:128/big-unsigned-integer>> = erlang:md5(S),
    Hex = string:to_lower(erlang:integer_to_list(M, 16)),
    Len = length(Hex),
    if
        Len =:= 32 -> Hex;
        Len =:= 31 -> "0" ++ Hex;
        true -> Hex
    end.

md5_bin(Str) ->
    <<M:128/big-unsigned-integer>> = erlang:md5(Str),
    Hex = erlang:integer_to_binary(M, 16),
    Len = byte_size(Hex),
    if
        Len =:= 32 -> Hex;
        Len =:= 31 -> <<"0", Hex/binary>>;
        true -> Hex
    end.

sha1(Bin) ->
    <<M:160/big-unsigned-integer>> = crypto:hash(sha, Bin),
    Hex = string:to_lower(erlang:integer_to_list(M, 16)),
    Len = length(Hex),
    if
        Len =:= 40 -> Hex;
        Len =:= 39 -> "0" ++ Hex;
        true -> Hex
    end.

sha1_bin(Bin) ->
    <<M:160/big-unsigned-integer>> = crypto:hash(sha, Bin),
    Hex = erlang:integer_to_binary(M, 16),
    Len = byte_size(Hex),
    if
        Len =:= 40 -> Hex;
        Len =:= 39 -> <<"0", Hex/binary>>;
        true -> Hex
    end.

hash(sha256, Bin) ->
    <<M:256/big-unsigned-integer>> = crypto:hash(sha256, Bin),
    Hex = erlang:integer_to_binary(M, 16),
    Len = byte_size(Hex),
    if
        Len =:= 64 -> Hex;
        Len =:= 63 -> <<"0", Hex/binary>>;
        true -> Hex
    end.

hmac(Type, Key, Bin) ->
    <<M:256/big-unsigned-integer>> = crypto:hmac(Type, Key, Bin),
    Hex = erlang:integer_to_binary(M, 16),
    Len = byte_size(Hex),
    if
        Len =:= 64 -> Hex;
        Len =:= 63 -> <<"0", Hex/binary>>;
        true -> Hex
    end.


