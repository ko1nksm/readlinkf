#!/bin/sh

if [ ! -e /.dockerenv ]; then
  echo "[ERROR] Do not run outside of Docker." >&2
  exit 1
fi

. ./readlinkf.sh

dir() { mkdir -p "$1"; }
file() { dir "$(dirname "$1")"; touch "$1"; }
link() { dir "$(dirname "$1")"; ln -s "$2" "$1"; }

file /BASE/FILE
dir  /BASE/DIR
link /BASE/LINK         FILE
link /BASE/LINK2        DIR
file /BASE/LINK2/FILE
link /BASE/PARENT       ../
link /BASE/PARENT2      ../BASE
link /BASE1             /BASE
link /BASE/DIR/LINK1   ../FILE
link /BASE/DIR/LINK2   ./LINK1
link /BASE/DIR/LINK3   ../../LINK4
link /LINK4             TMP/DIR/FILE
link /LOOP1             ./LOOP2
link /LOOP2             ./LOOP1
link /MISSING           ./NO_FILE
link /ROOT              /
file "/INCLUDE SPACE/FILE NAME"
link "/INCLUDE SPACE/DIR NAME/SYMBOLIC LINK"   "../FILE NAME"

cat <<HERE
# readlinkf

  1. readlink (without -f option) implementation
  2. POSIX compliant implementation

HERE

echo "## test"
echo "\`\`\`"
tree -N --noreport -I "[a-z]*" /
echo "\`\`\`"
echo
echo "----------------------------------------------------------------------"
echo
echo "\`\`\`"
check() {
  readlink=$(readlink -f "$1")
  readlinkf=$(readlinkf "$1")
  readlinkf_posix=$(readlinkf_posix "$1")

  if [ "$readlink" = "$readlinkf" ] && [ "$readlink" = "$readlinkf_posix" ]; then
    printf '[ok]  %s -> %s\n' "$1" "$readlink"
  else
    printf '[bad] %s -> %s : %s : %s\n' "$1" "$readlink" "$readlinkf" "$readlinkf_posix"
  fi
}

find / -path "/[A-Z]*" | sort | while IFS= read -r path; do
  check "$path"
  check "$path/"
done

check "/BASE/LINK2/FILE"
check "/BASE/LINK2/FILE/"
echo "\`\`\`"
