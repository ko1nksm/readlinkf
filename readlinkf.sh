#!/bin/sh

# Explanation
#
# set -- 10 ...           Maximum recursive loop count
# Exit loop with $1 = 0:  Too many levels of symbolic links
# Positional parameters:
#   $1: Loop count
#   $2: Original $PWD
#   $3: Original $OLDPWD
#   $4: Work variable
#   $5: Resolved path
# The first CDPATH assigning is a workaround for ksh.

# readlink without -f option
readlinkf_readlink() {
  [ ${1:+x} ] || return 1; p=$1; until [ "${p%/}" = "$p" ]; do p=${p%/}; done
  [ -e "$p" ] && p=$1; [ -d "$1" ] && p=$p/; set 10 "$PWD" "${OLDPWD:-}";
  CDPATH="" cd -P "$2" && while [ "$1" -gt 0 ]; do set "$1" "$2" "$3" "${p%/*}"
    [ "$p" = "$4" ] || { CDPATH="" cd -P "${4:-/}" || break; p=${p##*/}; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && set "$@" "${p:-/}" && break
    set $(($1-1)) "$2" "$3"; p=$(readlink "$p") || break
  done 2>/dev/null; cd -L "$2" && OLDPWD=$3 && [ ${5+x} ] && printf '%s\n' "$5"
}

# POSIX compliant
readlinkf_posix() {
  [ ${1:+x} ] || return 1; p=$1; until [ "${p%/}" = "$p" ]; do p=${p%/}; done
  [ -e "$p" ] && p=$1; [ -d "$1" ] && p=$p/; set 10 "$PWD" "${OLDPWD:-}"
  CDPATH="" cd -P "$2" && while [ "$1" -gt 0 ]; do set "$1" "$2" "$3" "${p%/*}"
    [ "$p" = "$4" ] || { CDPATH="" cd -P "${4:-/}" || break; p=${p##*/}; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && set "$@" "${p:-/}" && break
    set $(($1-1)) "$2" "$3" "$p"; p=$(ls -dl "$p") || break; p=${p#*" $4 -> "}
  done 2>/dev/null; cd -L "$2" && OLDPWD=$3 && [ ${5+x} ] && printf '%s\n' "$5"
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
