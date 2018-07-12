#!/usr/bin/env bash

DATE=`date +%F_%H_%M`

APP_NAME=$1
IP=$2
PORT=$3

if [ "${PORT}" = "" ]; then
    CONFIG=${IP}
    NAME=${APP_NAME}@${IP}
else
    CONFIG=${IP}_${PORT}
    NAME=${APP_NAME}_${PORT}@${IP}
fi

show_info(){
    ps aux | grep erl
}

show_help(){
    echo "./start -h|--help"
    echo "./start sh|ps|rar"
    echo "./start apps(health) ip port"
}

case ${APP_NAME} in
    'sh')
        erl -setcookie c847efcb974ad5164d5d867d1bb2f0f9 -name sh@127.0.0.1 -epmd_port 27100 -epmd "epmd -port 27100 -daemon" -remsh ${NAME};;
    'ps')
        show_info ;;
    'h'|'help')
        show_help;;
    'rar')
        VERSION=`grep '{health' rebar.config | awk -F '"' '{print $2}'`
        mkdir -p ${VERSION}/lib ${VERSION}/config
        cp -f config/* ${VERSION}/config
        cp -f st.sh ${VERSION}

        cp -rf _build/default/lib/* ${VERSION}/lib
        rm -rf ${VERSION}/lib/*/src ${VERSION}/lib/*/include ${VERSION}/lib/*/.rebar3 ${VERSION}/lib/*/priv ${VERSION}/lib/*/test ${VERSION}/lib/parse_tool
        cp -rf lib/common/c_src ${VERSION}/lib/common/c_src
        tar -zcf health_${VERSION}_${DATE}.tar.gz ${VERSION}
        rm -rf ${VERSION}
        echo ${VERSION};;
    'init'|'install'|'rebuild')
        rm -rf apps/*/ebin/*.beam
        rm -rf apps/*/.rebar3/
        rm -rf lib/*/ebin
        rm -rf lib/*/.rebar3/
        (cd lib/common;make def)
        (cd apps/global;make all)
        (cd apps/gm;make all)
        (cd apps/game_lib;make all)
        (cd apps/http;make all)
        (cd apps/im;make all)
        (cd apps/obj;make all);;
    'cc_make')
        (cd lib/common;make -C c_src)
	    (cd lib/jiffy;./rebar clean;./rebar co);;
    *)
        OPTIONS=" -name ${NAME}"
        CONFIGS=" -config config/sys -config config/${APP_NAME}_${CONFIG}"
        ARGS+=" -args_file config/vm.args -args_file config/${APP_NAME}_vm.args"
        echo erl ${CONFIGS} ${ARGS} ${OPTIONS};
        erl ${CONFIGS} ${ARGS}  ${OPTIONS};;
esac