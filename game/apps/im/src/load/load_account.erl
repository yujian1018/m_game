%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 28. 六月 2017 上午10:27
%%%-------------------------------------------------------------------
-module(load_account).

-include("im_pub.hrl").

-export([
    get_account/2,
    
    create_i_id/2, del_i_id/2
]).

get_account(AppId, Iid) ->
    ExecRet1 = db_mysql:execute(pool_im, <<"SELECT b.`id` FROM apps AS a, account AS b WHERE a.`app_id` = '", AppId/binary, "' AND a.`id` = b.`apps_id` AND b.`i_id`='", Iid/binary, "';">>),
    case ExecRet1 of
        [[AppsId]] ->
            AppsId;
        _ ->
            ?return_err(?ERR_NO_ACCOUNT)
    end.



create_i_id(AppsId, Iid) ->
    ExecRet1 = db_mysql:execute(pool_im, <<"SELECT `id` FROM account  WHERE `apps_id` = '", AppsId/binary, "' AND `i_id`='", Iid/binary, "';">>),
    case ExecRet1 of
        [[_Id]] ->
            ?return_err(?ERR_EXIT_ACCOUNT);
        _ ->
            Now = integer_to_binary(erl_time:now()),
            db_mysql:execute(pool_im, <<"INSERT INTO account (apps_id, i_id, c_times) VALUES( '", AppsId/binary, "', '", Iid/binary, "', '", Now/binary, "' );">>)
    end.

del_i_id(AppsId, Iid) ->
    db_mysql:execute(pool_im, <<"DELETE FROM account WHERE `apps_id` = '", AppsId/binary, "' AND `i_id`='", Iid/binary, "';">>).