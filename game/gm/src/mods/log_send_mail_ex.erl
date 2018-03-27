%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 23. 三月 2017 下午5:00
%%%-------------------------------------------------------------------
-module(log_send_mail_ex).

-include("gm_pub.hrl").

-export([insert/2]).

insert(_TabName, Args) ->
    Uid = list_can:exit_v_not_null(<<"uid">>, Args),
    ChannelId = binary_to_integer(list_can:exit_v_not_null(<<"channel_id">>, Args)),
    Title = list_can:exit_v_not_null(<<"title">>, Args),
    Content = list_can:exit_v_not_null(<<"content">>, Args),
    Appendix = list_can:exit_v(<<"appendix">>, Args),
    case erl_mysql:execute(pool_dynamic_1, <<"select channel_id from attr where uid = '", Uid/binary, "';">>) of
        [[ChannelId]] ->
            case redis_online:is_online(Uid) of
                {ok, Node, _Pid} ->
                    NewAppendix =
                        case Appendix of
                            <<"">> -> <<>>;
                            Appendix -> ?decode(Appendix)
                        end,
                    rpc:call(Node, mail_handler, add_mail_to_client, [0, binary_to_integer(Uid), Title, Content, NewAppendix]);
                false ->
                    CTimes = erl_time:now(),
                    erl_mysql:execute(pool_dynamic_1, <<"INSERT INTO mail (uid, from_uid, receive_time, title, info, appendix) VALUES (",
                        Uid/binary, ", 0, ",
                        (integer_to_binary(CTimes))/binary, ", '",
                        Title/binary, "', '",
                        Content/binary, "', '",
                        Appendix/binary, "');">>)
            
            end,
            R2 = [{K, V} || {K, V} <- Args, V =/= <<>>],
            FunFoldl =
                fun({K, V}, Record) ->
                    {Index, NewV} = log_send_mail:to_index(K, V),
                    setelement(Index, Record, NewV)
                end,
            VO = lists:foldl(FunFoldl, log_send_mail:record(), R2),
            log_send_mail:insert(VO);
        _ ->
            ?return_err(?ERR_CHANNEL_ID)
    end.
    