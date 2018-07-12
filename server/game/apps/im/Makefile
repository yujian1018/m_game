
def:
	rm -rf src/auto/def
	escript ../../lib/parse_tool/t_def ../etc/def/im/ src/auto/def/

proto:
	rm -rf src/auto/proto
	escript ../../lib/parse_tool/t_proto ../etc/proto/im/ src/auto/proto/

all:
	rm -rf ebin
	make def && make proto