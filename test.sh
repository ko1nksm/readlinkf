#!/bin/sh

set -eu
cd "$(dirname "$0")"

. ./helper.sh

if [ "$(id -u)" -eq 0 ] && [ ! -e /.dockerenv ]; then
  if [ ! "${ALLOW_CREATION_TO_THE_ROOT_DIRECTORY:-}" ]; then
    abort "Set ALLOW_CREATION_TO_THE_ROOT_DIRECTORY environment variable"
  fi
else
  if [ ! -e /.dockerenv ]; then
    docker --version >&2 || abort "You need docker to run"
    set -- "${1:-sh}" "${2:-Dockerfile}" "${3:-latest}"
    cid=$(docker build --build-arg "TAG=$3" -q . -f "$2")
    run docker run --rm -t "$cid" "$1" "./${0##*/}"
    exit
  fi
fi

. ./readlinkf.sh

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
run tree -C -N --noreport -I "*[a-z]*" /

echo "--------------------------------- Tests --------------------------------"
TEST_COUNT=$((25 * 2 * 4)) # expected test count
# TEST_COUNT=$((1 * 4))

pathes() {
  # echo "/RLF-BASE/FILE"
  # return # if you want to run only specified path
  {
    find /RLF-*
    echo "/RLF-BASE/LINK2/FILE"
    echo ""
    echo "."
    echo "../"
  } | sort | while IFS= read -r pathname; do
    echo "$pathname"
    echo "$pathname/"
  done
}

tests() {
  ex=0 count=0 cwd=$PWD
  while IFS= read -r pathname; do
    cd "$cwd" # absolute path
    count=$((count+1))
    compare_with_readlink "$pathname" || ex=1

    cd / # relative path from current directory
    count=$((count+1))
    compare_with_readlink "${pathname#/}" || ex=1

    cd /usr/bin # relative path from other directory
    count=$((count+1))
    compare_with_readlink "../..$pathname" || ex=1

    cd /RLF-BASE1 # on the symlink directory
    count=$((count+1))
    compare_with_readlink "${pathname#/}" || ex=1
  done
  [ "$ex" -ne 0 ] && fail 'some of the above path checks failed'
  if [ "$count" -ne "$TEST_COUNT" ]; then
    fail 'test count: expected %d, but ran %d' "$TEST_COUNT" "$count"
    ex=1
  fi
  return "$ex"
}

compare_with_readlink() {
  # shellcheck disable=SC2230
  link=$($(which readlink) -f "$1") &&:; set -- "$@" "$link" "$?"
  link=$(readlinkf_readlink "$1") &&:; set -- "$@" "$link" "$?"
  link=$(readlinkf_posix "$1") &&:; set -- "$@" "$link" "$?"

  if [ "$2($3)" = "$4($5)" ] && [ "$2($3)" = "$6($7)" ]; then
    pass "%s -> %s (exit status: %d)" "$1" "$2" "$3"
    return 0
  else
    fail "%s -> %s (%d) : %s (%d) : %s (%d)" "$@"
    return 1
  fi
}

pathes | tests &&:
ex=$?

echo "-------------------------------- Cleanup -------------------------------"
run rm -rf "/RLF-BASE"
run rm -rf "/RLF-BASE1"
run rm -rf "/RLF-LINK4"
run rm -rf "/RLF-LOOP1"
run rm -rf "/RLF-LOOP2"
run rm -rf "/RLF-MISSING"
run rm -rf "/RLF-ROOT"
run rm -rf "/RLF-SPACE INCLUDED"
run tree -C -N --noreport -I "*[a-z]*" /

exit $ex
