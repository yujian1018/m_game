%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 12. 五月 2017 下午5:38
%%%-------------------------------------------------------------------
-module(sign_token).

-include("erl_pub.hrl").

-export([
    jwt/0, jwt/3,
    sign/2
]).


jwt(AuthHeader, AuthClaimSet, RsaKey) ->
    SignInput = <<(b64_encode(AuthHeader))/binary, ".", (b64_encode(AuthClaimSet))/binary>>,

%%    [Entry] = public_key:pem_decode(Rsa),
%%    RsaPrivate = public_key:pem_entry_decode(Entry),
    Hex = public_key:sign(SignInput, sha256, RsaKey),

%%    Rsa = <<"secret">>,
%%    Hex = crypto:hmac(sha256, Rsa, SignInput),

    <<SignInput/binary, ".", (b64_encode(Hex))/binary>>.


jwt() ->
    AuthHeader = <<"{\"alg\":\"RS256\",\"typ\":\"JWT\"}">>,
    AuthClaimSet = <<"{\"sub\":\"1234567890\",\"name\":\"John Doe\",\"admin\":true}">>,
    PemBin = <<"-----BEGIN RSA PRIVATE KEY-----\nMIICWwIBAAKBgQDdlatRjRjogo3WojgGHFHYLugdUWAY9iR3fy4arWNA1KoS8kVw33cJibXr8bvwUAUparCwlvdbH6dvEOfou0/gCFQsHUfQrSDv+MuSUMAe8jzKE4qW+jK+xQU9a03GUnKHkkle+Q0pX/g6jXZ7r1/xAK5Do2kQ+X5xK9cipRgEKwIDAQABAoGAD+onAtVye4ic7VR7V50DF9bOnwRwNXrARcDhq9LWNRrRGElESYYTQ6EbatXS3MCyjjX2eMhu/aF5YhXBwkppwxg+EOmXeh+MzL7Zh284OuPbkglAaGhV9bb6/5CpuGb1esyPbYW+Ty2PC0GSZfIXkXs76jXAu9TOBvD0ybc2YlkCQQDywg2R/7t3Q2OE2+yo382CLJdrlSLVROWKwb4tb2PjhY4XAwV8d1vy0RenxTB+K5Mu57uVSTHtrMK0GAtFr833AkEA6avx20OHo61Yela/4k5kQDtjEf1N0LfI+BcWZtxsS3jDM3i1Hp0KSu5rsCPb8acJo5RO26gGVrfAsDcIXKC+bQJAZZ2XIpsitLyPpuiMOvBbzPavd4gY6Z8KWrfYzJoI/Q9FuBo6rKwl4BFoToD7WIUS+hpkagwWiz+6zLoX1dbOZwJACmH5fSSjAkLRi54PKJ8TFUeOP15h9sQzydI8zJU+upvDEKZsZc/UhT/SySDOxQ4G/523Y0sz/OZtSWcol/UMgQJALesy++GdvoIDLfJX5GBQpuFgFenRiRDabxrE9MNUZ2aPFaFp+DyAe+b4nDwuJaW2LURbr8AEZga7oQj0uYxcYw==\n-----END RSA PRIVATE KEY-----\n">>,
    [Entry] = public_key:pem_decode(PemBin),
    RsaKey = public_key:pem_entry_decode(Entry),
    jwt(AuthHeader, AuthClaimSet, RsaKey).


b64_encode(Key) ->
    BaseKey = base64:encode(Key),
    BaseKey2 = binary:replace(BaseKey, <<"+">>, <<"-">>, [global]),
    BaseKey3 = binary:replace(BaseKey2, <<"/">>, <<"_">>, [global]),
    binary:replace(BaseKey3, <<"=">>, <<"">>, [global]).



sign(Sign, Times) ->
    TimesInt = binary_to_integer(Times),
    Now = erl_time:now(),
    if
        abs(TimesInt - Now) =< (?TIMEOUT_MO_1 / 1000) ->
            erl_bin:to_lower(erl_hash:md5_bin(<<"date=", Times/binary, "&key=3e1a34f2fe775e8b95cf021547462c15">>)) =:= Sign;
        true ->
            false
    end.