#!/bin/sh

# readlink without -f option
readlinkf_readlink() {
  [ "${1:-}" ] && cd -P . || return 1; i=0 p=${1%/}; [ -e "$p" ] && p=$1
  while [ $i -lt 10 ] && i=$((i+1)); do set -- "${p%/*}" "${p##*/}" /dev/null
    [ "$p" = "$1" ] || { cd -P "${1%/}/" 2>"$3" || return 1; p=$2; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && return 0
    p=$(readlink "$p" 2>"$3") || return 1
  done; return 1 # maximum recursive loop exceeded
}

# POSIX compliant
readlinkf_posix() {
  [ "${1:-}" ] && cd -P . || return 1; i=0 p=${1%/}; [ -e "$p" ] && p=$1
  while [ $i -lt 10 ] && i=$((i+1)); do set -- "${p%/*}" "${p##*/}" /dev/null
    [ "$p" = "$1" ] || { cd -P "${1%/}/" 2>"$3" || return 1; p=$2; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && return 0
    l=$(ls -dl "$p" 2>"$3") && p=${l#*" $p -> "} || return 1
  done; return 1 # maximum recursive loop exceeded
}

# The format of "ls -dl" of symlink is defined below
# https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html#tag_20_73_10
# "%s -> %s", <pathname of link>, <contents of link>

case ${0##*/} in (readlinkf_readlink | readlinkf_posix)
  set -eu

  if [ $# -eq 0 ]; then
    echo "readlink: missing operand"
    exit 1
  fi

  for i; do
    "${0##*/}" "$i"
  done
esac
