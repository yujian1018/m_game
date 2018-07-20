#!/usr/bin/env bash

DATE=`date +%F_%H_%M`
HOST_TEST=127.0.0.1
VERSION=`grep '{game' rebar.config | awk -F '"' '{print $2}'`

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

case ${APP_NAME} in
    'sh')
        erl -setcookie c847efcb974ad5164d5d867d1bb2f0f9 -name sh@127.0.0.1 -epmd_port 27100 -epmd "epmd -port 27100 -daemon" -remsh ${NAME};;
    'ps')
        show_info ;;
    'h'|'help')
        show_help;;

    'init'|'install'|'rebuild')
        rm -rf apps/*/ebin
        rm -rf apps/*/.rebar3/
        rm -rf lib/*/.rebar3/
        rm -rf lib/*/ebin
        (cd lib/parse_tool;sh bootstrap.sh)
        ./st.sh re;;
    'rebuild'|'re')
        re;;
    'rar')
        rar;;
    'cc')
        (cd _build/default/lib/common;make -C c_src)
	    (cd _build/default/lib/jiffy;./rebar clean;./rebar co);;

    'scp_rar')
	    scp game_*.tar.gz root@${HOST_TEST}:/root/project/game/;;
    'scp')
	    scp _build/default/lib/$2/ebin/$3.beam root@${HOST_TEST}:/root/project/game/${VERSION}/_build/default/lib/$2/ebin/;;
    *)
        OPTIONS=" -name ${NAME}"
        CONFIGS=" -config config/sys -config config/${APP_NAME}_${CONFIG}"
        ARGS+=" -args_file config/vm.args -args_file config/${APP_NAME}_vm.args"
        echo erl ${CONFIGS} ${ARGS} ${OPTIONS};
        erl ${CONFIGS} ${ARGS}  ${OPTIONS};;
esac



show_info(){
    ps aux | grep erl
}

show_help(){
    echo "./st.sh -h ||h || help"
    echo "./st.sh sh ip port"
    echo "./st.sh ps"
    echo "./st.sh init || install || rebuild"
    echo "./st.sh rar"
    echo "./st.sh cc"
    echo "./st.sh apps(health) ip port"
    echo "./st.sh scp_rar"
    echo "./st.sh scp apps(http || health) file"
}

re(){
    (cd lib/common;make def)
    (cd apps/global;make all)
    (cd apps/gm;make all)
    (cd apps/game_lib;make all)
    (cd apps/http;make all)
    (cd apps/im;make all)
    (cd apps/obj;make all)
}

rar(){
    rm -rf game_*.tar.gz
    mkdir -p ${VERSION}/_build/default/lib ${VERSION}/config
    cp -f config/* ${VERSION}/config
    cp -f st.sh ${VERSION}
    cp -rf _build/default/lib/* ${VERSION}/_build/default/lib

    rm -rf ${VERSION}/_build/default/lib/*/src
    rm -rf ${VERSION}/_build/default/lib/*/include
    rm -rf ${VERSION}/_build/default/lib/*/doc
    rm -rf ${VERSION}/_build/default/lib/*/priv
    rm -rf ${VERSION}/_build/default/lib/*/test
    rm -rf ${VERSION}/_build/default/lib/*/.rebar3
    rm -rf ${VERSION}/_build/default/lib/*/.git
    rm -rf ${VERSION}/_build/default/lib/parse_tool
    cp -rf lib/common/c_src ${VERSION}/_build/default/lib/common/c_src
    tar -zcf game_${VERSION}_${DATE}.tar.gz ${VERSION}
    rm -rf ${VERSION}
    echo ${VERSION}
}