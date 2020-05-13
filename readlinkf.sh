#!/bin/sh

# Usage
#   Arguments:
#     $1: Symbolic link (or regular path)
#
#   Exit status:
#     0: Path found
#     1: Path not found
#
# Note
#   `set 10 ...` is Maximum recursive loop count. When exit while loop
#   with $1 = 0, It means "Too many levels of symbolic links".
#
# Meaning of positional parameters used internally
#   $1: Remain loop count
#   $2: Original $PWD
#   $3: Original $OLDPWD
#   $4: Work variable
#   $5: Resolved path
#
# Included workarounds
#   $(pwd): PWD is not initialized when script started on ksh.
#   PWD=: I don't know why, Ksh on Ubuntu 12.04 won't work without this.
#   First CDPATH assignment: Not working second CDPATH assignment on ksh.
#   Use cd instead of cd -L: cd -L is not implemented on NetBSD sh.
#   Underscore of [ _"$p" = _"$4" ]: Avoid "unknown operand" when $p is "!".
#     e.g dash 0.5.3, busybox 1.22.0

# readlink without -f option
readlinkf_readlink() {
  [ ${1:+x} ] || return 1; p=$1; until [ _"${p%/}" = _"$p" ]; do p=${p%/}; done
  [ -e "$p" ] && p=$1; [ -d "$1" ] && p=$p/; set 10 "$(pwd)" "${OLDPWD:-}"; PWD=
  CDPATH="" cd -P "$2" && while [ "$1" -gt 0 ]; do set "$1" "$2" "$3" "${p%/*}"
    [ _"$p" = _"$4" ] || { CDPATH="" cd -P "${4:-/}" || break; p=${p##*/}; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && set "$@" "${p:-/}" && break
    set $(($1-1)) "$2" "$3"; p=$(readlink "$p") || break
  done 2>/dev/null; cd "$2" && OLDPWD=$3 && [ ${5+x} ] && printf '%s\n' "$5"
}

# POSIX compliant
readlinkf_posix() {
  [ ${1:+x} ] || return 1; p=$1; until [ _"${p%/}" = _"$p" ]; do p=${p%/}; done
  [ -e "$p" ] && p=$1; [ -d "$1" ] && p=$p/; set 10 "$(pwd)" "${OLDPWD:-}"; PWD=
  CDPATH="" cd -P "$2" && while [ "$1" -gt 0 ]; do set "$1" "$2" "$3" "${p%/*}"
    [ _"$p" = _"$4" ] || { CDPATH="" cd -P "${4:-/}" || break; p=${p##*/}; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && set "$@" "${p:-/}" && break
    set $(($1-1)) "$2" "$3" "$p"; p=$(ls -dl "$p") || break; p=${p#*" $4 -> "}
  done 2>/dev/null; cd "$2" && OLDPWD=$3 && [ ${5+x} ] && printf '%s\n' "$5"
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
