#!/usr/bin/env bash

APP_NAME=$1
IP=$2
PORT=$3
IS_HIDDEN=$4

CONFIGS=""
ARGS=""
OPTIONS=""


if [ "${PORT}" = "" ]; then
    CONFIG=${IP}
    NAME=game_${APP_NAME}@${IP}
else
    CONFIG=${IP}_${PORT}
    NAME=game_${APP_NAME}_${PORT}@${IP}
fi


show_help(){
    echo "./start -h"
    echo "screen -dmS {session_name} ./start.sh {app_name} {ip} {port}"
    echo "app_name = db|mgr|http|obj|push|fight|im"
}


case ${APP_NAME} in
    'sh')
        erl -setcookie 123 -name game_sh@127.0.0.1 -epmd_port 26100 -epmd "epmd -port 26100 -daemon" -pa apps/*/ebin -pa libs/*/ebin -pa */ebin;;
    '-h')
        show_help;;
    *)
        case ${IS_HIDDEN} in
            'bg')
            OPTIONS=" -noshell -noinput -detached -name ${NAME}";;
            *)
            OPTIONS=" -name ${NAME}"
        esac
        case ${APP_NAME} in
            'db'|'http'|'obj')
                CONFIGS=" -config etc/conf/sys -config etc/conf/${APP_NAME} -config etc/conf/${APP_NAME}_${CONFIG}";;
            *)
                CONFIGS=" -config etc/conf/sys -config etc/conf/${APP_NAME}"
        esac
        ARGS+=" -args_file etc/conf/vm.args -args_file etc/conf/${APP_NAME}.args"
        echo erl ${CONFIGS} ${ARGS} ${OPTIONS};
        erl ${CONFIGS} ${ARGS}  ${OPTIONS};;
esac