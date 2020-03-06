# Portable readlink -f

Portable `readlink -f` implementation.

## readlinkf

Source code: [readlinkf.sh](readlinkf.sh)

### 1. readlinkf_readlink

Using `readlink` without `-f` option.

### 2. readlinkf_posix

Using `ls` and `cd`, not using `readlink`. (POSIX compliant)

### readlinkf_readlink vs readlinkf_posix

- `readlinkf_readlink`: Probably fast (about 1.5x - 2.0x).
- `readlinkf_posix`: More portability.

### About coding style

I keep it short as possible not to lengthen your script.

## Test

[![Build Status](https://travis-ci.org/ko1nksm/readlinkf.svg?branch=master)](https://travis-ci.org/ko1nksm/readlinkf)

Tested with `ash` (busybox), `bash`, `dash`, `ksh`, `mksh`, `posh`, `yash`, `zsh` on Debian 10.
The tests are compared with the result of `readlink -f` command.

If you want to test yourself, use `test.sh` script. Docker is required.
Because create a symbolic link safely on the root directory.

```sh
./test.sh [SHELL (default:sh)] [Dockerfile] [DOCKER-TAG (default: latest)]
```

Note: The `readlink` built into busybox is not compatible with `readlink` of coreutils.

```sh
./test.sh ash Dockerfile.alpine 3.11 # will fails
```

## Supplementary information

### `cd` command compatibility

| [exit status] | ash | bash | bosh | dash | ksh | mksh | posh | yash | zsh |
| ------------- | --- | ---- | ---- | ---- | --- | ---- | ---- | ---- | --- |
| `cd  ""`      | 0   | 0    | 1    | 0    | 1   | 0    | 0    | 0    | 0   |
| `cd -P ""`    | 0   | 1    | 1    | 0    | 1   | 1    | 1    | 1    | 0   |
| `cd -L ""`    | 0   | 0    | 1    | 0    | 1   | 0    | 0    | 0    | 0   |

### `readlink` command compatibility

coreutils

```sh
$ cd /tmp
$ ln -s no-such-a-file symlink

$ readlink symlink
no-such-a-file # exit status: 0

$ readlink -f symlink
/tmp/no-such-a-file # exit status: 0

$ cd /
$ readlink -f /tmp/symlink
/tmp/no-such-a-file # exit status: 0
```

busybox 1.31.1

```sh
$ cd /tmp
$ ln -s no-such-a-file symlink

# OK
$ readlink symlink
no-such-a-file # exit status: 0

# BAD
$ readlink -f symlink
<none> # exit status: 1

# BAD
$ cd /
$ readlink -f /tmp/symlink
/tmp/symlink # exit status: 0
```

macOS

```sh
$ cd /tmp
$ ln -s no-such-a-file symlink

# OK
$ readlink symlink
no-such-a-file # exit status: 0

# -f not implemented
$ readlink -f symlink
readlink: illegal option -- f # exit status: 1
```

## License

Creative Commons Zero v1.0 Universal.
Feel free to modified or embed in your script.
