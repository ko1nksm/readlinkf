# readlinkf

Portable `readlink -f` implementation.

## 1. readlinkf_readlink

Using `readlink` without `-f` option.

## 2. readlinkf_posix

POSIX compliant. Using `ls` and `cd`, Not using `readlink`.

## Test

The tests are compared with the result of `readlink -f` command.
