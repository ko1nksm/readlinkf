all: test check

test:
	./test.sh sh
	./test.sh ash
	./test.sh bash
	./test.sh bosh dockerfiles/schily
	./test.sh ksh
	./test.sh mksh
	./test.sh posh
	./test.sh yash
	./test.sh zsh

check:
	shellcheck *.sh
