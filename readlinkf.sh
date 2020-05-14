#!/bin/sh
# shellcheck disable=SC2004

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
  target=$1 loop=10 CDPATH=""

  if [ ! -e "${target%/}" ]; then
    while [ ! "${target%/}" = "$target" ]; do
      target=${target%/}
    done
  fi
  [ -d "${target:-/}" ] && target="$target/"

  cd -P "$PWD" 2>/dev/null || return 1
  while [ "$loop" -gt 0 ] && loop=$(($loop - 1)); do
    if [ ! "$target" = "${target%/*}" ]; then
      cd -P "${target%/*}/" 2>/dev/null || break
      target=${target##*/}
    fi

    if [ ! -L "$target" ]; then
      target="${PWD%/}${target:+/}$target"
      printf '%s\n' "${target:-/}"
      return 0
    fi

    target=$(readlink "$target" 2>/dev/null) || break
  done
  return 1
}

# POSIX compliant
readlinkf_posix() {
  eval "$1=\$(readlinkf_posix_ \"\$2\")"
}

readlinkf_posix_() {
  [ ${1:+x} ] || return 1
  target=$1 loop=10 CDPATH=""

  if [ ! -e "${target%/}" ]; then
    while [ ! "${target%/}" = "$target" ]; do
      target=${target%/}
    done
  fi
  [ -d "${target:-/}" ] && target="$target/"

  cd -P "$PWD" 2>/dev/null || return 1
  while [ "$loop" -gt 0 ] && loop=$(($loop - 1)); do
    if [ ! "$target" = "${target%/*}" ]; then
      cd -P "${target%/*}/" 2>/dev/null || break
      target=${target##*/}
    fi

    if [ ! -L "$target" ]; then
      target="${PWD%/}${target:+/}$target"
      printf '%s\n' "${target:-/}"
      return 0
    fi

    link=$(ls -dl "$target" 2>/dev/null) || break
    target=${link#*" $target -> "}
  done
  return 1
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
