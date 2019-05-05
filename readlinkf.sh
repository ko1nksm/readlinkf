#shellcheck shell=sh

# readlink (without -f option) implementation
readlinkf() {
  p=$1 i=0
  [ -L "${p%/}" ] && [ ! -e "${p%/}" ] && p=${p%/}
  while [ $i -lt 10 ]; do
    case $p in (*/*) cd -P "${p%/*}" 2>/dev/null || return 1; p=${p##*/}; esac
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && return 0
    p=$(readlink "$p" 2>/dev/null) || return 1
    i=$((i+1))
  done
  return 1
}

# POSIX compliant implementation
readlinkf_posix() {
  p=$1 i=0
  [ -L "${p%/}" ] && [ ! -e "${p%/}" ] && p=${p%/}
  while [ $i -lt 10 ]; do
    case $p in (*/*) cd -P "${p%/*}" 2>/dev/null || return 1; p=${p##*/}; esac
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && return 0
    l=$(ls -dl "$p" 2>/dev/null) || return 1
    p=${l#*" $p -> "} i=$((i+1))
  done
  return 1
}
