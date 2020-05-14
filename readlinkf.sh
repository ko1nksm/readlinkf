#!/bin/sh

# POSIX compliant version
# Usage: readlinkf_readlink <varname> <path>
readlinkf_posix() {
  if [ $# -gt 1 ]; then
    eval "$1=\$(readlinkf_posix \"\$2\")"
  else
    [ ${1:+x} ] || return 1
    target=$1 loop=10 CDPATH=""

    if [ ! -e "${target%/}" ]; then
      while [ ! "${target%/}" = "$target" ]; do
        target=${target%/}
      done
    fi
    [ -d "${target:-/}" ] && target="$target/"

    cd -P "$PWD" 2>/dev/null || return 1
    while [ "$loop" -gt 0 ] && loop=$((loop - 1)); do
      if [ ! "$target" = "${target%/*}" ]; then
        cd -P "${target%/*}/" 2>/dev/null || break
        target=${target##*/}
      fi

      if [ ! -L "$target" ]; then
        target="${PWD%/}${target:+/}$target"
        printf '%s\n' "${target:-/}"
        return 0
      fi

      # See https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html
      # "%s -> %s", <pathname of link>, <contents of link>
      link=$(ls -dl "$target" 2>/dev/null) || break
      target=${link#*" $target -> "}
    done
    return 1
  fi
}

# readlink version
# Usage: readlinkf_readlink <varname> <path>
readlinkf_readlink() {
  if [ $# -gt 1 ]; then
    eval "$1=\$(readlinkf_readlink \"\$2\")"
  else
    [ ${1:+x} ] || return 1
    target=$1 loop=10 CDPATH=""

    if [ ! -e "${target%/}" ]; then
      while [ ! "${target%/}" = "$target" ]; do
        target=${target%/}
      done
    fi
    [ -d "${target:-/}" ] && target="$target/"

    cd -P "$PWD" 2>/dev/null || return 1
    while [ "$loop" -gt 0 ] && loop=$((loop - 1)); do
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
  fi
}

# Run as a command is an example.
case ${0##*/} in (readlinkf_posix | readlinkf_readlink)
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
