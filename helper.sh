# shellcheck shell=sh

abort() {
  echo "$@" >&2
  exit 1
}

run() {
  echo "\$ " "$@"
  "$@"
}

make_dir() {
  run mkdir "$1"
}

make_file() {
  mkdir -p "$(dirname "$1")"
  run touch "$1"
}

make_link() {
  from=${1#*" -> "} to=${1%" -> "*}
  mkdir -p "$(dirname "$to")"
  run ln -s "$from" "$to"
}
