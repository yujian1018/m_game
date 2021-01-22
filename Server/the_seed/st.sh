#!/usr/bin/env bash

DATE=`date +%F_%H_%M`
VERSION=`awk -F'"' '/{health/{print $2}' rebar.config`


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


re(){
    (cd lib/common;make def)
    (cd apps/global;make def)
    (cd user;make def)
    (cd gateway;make all)
    (make cl)
    (make co)
}

rar(){
    rm -rf health_*.tar.gz
    mkdir -p ${VERSION}/_build/default/lib ${VERSION}/config ${VERSION}/config/dict ${VERSION}/config/database
    cp -f config/* ${VERSION}/config
    cp -rf config/dict ${VERSION}/config
    cp -rf config/database ${VERSION}/config
#    cp -rf config/mnesia.db ${VERSION}/config
    cp -f st.sh ${VERSION}

    cp -rf _build/default/lib/* ${VERSION}/_build/default/lib
    rm -rf ${VERSION}/config/database/.svn
    rm -rf ${VERSION}/_build/default/lib/*/src ${VERSION}/_build/default/lib/*/include ${VERSION}/_build/default/lib/*/.rebar3 ${VERSION}/_build/default/lib/*/priv ${VERSION}/_build/default/lib/*/test ${VERSION}/_build/default/lib/parse_tool ${VERSION}/_build/default/lib/*/.git ${VERSION}/_build/default/lib/*/doc
    cp -rf lib/common/c_src ${VERSION}/_build/default/lib/common/c_src
    tar -zcf health_${VERSION}_${DATE}.tar.gz ${VERSION}
    rm -rf ${VERSION}
    echo ${VERSION}
}

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

case ${APP_NAME} in
    'sh')
        erl -setcookie c847efcb974ad5164d5d867d1bb2f0f9 -name sh@127.0.0.1 -epmd_port 26100 -epmd "epmd -port 26100 -daemon" -remsh health_${PORT}@${IP};;
    'ps')
        show_info ;;
    '-h'|'h'|'help')
        show_help;;
    'init'|'install')
        rm -rf lib/*/.rebar/
        rm -rf lib/*/ebin
        (cd lib/parse_tool;sh bootstrap.sh)
        ./st.sh re;;
    'rebuild'|'re')
        re;;
    'rar')
        rar;;
    'cc')
        rm -rf _build/default/lib/jiffy/
        (cd _build/default/lib/common;make -C c_src)
        rm -rf _build/default/lib/common/ebin/iconv.beam
	    rm -rf _build/default/lib/common/ebin/ejieba.beam
	    rm -rf _build/default/lib/common/ebin/std.beam;;
    'scp_rar')
	    scp health_*.tar.gz root@212.64.37.40:/root/project/health/;;
    'scp')
        echo scp _build/default/lib/$2/ebin/$3.beam root@212.64.37.40:/root/project/health/${VERSION}/_build/default/lib/$2/ebin/
	    scp _build/default/lib/$2/ebin/$3.beam root@212.64.37.40:/root/project/health/${VERSION}/_build/default/lib/$2/ebin/;;
	'scp_data')
	    scp config/database/*.data root@212.64.37.40:/root/project/health/${VERSION}/config/database/;;
	'scp_mysql')
        mysqldump -uroot -p123456 --databases 3.0.10 |mysql --host=212.64.37.40 -uroot -p86E5AA595C6A5190C985b3850154C_,# -C ${VERSION};;
    '+S')
        erlc +"'S'" -I frame/include/ frame/test/test_trie.erl;;
    'release')
        mysqldump -u root -p123456 --port 27199 --databases ${VERSION} > ${VERSION}.sql
        mv ${VERSION}.sql ../db/sql/release/
        git add -A
        git commit
        git push
        git checkout develop
        git merge yujian
        git push
        git checkout master
        git merge develop
        git push
        git checkout yujian
        git tag -a ${VERSION}
        git push --tags;;
    'tag_del')
        TAG_NAME=$2
        git tag -d ${TAG_NAME}
        git push origin --delete tag ${TAG_NAME};;
    *)
        OPTIONS=" -name ${NAME}"
        CONFIGS=" -config config/sys -config config/${APP_NAME}_${CONFIG}"
        ARGS+=" -args_file config/vm.args -args_file config/${APP_NAME}_vm.args"
        echo erl ${CONFIGS} ${ARGS} ${OPTIONS};
        erl ${CONFIGS} ${ARGS}  ${OPTIONS};;
esac
