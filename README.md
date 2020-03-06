# Portable readlink -f

Portable `readlink -f` implementation.

## readlinkf

Source code: [readlinkf.sh](readlinkf.sh)

### 1. readlinkf_readlink

Using `readlink` without `-f` option.

### 2. readlinkf_posix

Using `ls` and `cd`, not using `readlink`. (POSIX compliant)

## readlinkf_readlink vs readlinkf_posix

- `readlinkf_readlink`: Faster (about 1.5x - 2.0x).
- `readlinkf_posix`: More portability.

## Test

[![Build Status](https://travis-ci.org/ko1nksm/readlinkf.svg?branch=master)](https://travis-ci.org/ko1nksm/readlinkf)

The tests are compared with the result of `readlink -f` command.

If you want to test yourself, use `test.sh` script. Docker is required.
Because create a symbolic link safely on the root directory.

```sh
./test.sh [SHELL (default:sh)] [Dockerfile] [DOCKER-TAG (default: latest)]
```

Note: busybox (alpine) `readlink` is not compatibile with coreutils `readlink`.

```sh
./test.sh ash Dockerfile.alpine 3.11 # will fails
```

## License

Creative Commons Zero v1.0 Universal.
Feel free to modified or embed in your script.
