%%%-------------------------------------------------------------------
%%% @author yj
%%% @doc 非对称加密算法 RSA
%%% 公开密钥加密（英语：public-key cryptography，又译为公开密钥加密），也称为非对称加密（asymmetric cryptography），
%%% 一种密码学算法类型，在这种密码学方法中，需要一对密钥(其实这里密钥说法不好，就是“钥”)，一个是私人密钥，另一个则是公开密钥。
%%% 这两个密钥是数学相关，用某用户密钥加密后所得的信息，只能用该用户的解密密钥才能解密。
%%% 如果知道了其中一个，并不能计算出另外一个。因此如果公开了一对密钥中的一个，并不会危害到另外一个的秘密性质。
%%% 称公开的密钥为公钥；不公开的密钥为私钥。
%%%
%%% Created : 02. 一月 2019 下午3:57
%%%-------------------------------------------------------------------
-module(erl_acrypto).

-export([
    rsa_decode/1,
    rsa_encode/1
]).


%% 公钥
-define(RSAPublicKey, <<"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDSfAH41yVn2uKDdRanLxsgFmkU\nBtOM8TFaqnUFA82lhm4ey9/9d8CMn/dzngt/PPnUuLWz0HMyMjBf/2hWL6HinXha\nNt0E4KcwYTHJkpmUxOTTyQSO++OvIwblsMYnaotnx5+jvEeditzLffFJa0QzdDwb\nEdmNym66fQ8gHqB8LwIDAQAB\n-----END PUBLIC KEY-----\n\n">>).
%% 私密
-define(RSAPrivateKey, <<"-----BEGIN RSA PRIVATE KEY-----\nMIICXgIBAAKBgQDSfAH41yVn2uKDdRanLxsgFmkUBtOM8TFaqnUFA82lhm4ey9/9\nd8CMn/dzngt/PPnUuLWz0HMyMjBf/2hWL6HinXhaNt0E4KcwYTHJkpmUxOTTyQSO\n++OvIwblsMYnaotnx5+jvEeditzLffFJa0QzdDwbEdmNym66fQ8gHqB8LwIDAQAB\nAoGBALj3sOP0bTKu74+GPbn9c2DnUMAAn7ej3TNHyD338agcUnlNwDEGI3dwvAwm\nPwQ5mXKOP18dN55M7KXv1MioYyEhIZ8yyyBKPvTaQFrHHojRU3NI8h8psLhlZG+X\nmk0aALFHJ0S+WlWtlHv78SAWquJQ1yfhWDuq35JIW9z10TNBAkEA+ZxdVceBHna5\nTEImFiZ5rbcPk1UowjbKA//1Ex2apdLiTW33UpJN1o5tnz1v/xhGITLlfr7xYkYn\nm3yu9NI9GwJBANffQgZXUs2tv7Dhmv1QpeI+6/Jhc0JRLNroQ70Dq6bAyttFke5R\nQwJ1Xp1kCJy76Dj/yFSfp/NBukhQhlmSUn0CQQCSqGbGgaPBrGwO/Ea4eP7BLG/A\nVybNhbeIRhlOk/RLPe6tI9FO+Js3VxPdnhFxxmdeFjN1FudooGOhHc8GFYjFAkBy\nYkQz4/VmMpiN+x0K+L7NIRYYunY+P5EK9WNfNiCwHRvgD/8BTmG5XcOilizSD+c+\nvJnD7U0q4jr4smJd9+BpAkEAhBa5viehhdKK48KgP9lAHi5wIDs9VkZ4QNFBJE0U\nosGA3JXjMUW8SItgMWcv9lkrfceLfUpapZSBpQz1v5oNnA==\n-----END RSA PRIVATE KEY-----\n\n">>).


rsa_decode(CipherText) ->
    [Entry] = public_key:pem_decode(?RSAPrivateKey),
    RsaEntry = public_key:pem_entry_decode(Entry),
    public_key:decrypt_private(CipherText, RsaEntry).


rsa_encode(Text) ->
    [Entry] = public_key:pem_decode(?RSAPublicKey),
    RsaEntry = public_key:pem_entry_decode(Entry),
    public_key:encrypt_public(Text, RsaEntry).