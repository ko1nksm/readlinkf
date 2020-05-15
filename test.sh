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
    run docker --version >&2 || abort "You need docker to run"
    shell=${1:-sh} dockerfile=${2:-dockerfiles/debian} tag=${3:-}
    set -- -f "$dockerfile"
    [ ${tag:+x} ] && set -- "$@" --build-arg "TAG=$tag"
    iidfile=$(mktemp)
    run docker build --iidfile "$iidfile" "$@" .
    iid=$(cat "$iidfile")
    rm "$iidfile"
    run docker run --rm -t "$iid" "$shell" "./${0##*/}"
    exit
  fi
fi

. ./readlinkf.sh

CDPATH=/

echo "============================== Information ============================="
[ -f /etc/os-release ] && run cat /etc/os-release
[ -f /etc/debian_version ] && run cat /etc/debian_version
sleep 3

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
make_link "/RLF-BASE/DIR/LINK3 -> ../../RLF-LINK"
make_link "/RLF-BASE/DIR/LINK4 -> ../../RLF-LINK-BROKEN"
make_link "/RLF-LINK -> RLF-BASE/DIR/LINK1"
make_link "/RLF-LINK-BROKEN -> RLF-TMP/DIR/FILE"
make_link "/RLF-LOOP1 -> ./RLF-LOOP2"
make_link "/RLF-LOOP2 -> ./RLF-LOOP1"
make_link "/RLF-MISSING -> ./RLF-NO_FILE"
make_link "/RLF-ROOT -> /"
make_file "/RLF-SPACE INCLUDED/FILE NAME"
make_link "/RLF-SPACE INCLUDED/DIR NAME/SYMBOLIC LINK -> ../FILE NAME"

echo "--------------------------------- Tree ---------------------------------"
run tree -C -N --noreport -I "*[a-z]*" /

echo "--------------------------------- Tests --------------------------------"
TEST_COUNT=$((29 * 2 * 4)) # expected test count
# TEST_COUNT=$((1 * 4))

pathes() {
  # echo "/RLF-BASE/FILE"
  # return # if you want to run only specified path
  {
    set +u
    find /RLF-*
    echo "/RLF-BASE/LINK2/FILE"
    echo "/RLF-BASE/DIR/../FILE"
    echo ""
    echo "."
    echo "../"
    echo "./RLF-NONE/../"
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

  if [ "$ex" -eq 0 ]; then
    pass "path check: all of the above succeeded"
  else
    fail 'path check: some of the above failed'
  fi

  if [ "$count" -eq "$TEST_COUNT" ]; then
    pass 'test count: expected %d, ran all %d' "$TEST_COUNT" "$count"
  else
    fail 'test count: expected %d, but ran %d' "$TEST_COUNT" "$count"
    ex=1
  fi

  return "$ex"
}

compare_with_readlink() {
  # shellcheck disable=SC2230
  link=$($(which readlink) -f "$1") &&:; set -- "$@" "$link" "$?"
  link=$(readlinkf_posix "$1") &&:; set -- "$@" "$link" "$?"
  link=$(readlinkf_readlink "$1") &&:; set -- "$@" "$link" "$?"

  if [ "$2($3)" = "$4($5)" ] && [ "$2($3)" = "$6($7)" ]; then
    pass "%s -> %s (exit status: %d) [cd %s]" "$1" "$2" "$3" "$PWD"
    return 0
  else
    fail "%s -> %s (%d) : %s (%d) : %s (%d) [cd %s]" "$@" "$PWD"
    return 1
  fi
}

pathes | tests &&:
ex=$?

# Extra test
pass_fail_number=$((TEST_COUNT + 2))
cd /var
cd /tmp
CDPATH=/usr

variable_check() {
  name=$1 && shift
  if "$@"; then
    pass "Variable %s preserved" "$name"
  else
    fail "Variable %s changed" "$name" && ex=1
  fi
}

link=$(readlinkf_readlink /RLF-BASE/DIR/LINK3) >/dev/null
variable_check 'readlinkf_readlink: PWD' [ "$PWD" = /tmp ]
variable_check 'readlinkf_readlink: OLDPWD' [ "$OLDPWD" = /var ]
variable_check 'readlinkf_readlink: CDPATH' [ "$CDPATH" = /usr ]

link=$(readlinkf_posix /RLF-BASE/DIR/LINK3) >/dev/null
variable_check 'readlinkf_posix: PWD' [ "$PWD" = /tmp ]
variable_check 'readlinkf_posix: OLDPWD' [ "$OLDPWD" = /var ]
variable_check 'readlinkf_posix: CDPATH' [ "$CDPATH" = /usr ]

echo "-------------------------------- Cleanup -------------------------------"
run rm -rf "/RLF-BASE"
run rm -rf "/RLF-BASE1"
run rm -rf "/RLF-LINK"
run rm -rf "/RLF-LINK-BROKEN"
run rm -rf "/RLF-LOOP1"
run rm -rf "/RLF-LOOP2"
run rm -rf "/RLF-MISSING"
run rm -rf "/RLF-ROOT"
run rm -rf "/RLF-SPACE INCLUDED"
run tree -C -N --noreport -I "*[a-z]*" /

exit $ex
