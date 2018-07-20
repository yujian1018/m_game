

def:
	rm -rf src/_auto/def
	escript ../../lib/parse_tool/t_def ../../config/def/gm src/_auto/def/

proto:
	rm -rf src/_auto/proto
	escript ../../lib/parse_tool/t_proto ../../config/proto/gm src/_auto/proto/

mysql:
	rm -rf src/_auto/db
	erl -pa ../../lib/*/ebin ../../_build/default/lib/*/ebin -config ../../config/gm_sys_192.168.2.51_26004 -pa -s tab_to_mod main -s erlang halt


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