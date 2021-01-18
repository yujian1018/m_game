%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%% Created : 23. 一月 2016 上午11:24
%%%-------------------------------------------------------------------
-module(sdk_http_taobao).

-export([sms/0]). %淘宝短信api，以及淘宝开放平台通用数据组装

timestamp() ->
    {{Y, Mon, D}, {H, Min, S}} = erlang:localtime(),
    YBin = integer_to_binary(Y),
    Fun = fun(Num) ->
        if
            Num >= 10 ->
                integer_to_binary(Num);
            true ->
                NumBin = integer_to_binary(Num),
                <<"0", NumBin/binary>>
        end
          end,
    MonBin = Fun(Mon),
    DBin = Fun(D),
    HBin = Fun(H),
    MinBin = Fun(Min),
    Sbin = Fun(S),
    <<YBin/binary, "-", MonBin/binary, "-", DBin/binary, " ", HBin/binary, ":", MinBin/binary, ":", Sbin/binary>>.


sms() ->
    Arg = [{<<"app_key">>, <<"111">>},
        {<<"method">>, <<"alibaba.aliqin.fc.sms.num.send">>},
        {<<"rec_num">>, <<"18721112975">>},
        {<<"format">>, <<"json">>},
        {<<"partner_id">>, <<"ping">>},
        {<<"v">>, <<"2.0">>},
        {<<"sms_type">>, <<"normal">>},
        {<<"sms_template_code">>, <<"SMS_3755236">>},
        {<<"sms_param">>, <<"{\"product\":\"test\"}">>},
        {<<"sms_free_sign_name">>, <<"注册验证"/utf8>>},
        {<<"timestamp">>, timestamp()},
        {<<"sign_method">>, <<"md5">>}],


    Arg1 = lists:foldl(
        fun({Key, Value}, Acc) ->
            <<Acc/binary, Key/binary, Value/binary>>
        end,
        <<>>,
        lists:sort(Arg)
    ),
    io:format( "000:~ts~n", [ Arg1 ] ),
    <<Bin:128>> = crypto:hash(md5, <<"1", Arg1/binary, "2">>),
    Sign = list_to_binary(string:to_upper(lists:flatten(io_lib:format("~32.16.0b", [Bin])))),

    Arg2 = cow_qs:qs(Arg),
    io:format("111:~p~n", [<<Arg2/binary, "&sign=", Sign/binary>>]),
    httpc:request(post, {"http://gw.api.taobao.com/router/rest", [], "application/x-www-form-urlencoded;charset=utf-8", <<Arg2/binary, "&sign=", Sign/binary>>}, [], []).
