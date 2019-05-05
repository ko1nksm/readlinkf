#!/bin/sh

set -eu

docker build -t readlinkf ./ >&2

docker run --rm readlinkf

# docker rmi readlinkf
