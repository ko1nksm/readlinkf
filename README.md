# POSIX compliant readlink -f

POSIX compliant `readlink -f` shell function implementation for POSIX shell.

## readlinkf

Source code: [readlinkf.sh](readlinkf.sh)

Note: These functions have no side effects after calling.
Does not change the current directory and any variables.

Maximum depth of symbolic links is 10.
Please modify the source code if you want to change.

### 1. readlinkf_posix

*Usage:* `readlinkf_posix <varname> <path>`

This function using `cd -P` and `ls -dl`.

### 2. readlinkf_readlink

*Usage:* `readlinkf_readlink <varname> <path>`

This function using `cd -P` and `readlink` (without `-f`).

Note: Probably fast than `readlinkf_posix`, but `readlink` is not POSIX compliant.
It may not be installed in some environments.

## About test

[![Test Results](https://img.shields.io/travis/ko1nksm/readlinkf/master.svg?label=Test%20results&style=for-the-badge)](https://travis-ci.org/ko1nksm/readlinkf)

Tested with `ash` (busybox), `bosh`, `bash`, `dash`, `ksh`, `mksh`, `posh`, `yash`, `zsh` on Debian.
The tests are compared with the result of GNU `readlink -f` command.

If you want to test yourself, use `test.sh` script.
Root privilege is required for edge case test around the root directory.
Therefore using Docker by default for safely create files on the root directory.

```sh
./test.sh [SHELL (default:sh)] [Dockerfile] [DOCKER-TAG (default: latest)]
```

Note: The `readlink` built into busybox is not compatible with `readlink` of GNU coreutils.

```sh
./test.sh ash dockerfiles/alpine 3.11 # will fails
```

If you want to test without Docker, set `ALLOW_CREATION_TO_THE_ROOT_DIRECTORY`
environment variable. Check `test.sh` script for what it do before running it.

```sh
sudo ALLOW_CREATION_TO_THE_ROOT_DIRECTORY=1 ./test.sh
```

## Supplementary information

### `cd` command compatibility

| [exit status] | ash | bash | bosh | dash | ksh | mksh | posh | yash | zsh |
| ------------- | --- | ---- | ---- | ---- | --- | ---- | ---- | ---- | --- |
| `cd  ""`      | 0   | 0    | 1    | 0    | 1   | 0    | 0    | 0    | 0   |
| `cd -P ""`    | 0   | 1    | 1    | 0    | 1   | 1    | 1    | 1    | 0   |
| `cd -L ""`    | 0   | 0    | 1    | 0    | 1   | 0    | 0    | 0    | 0   |

### `readlink` command compatibility

GNU coreutils

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

## Changelog

- v1.0.0: 2020-05-13 Short code version
- Unreleased: Friendly version

## License

Creative Commons Zero v1.0 Universal.
Feel free to modified or embed in your script.
