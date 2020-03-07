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
make_file "/RLF-BASE/FILE"
make_dir  "/RLF-BASE/DIR"
make_link "/RLF-BASE/LINK -> FILE"
make_link "/RLF-BASE/LINK2 -> DIR"
make_file "/RLF-BASE/LINK2/FILE"
make_link "/RLF-BASE/PARENT -> ../"
make_link "/RLF-BASE/PARENT2 -> ../RLF-BASE"
make_link "/RLF-BASE1 -> /RLF-BASE"
make_link "/RLF-BASE/DIR/LINK1 -> ../FILE"
make_link "/RLF-BASE/DIR/LINK2 -> ./LINK1"
make_link "/RLF-BASE/DIR/LINK3 -> ../../RLF-LINK4"
make_link "/RLF-LINK4 -> RLF-TMP/DIR/FILE"
make_link "/RLF-LOOP1 -> ./RLF-LOOP2"
make_link "/RLF-LOOP2 -> ./RLF-LOOP1"
make_link "/RLF-MISSING -> ./RLF-NO_FILE"
make_link "/RLF-ROOT -> /"
make_file "/RLF-SPACE INCLUDED/FILE NAME"
make_link "/RLF-SPACE INCLUDED/DIR NAME/SYMBOLIC LINK -> ../FILE NAME"

echo "--------------------------------- Tree ---------------------------------"
run tree -N --noreport -I "*[a-z]*" /

echo "--------------------------------- Tests --------------------------------"
TEST_COUNT=44
{
  find / -path "/RLF-*"
  echo "/RLF-BASE/LINK2/FILE"
} | sort | while IFS= read -r pathname; do
  echo "$pathname"
  echo "$pathname/"
done | {
  ex=0 count=0
  while IFS= read -r pathname; do
    count=$((count+1))
    set -- "$pathname"
    # shellcheck disable=SC2230
    link=$($(which readlink) -f "$1") &&:; set -- "$@" "$link" "$?"
    link=$(readlinkf_readlink "$1") &&:; set -- "$@" "$link" "$?"
    link=$(readlinkf_posix "$1") &&:; set -- "$@" "$link" "$?"

    if [ "$2($3)" = "$4($5)" ] && [ "$2($3)" = "$6($7)" ]; then
      printf "\033[32m[pass]\033[m %s -> %s (exit status: %d)\n" "$1" "$2" "$3"
    else
      printf '\033[31m[fail]\033[m %s -> %s (%d) : %s (%d) : %s (%d)\n' "$@"
      ex=1
    fi
  done
  if [ "$count" -ne "$TEST_COUNT" ]; then
    set -- "$TEST_COUNT" "$count"
    printf '\033[31m[fail]\033[m test count: expected %d, but ran %d\n' "$@"
    ex=1
  fi

  echo "-------------------------------- Cleanup -------------------------------"
  run rm -rf "/RLF-BASE"
  run rm -rf "/RLF-BASE1"
  run rm -rf "/RLF-LINK4"
  run rm -rf "/RLF-LOOP1"
  run rm -rf "/RLF-LOOP2"
  run rm -rf "/RLF-MISSING"
  run rm -rf "/RLF-ROOT"
  run rm -rf "/RLF-SPACE INCLUDED"
  run tree -N --noreport -I "*[a-z]*" /

  exit $ex
}
