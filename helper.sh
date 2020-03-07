# shellcheck shell=sh

abort() {
  printf '\033[31m[ERROR]\033[m %s\n' "$*"
  exit 1
}

fail() {
  msg=$1
  shift
  # shellcheck disable=SC2059
  printf "\033[31m[fail]\033[m $msg\n" "$@"
}

pass() {
  msg=$1
  shift
  # shellcheck disable=SC2059
  printf "\033[32m[pass]\033[m $msg\n" "$@"
}

run() {
  echo '$' "$@"
  "$@"
}

make_dir() {
  run mkdir -p "$1"
}

make_file() {
  mkdir -p "$(dirname "$1")"
  run touch "$1"
}

make_link() {
  from=${1#*" -> "} to=${1%" -> "*}
  mkdir -p "$(dirname "$to")"
  run ln -snf "$from" "$to"
}
