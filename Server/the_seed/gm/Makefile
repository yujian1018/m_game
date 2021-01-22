

def:
	rm -rf src/auto/def
	escript ../libs/parse_tool/t_def ../etc/def/gm src/auto/def/

proto:
	rm -rf src/auto/proto
	escript ../libs/parse_tool/t_proto ../etc/proto/gm src/auto/proto/

mysql:
	rm -rf src/auto/mysql
	erl -pa ebin/ ../apps/*/ebin ../libs/*/ebin -config ../etc/conf/gm_sys_192.168.2.51_26004 -pa -s tab_to_mod main -s erlang halt


all:
	rm -rf ebin
	make def && make proto && make mysql


dev:
	cat priv/docroot/js/main_1.jsc > priv/docroot/js/main.js

rar_js:
	cat priv/docroot/assets/js/*/*.js priv/docroot/assets/js/*/*/*.js priv/docroot/assets/lib/*/*.js  priv/docroot/js/*/*.js priv/docroot/js/main_2.js > priv/docroot/js/main.js
	java -jar compiler.jar --compilation_level=SIMPLE_OPTIMIZATIONS --js priv/docroot/js/main.js --js_output_file priv/docroot/js/main_min.js
	mv priv/docroot/js/main_min.js priv/docroot/js/main.js

#find ./ex/gm_ex/priv/docroot/assets/js/ -type f -name '*.js'