#!/bin/sh

set -eu
cd "$(dirname "$0")"

. ./helper.sh
. ./readlinkf.sh

if [ ! -e /.dockerenv ]; then
  docker --version >&2 || abort "[ERROR] You need docker to run"
  set -- "${1:-sh}" "${2:-Dockerfile}" "${3:-latest}"
  docker run --rm "$(docker build --build-arg "TAG=$3" -q . -f "$2")" "$1" "./${0##*/}"
  exit
fi

echo "============================ /etc/os-release ==========================="
[ -f /etc/os-release ] && cat /etc/os-release

echo "---------------- Create files, directories and symlinks ----------------"
make_file "/BASE/FILE"
make_dir  "/BASE/DIR"
make_link "/BASE/LINK -> FILE"
make_link "/BASE/LINK2 -> DIR"
make_file "/BASE/LINK2/FILE"
make_link "/BASE/PARENT -> ../"
make_link "/BASE/PARENT2 -> ../BASE"
make_link "/BASE1 -> /BASE"
make_link "/BASE/DIR/LINK1 -> ../FILE"
make_link "/BASE/DIR/LINK2 -> ./LINK1"
make_link "/BASE/DIR/LINK3 -> ../../LINK4"
make_link "/LINK4 -> TMP/DIR/FILE"
make_link "/LOOP1 -> ./LOOP2"
make_link "/LOOP2 -> ./LOOP1"
make_link "/MISSING -> ./NO_FILE"
make_link "/ROOT -> /"
make_file "/INCLUDE SPACE/FILE NAME"
make_link "/INCLUDE SPACE/DIR NAME/SYMBOLIC LINK -> ../FILE NAME"

echo "--------------------------------- Tree ---------------------------------"
run tree -N --noreport -I "[a-z]*" /

echo "--------------------------------- Tests --------------------------------"
{
  find / -path "/[A-Z]*"
  echo "/BASE/LINK2/FILE"
} | sort | while IFS= read -r pathname; do
  echo "$pathname"
  echo "$pathname/"
done | {
  ex=0
  while IFS= read -r pathname; do
    set -- "$pathname"
    link=$($(which readlink) -f "$1")        &&:; set -- "$@" "$link" "$?"
    link=$(readlinkf_readlink "$1") &&:; set -- "$@" "$link" "$?"
    link=$(readlinkf_posix "$1")    &&:; set -- "$@" "$link" "$?"

    if [ "$2($3)" = "$4($5)" ] && [ "$2($3)" = "$6($7)" ]; then
      printf "\033[32m[pass]\033[m %s -> %s (exit status: %d)\n" "$1" "$2" "$3"
    else
      printf '\033[31m[fail]\033[m %s -> %s (%d) : %s (%d) : %s (%d)\n' "$@"
      ex=1
    fi
  done
  exit $ex
}
