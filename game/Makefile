DATE=`date +%F_%H_%M`

co:
	./rebar co


rar:
	tar -zcf game_all_$(DATE).tar.gz etc/conf obj/ebin/ apps/*/ebin apps/*/priv libs/*/ebin start.sh


all:
	rm -rf apps/*/ebin/*.beam
	rm -rf apps/*/.rebar/
	rm -rf libs/cache/ebin
	rm -rf libs/common/ebin
	rm -rf libs/network/ebin
	rm -rf libs/*/.rebar/

	(cd libs/common;make all)
	(cd apps/game_lib;make all)
	(cd apps/http;make all)
	(cd obj;make all)
