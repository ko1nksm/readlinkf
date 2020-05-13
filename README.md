# Portable readlink -f

Portable `readlink -f` implementation.

## readlinkf

Source code: [readlinkf.sh](readlinkf.sh)
(I keep it short as possible not to lengthen your script)

### 1. readlinkf_readlink

Using `pwd`, `cd` and `readlink` without `-f` option.

### 2. readlinkf_posix

Using `pwd`, `cd` and `ls -dl`. (POSIX compliant)

### readlinkf_readlink vs readlinkf_posix

- `readlinkf_readlink`: Probably fast (about 1.5x - 2.0x).
- `readlinkf_posix`: POSIX compliant and more portability.

### NOTE

The function uses `cd` command internally, however it not affected by `CDPATH`.

The function uses variable `p` internally.
Therefore, it will be changed after the call unless using subshell.

Current directory and other variables `PWD`, `OLDPWD` and `CDPATH` not change
(unless change to the original directory fails).

```sh
# The variable `p` will be changed.
p=foo
readlinkf_posix "$path"
echo "$p" # => not foo

# It uses subshell. Therefore, the variable `p` not change.
p=foo
link=$(readlinkf_posix "$path")
echo "$p" # => foo
```

## Test

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

- 2020-05-13 Release v1.0.0

## License

Creative Commons Zero v1.0 Universal.
Feel free to modified or embed in your script.
