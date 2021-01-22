%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc
%%%
%%% Created : 02. 一月 2019 上午11:55
%%%-------------------------------------------------------------------
-module(t_crypto).

-include("erl_pub.hrl").
-include_lib("public_key/include/public_key.hrl").

-compile(export_all).

-export([test/0]).

test() ->
    K = <<"01234567">>,
    Key = [K, K, K],
    Ivec = <<"abcdefgh">>,

    Text = <<"Nowisthetimeforallaaabbbcccdddee">>,
    Ciphertext = crypto:block_encrypt(des3_cbc, Key, Ivec, padding(Text)),


    Fun =
        fun(Int) ->
            Bin = erlang:integer_to_binary(Int, 16),
            case byte_size(Bin) of
                2 -> Bin;
                1 -> <<"0", Bin/binary>>
            end
        end,
    ?DEBUG("ret:~tp~n", [[Ciphertext, base64:encode(Ciphertext), iolist_to_binary([Fun(I) || <<I:8>> <= Ciphertext])]]),

    crypto:block_decrypt(des3_cbc, Key, Ivec, Ciphertext).

%% 填充算法 PKCS7
padding(Bin) ->
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



read_rsa_key(FileName) ->
    {ok, PemBin} = file:read_file(FileName),
    [Entry] = public_key:pem_decode(PemBin),
    public_key:pem_entry_decode(Entry).

rsa_public_key() ->
    read_rsa_key("/home/yj/.ssh/id_rsa").

rsa_private_key() ->
    read_rsa_key("/home/yj/.ssh/id_rsa.pub").

enc(PlainText) ->
    public_key:encrypt_public(PlainText, rsa_public_key()).

dec(CipherText) ->
    public_key:decrypt_private(CipherText, rsa_private_key()).

test(Msg) ->
    CipherText = enc(Msg),
    ?DEBUG("plain text:~p, cipher text:~p~n", [Msg, CipherText]),
    PlainText = dec(CipherText),
    ?DEBUG("plain text after decode:~p~n", [PlainText]).


set_private_key() ->
    %%获取私钥
    #'RSAPrivateKey'{modulus=Modulus, publicExponent=PublicExponent} = PrivateKey = public_key:generate_key({rsa, 1024, 65537}),
    %%获取公钥
    PublicKey = #'RSAPublicKey'{modulus=Modulus, publicExponent=PublicExponent},
    put(rsa_private_key, PrivateKey),
    put(rsa_public_key, PublicKey),
    {PrivateKey, PublicKey}.

%%密钥转字符串
key_to_list(Pri, Pub) ->
    binary_to_list(public_key:pem_encode([public_key:pem_entry_encode('SubjectPublicKeyInfo',Pub)])),
    binary_to_list(public_key:pem_encode([public_key:pem_entry_encode('RSAPrivateKey',Pri)])).
