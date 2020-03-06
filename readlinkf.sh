#shellcheck shell=sh

# readlink without -f option
readlinkf_readlink() {
  p=$1 && i=0 && [ -L "${p%/}" ] && [ ! -e "${p%/}" ] && p=${p%/}
  while [ $i -lt 10 ] && i=$((i+1)); do # maximum recursion depth
    set -- "$p" "${p%/*}" "${p##*/}" /dev/null
    [ "$1" = "$2" ] || { [ ! "$2" ] || cd -P "$2" 2>"$4" || return 1; p=$3; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && return 0
    p=$(readlink "$p" 2>"$4") || return 1
  done; return 1
}

# POSIX compliant
readlinkf_posix() {
  p=$1 && i=0 && [ -L "${p%/}" ] && [ ! -e "${p%/}" ] && p=${p%/}
  while [ $i -lt 10 ] && i=$((i+1)); do # maximum recursion depth
    set -- "$p" "${p%/*}" "${p##*/}" /dev/null
    [ "$1" = "$2" ] || { [ ! "$2" ] || cd -P "$2" 2>"$4" || return 1; p=$3; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && return 0
    l=$(ls -dl "$p" 2>"$4") && p=${l#*" $p -> "} || return 1
  done; return 1
}
