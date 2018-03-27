%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 14. 十一月 2017 下午7:31
%%%-------------------------------------------------------------------
-module(mail_mng_ex).


-include("gm_pub.hrl").

-export([
    select/6,
    insert/2,
    update/2,
    delete/2,
    lookup/2
]).

select(_Mod, List, StartIndex, _SortKey, _SortType, _SqlEx) ->
    List1 = lists:keydelete(<<"appendix">>, 1, List),
    SelectArg = lists:foldl(
        fun({Field, Item}, Acc) ->
            case binary_can:illegal_character(Item) of
                false -> Acc;
                true ->
                    Kv = case binary:match(Field, <<"_begin">>) of
                             nomatch ->
                                 case binary:match(Field, <<"_end">>) of
                                     nomatch ->
                                         case binary:match(Field, <<"_times">>) of
                                             nomatch ->
                                                 <<"`", Field/binary, "`='", Item/binary, "'">>;
                                             {_Index3, _Pos3} ->
                                                 <<"`", Field/binary, "`='", (integer_to_binary(erl_time:time2timer(Item)))/binary, "'">>
                                         end;
                                     {Index2, _Pos2} ->
                                         Field2 = binary:part(Field, 0, Index2),
                                         <<"`", Field2/binary, "`<", (integer_to_binary(erl_time:time2timer(Item)))/binary>>
                                 end;
                             {Index, _Pos} ->
                                 Field1 = binary:part(Field, 0, Index),
                                 <<"`", Field1/binary, "`>=", (integer_to_binary(erl_time:time2timer(Item)))/binary>>
                         end,
                    if
                        Acc =:= <<>> -> Kv;
                        true -> <<Acc/binary, " AND ", Kv/binary>>
                    end
            
            end
        end,
        <<>>,
        List1),
    Sql =
        if
            SelectArg =:= <<>> ->
                <<"select count(*) from mail_mng; select a.`id`, `channel_id`, `a_times`, `d_times`, `e_time`, `type`, `mail_id`, `limit`, `op_state`, b.title, b.content, b.prize_id from mail_mng as a, config_mail as b where mail_id = b.id limit ", (integer_to_binary(StartIndex))/binary, ", 60;">>;
            true ->
                <<"select count(*) from mail_mng where ", SelectArg/binary, "; select a.`id`, `channel_id`, `a_times`, `d_times`, `e_time`, `type`, `mail_id`, `limit`, `op_state`, b.title, b.content, b.prize_id from mail_mng as a, config_mail as b where ", SelectArg/binary, " and a.mail_id = b.id limit ", (integer_to_binary(StartIndex))/binary, ", 60;">>
        end,
    [[[Count]], Ret] = db_mysql:execute(pool_static_1, Sql),
    Fun =
        fun([ID, CHANNEL_ID, A_TIMES, D_TIMES, E_TIME, TYPE, MAIL_ID, LIMIT, OP_STATE, TITLE, CONTENT, PRIZE_ID]) ->
            {[{<<"id">>, ID}, {<<"channel_id">>, CHANNEL_ID}, {<<"a_times">>, A_TIMES}, {<<"d_times">>, D_TIMES},
                {<<"e_time">>, E_TIME}, {<<"type">>, TYPE}, {<<"mail_id">>, MAIL_ID}, {<<"limit">>, LIMIT},
                {<<"title">>, TITLE}, {<<"content">>, CONTENT}, {<<"appendix">>, PRIZE_ID}, {<<"op_state">>, OP_STATE}]}
        end,
    {Count, lists:map(Fun, Ret)}.


insert(_TabName, Args) ->
    Title = list_can:exit_v_not_null(<<"title">>, Args),
    Content = list_can:exit_v_not_null(<<"content">>, Args),
    PrizeId = binary_to_integer(list_can:get_arg(<<"appendix">>, Args, <<"0">>)),
    
    ATimes = list_can:exit_v_not_null(<<"a_times">>, Args),
    DTimes = list_can:exit_v_not_null(<<"d_times">>, Args),
    ETime = list_can:exit_v_not_null(<<"e_time">>, Args),
    Type = list_can:get_arg(<<"type">>, Args),
    Limit = list_can:get_arg(<<"limit">>, Args),
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Args),
    OpState = list_can:get_arg(<<"op_state">>, Args, <<"0">>),
    
    FunFoldl =
        fun({K, V}, Record) ->
            {Index, NewV} = mail_mng:to_index(K, V),
            setelement(Index, Record, NewV)
        end,
    VO = lists:foldl(FunFoldl, mail_mng:record(), [{<<"a_times">>, ATimes}, {<<"d_times">>, DTimes}, {<<"e_time">>, ETime},
        {<<"type">>, Type}, {<<"limit">>, Limit}, {<<"channel_id">>, ChannelId}, {<<"op_state">>, OpState}]),
    
    MailId = config_mail:insert(#config_mail{title = Title, content = Content, prize_id = PrizeId}),
    mail_mng:insert(VO#mail_mng{mail_id = MailId}),
    sys_handler:reload_tabs(<<"config_mail">>),
    global_rpc:rpc_mgr_server(?gm, mgr_server, reload_cache, [cache_mail_mng]).



update(_TabName, Args) ->
    MailId = binary_to_integer(list_can:exit_v_not_null(<<"mail_id">>, Args)),
    Title = list_can:exit_v_not_null(<<"title">>, Args),
    Content = list_can:exit_v_not_null(<<"content">>, Args),
    PrizeId = binary_to_integer(list_can:exit_v_not_null(<<"appendix">>, Args)),
    
    Id = list_can:exit_v_not_null(<<"id">>, Args),
    ATimes = list_can:exit_v_not_null(<<"a_times">>, Args),
    DTimes = list_can:exit_v_not_null(<<"d_times">>, Args),
    ETime = list_can:exit_v_not_null(<<"e_time">>, Args),
    Type = list_can:get_arg(<<"type">>, Args),
    Limit = list_can:get_arg(<<"limit">>, Args),
    ChannelId = list_can:exit_v_not_null(<<"channel_id">>, Args),
    OpState = list_can:exit_v_not_null(<<"op_state">>, Args),
    
    FunFoldl =
        fun({K, V}, Record) ->
            {Index, NewV} = mail_mng:to_index(K, V),
            setelement(Index, Record, NewV)
        end,
    VO = lists:foldl(FunFoldl, mail_mng:record(), [{<<"id">>, Id}, {<<"a_times">>, ATimes}, {<<"d_times">>, DTimes}, {<<"e_time">>, ETime},
        {<<"type">>, Type}, {<<"limit">>, Limit}, {<<"channel_id">>, ChannelId}, {<<"op_state">>, OpState}]),
    
    config_mail:update(#config_mail{id = MailId, title = Title, content = Content, prize_id = PrizeId}),
    mail_mng:update(VO),
    sys_handler:reload_tabs(<<"config_mail">>),
    global_rpc:rpc_mgr_server(?gm, mgr_server, reload_cache, [cache_mail_mng]).


delete(_TabNameMod, Keys) ->
    [{K, V}] = Keys,
    {_Index, NewV} = mail_mng:to_index(K, V),
    MailMng = mail_mng:lookup(NewV),
    mail_mng:delete(NewV),
    config_mail:delete(MailMng#mail_mng.mail_id),
    sys_handler:reload_tabs(<<"config_mail">>),
    global_rpc:rpc_mgr_server(?gm, mgr_server, reload_cache, [cache_mail_mng]).

lookup(_TbMod, Keys) ->
    [{K, V}] = Keys,
    {_Index, NewV} = mail_mng:to_index(K, V),
    MailMng = mail_mng:lookup(NewV),
    ConfigMail = config_mail:lookup(MailMng#mail_mng.mail_id),
    [{<<"id">>, MailMng#mail_mng.id}, {<<"channel_id">>, MailMng#mail_mng.channel_id}, {<<"a_times">>, MailMng#mail_mng.a_times},
        {<<"d_times">>, MailMng#mail_mng.d_times}, {<<"e_time">>, MailMng#mail_mng.e_time},
        {<<"type">>, MailMng#mail_mng.type}, {<<"mail_id">>, MailMng#mail_mng.mail_id}, {<<"limit">>, MailMng#mail_mng.limit},
        {<<"title">>, ConfigMail#config_mail.title}, {<<"content">>, ConfigMail#config_mail.content},
        {<<"appendix">>, ConfigMail#config_mail.prize_id}, {<<"op_state">>, MailMng#mail_mng.op_state}].