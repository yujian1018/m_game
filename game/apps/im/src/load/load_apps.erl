%%%-------------------------------------------------------------------
%%% @author yujian
%%% @doc
%%%
%%% Created : 29. 六月 2017 下午2:05
%%%-------------------------------------------------------------------
-module(load_apps).

-include("im_pub.hrl").

-export([get_app/1]).


get_app(AppId) ->
    ExecRet1 = db_mysql:execute(pool_im, <<"SELECT id, app_secret FROM apps where app_id = '", AppId/binary, "';">>),
    case ExecRet1 of
        [[AppsId, AppSecret]] ->
            {AppsId, AppSecret};
        _ ->
            ?return_err(?ERR_NOT_APP)
    end.