%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 对称加密算法
%%% 常见的对称加密算法有DES、3DES、AES、Blowfish、IDEA、RC5、RC6。
%%%
%%% Created : 02. 一月 2019 下午3:55
%%%-------------------------------------------------------------------
-module(erl_scrypto).

-export([
    des3_encode/3, des3_decode/3
]).


des3_encode(Key, Ivec, Text) ->
    crypto:block_encrypt(des3_cbc, [Key, Key, Key], Ivec, padding('PKCS7',Text)).

des3_decode(Key, Ivec, Text) ->
    crypto:block_decrypt(des3_cbc, [Key, Key, Key], Ivec, Text).


%% 填充算法 PKCS7
padding('PKCS7', Bin) ->
    ByteSize = byte_size(Bin),
    N = ByteSize rem 8,
    if
        N =:= 7 ->
            <<Bin/binary, 1:8>>;
        N =:= 6 ->
            <<Bin/binary, 2:8, 2:8>>;
        N =:= 5 ->
            <<Bin/binary, 3:8, 3:8, 3:8>>;
        N =:= 4 ->
            <<Bin/binary, 4:8, 4:8, 4:8, 4:8>>;
        N =:= 3 ->
            <<Bin/binary, 5:8, 5:8, 5:8, 5:8, 5:8>>;
        N =:= 2 ->
            <<Bin/binary, 6:8, 6:8, 6:8, 6:8, 6:8, 6:8>>;
        N =:= 1 ->
            <<Bin/binary, 7:8, 7:8, 7:8, 7:8, 7:8, 7:8, 7:8>>;
        N =:= 0 ->
            <<Bin/binary, 8:8, 8:8, 8:8, 8:8, 8:8, 8:8, 8:8, 8:8>>
    end.