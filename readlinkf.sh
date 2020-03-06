# shellcheck shell=sh

# readlink without -f option
readlinkf_readlink() {
  p=$1 && i=0 && [ -L "${p%/}" ] && [ ! -e "${p%/}" ] && p=${p%/}
  while [ $i -lt 10 ] && i=$((i+1)); do set -- "${p%/*}" "${p##*/}" /dev/null
    [ "$p" = "$1" ] || { [ ! "$1" ] || cd -P "$1" 2>"$3" || return 1; p=$2; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && return 0
    p=$(readlink "$p" 2>"$3") || return 1
  done; return 1 # maximum recursive loop exceeded
}

# POSIX compliant
readlinkf_posix() {
  p=$1 && i=0 && [ -L "${p%/}" ] && [ ! -e "${p%/}" ] && p=${p%/}
  while [ $i -lt 10 ] && i=$((i+1)); do set -- "${p%/*}" "${p##*/}" /dev/null
    [ "$p" = "$1" ] || { [ ! "$1" ] || cd -P "$1" 2>"$3" || return 1; p=$2; }
    [ ! -L "$p" ] && p=${PWD%/}${p:+/}$p && printf '%s\n' "${p:-/}" && return 0
    l=$(ls -dl "$p" 2>"$3") && p=${l#*" $p -> "} || return 1
  done; return 1 # maximum recursive loop exceeded
}
