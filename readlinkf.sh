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
  eval "$1=\$(readlinkf_readlink_ \"\$2\")"
}

readlinkf_readlink_() {
  [ ${1:+x} ] || return 1
  p=$1

  until [ "${p%/}" = "$p" ]
    do p=${p%/}
  done

  [ -e "$p" ] && p=$1
  [ -d "$1" ] && p=$p/
  set 10
  cd -P "$PWD" || return 1

  while [ "$1" -gt 0 ]; do
    set "$1" "${p%/*}"

    if [ ! "$p" = "$2" ]; then
      CDPATH="" cd -P "${2:-/}" 2>/dev/null || break
      p=${p##*/}
    fi

    if [ ! -L "$p" ]; then
      p=${PWD%/}${p:+/}$p
      set "$1" "$2" "${p:-/}"
      break
    fi

    set $(($1-1))
    p=$(readlink "$p" 2>/dev/null) || break
  done

  [ ${3+x} ] || return 1
  printf '%s\n' "$3"
}

# POSIX compliant
readlinkf_posix() {
  eval "$1=\$(readlinkf_posix_ \"\$2\")"
}

readlinkf_posix_() {
  [ ${1:+x} ] || return 1
  p=$1

  until [ "${p%/}" = "$p" ]; do
    p=${p%/}
  done

  [ -e "$p" ] && p=$1
  [ -d "$1" ] && p=$p/
  set 10
  cd -P "$PWD" || return 1

  while [ "$1" -gt 0 ]; do
    set "$1" "${p%/*}"

    if [ ! "$p" = "$2" ]; then
      CDPATH="" cd -P "${2:-/}" 2>/dev/null || break
      p=${p##*/}
    fi

    if [ ! -L "$p" ]; then
      p=${PWD%/}${p:+/}$p
      set "$1" "$2" "${p:-/}"
      break
    fi

    set $(($1-1)) "$p"
    p=$(ls -dl "$p" 2>/dev/null) || break
    p=${p#*" $2 -> "}
  done

  [ ${3+x} ] || return 1
  printf '%s\n' "$3"
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
