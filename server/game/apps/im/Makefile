
def:
	rm -rf src/_auto/def
	escript ../../lib/parse_tool/t_def ../../config/def/im/ src/_auto/def/

proto:
	rm -rf src/_auto/proto
	escript ../../lib/parse_tool/t_proto ../../config/proto/im/ src/_auto/proto/

all:
	rm -rf ebin
	make def && make proto