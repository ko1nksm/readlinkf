#!/bin/sh

# Explanation
#
# set 10 ... :            10 is maximum recursive count
# exit loop with $1 = 0:  Too many levels of symbolic links
# exit loop with $1 = -1: No such file or directory

# readlink without -f option
readlinkf_readlink() {
  [ "${1:-}" ] || return 1; p=$1; until [ "${p%/}" = "$p" ]; do p=${p%/}; done
  [ -e "$p" ] && p=$1; [ -d "$1" ] && p=$p/; set 10 "$PWD"; cd -P . || return 1
  while [ "$1" -gt 0 ]; do set -- $(($1-1)) "$2" "${p%/*}" "${p##*/}"
    [ "$p" = "$3" ] || { cd -P "$3/" || { set -- -1 "$2"; break; }; p=$4; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && break
    p=$(readlink "$p") || set -- -1 "$2" "$3"
  done 2>/dev/null; cd -L "$2" && [ "$1" -gt 0 ]
}

# POSIX compliant
readlinkf_posix() {
  [ "${1:-}" ] || return 1; p=$1; until [ "${p%/}" = "$p" ]; do p=${p%/}; done
  [ -e "$p" ] && p=$1; [ -d "$1" ] && p=$p/; set 10 "$PWD"; cd -P . || return 1
  while [ "$1" -gt 0 ]; do set -- $(($1-1)) "$2" "${p%/*}" "${p##*/}"
    [ "$p" = "$3" ] || { cd -P "$3/" || { set -- -1 "$2"; break; }; p=$4; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && break
    set -- "$@" "$p"; p=$(ls -dl "$p") || set -- -1 "$2"; p=${p#*" $5 -> "}
  done 2>/dev/null; cd -L "$2" && [ "$1" -gt 0 ]
}

# The format of "ls -dl" of symlink is defined below
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html#tag_20_73_10
# "%s -> %s", <pathname of link>, <contents of link>

# Run as a command is an example.
case ${0##*/} in (readlinkf_readlink | readlinkf_posix)
  set -eu

  if [ $# -eq 0 ]; then
    echo "readlink: missing operand" >&2
    exit 1
  fi

  ex=0
  for i; do
    "${0##*/}" "$i" || ex=1
  done
  exit "$ex"
esac
