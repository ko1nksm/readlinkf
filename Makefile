TAG ?= latest
DOCKERFILE := dockerfiles/debian

all: test check

test:
	./test.sh sh $(DOCKERFILE) $(TAG)
	./test.sh ash $(DOCKERFILE) $(TAG)
	./test.sh bash $(DOCKERFILE) $(TAG)
	./test.sh ksh $(DOCKERFILE) $(TAG)
	./test.sh mksh $(DOCKERFILE) $(TAG)
	./test.sh posh $(DOCKERFILE) $(TAG)
	./test.sh yash $(DOCKERFILE) $(TAG)
	./test.sh zsh $(DOCKERFILE) $(TAG)

bosh:
	./test.sh bosh dockerfiles/schily

pbosh:
	./test.sh pbosh dockerfiles/schily

check:
	shellcheck *.sh
