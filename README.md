# POSIX compliant readlink -f

POSIX compliant `readlink -f` implementation for POSIX shell scripts.

## Why?

The `readlink` and the `realpath` commands are not specified POSIX and some environments may not be installed.
There are many implementation alternatives to `readlink -f` ([\[1\]][1], [\[2\]][2], [\[3\]][3]).
Some of them probably work, but It has some edge case bugs, unresolved issues,
no tests, poor performance, long code, bashism, non-POSIX compliant and license problem.
This feature is important to access files on relative paths from the main script.
I couldn't find any reliable code despite of.

[1]: https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
[2]: https://stackoverflow.com/questions/59895/how-to-get-the-source-directory-of-a-bash-script-from-within-the-script-itself
[3]: https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself

## readlinkf

Source code: [readlinkf.sh](readlinkf.sh)

Short code version has been temporarily removed. See [v1.0.0](https://github.com/ko1nksm/readlinkf/releases/tag/v1.0.0) if you need it.

### Usage

  1. `varname=$(readlinkf_* "<path>")` (assign to variable)
  2. `(readlinkf_* "<path>")` (output to stdout)
  3. `readlinkf_* "<path>"` (output to stdout, not recommended)

Note: Usage 1 and 2 use subshells and therefore have no side effects. It does
not change the current directory and any variables. Usage 3 has side effects.

The maximum depth of symbolic links is 40. This value is the same as defined in Linux kernel 5.6. (See [MAXSYMLINKS](MAXSYMLINKS))
However, `readlink -f` has not limitation. If you want to change, modify `max_symlinks` variable in these function.

[MAXSYMLINKS]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/namei.h?h=v5.6&id=7111951b8d4973bda27ff663f2cf18b663d15b48#n13

### 1. readlinkf_posix

This implementation uses `cd -P` and `ls -dl`.

#### How it works

It parsing the output of `ls -dl` and resolve symbolic links.

```sh
ls -dl: "%s %u %s %s %u %s %s -> %s\n",
  <file mode>, <number of links>, <owner name>, <group name>,
  <size>, <date and time>, <pathname of link>, <contents of link>
```

The format of `ls -dl` is specified in [POSIX](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html).

> If the file is a symbolic link and the -L option is not specified, this
> information shall be about the link itself and the `<pathname>` field shall be of the form:
>
> `"%s -> %s", <pathname of link>, <contents of link>`

### 2. readlinkf_readlink

This implementation uses `cd -P` and `readlink` (without `-f`).

Note: Probably fast than `readlinkf_posix`, but `readlink` is not POSIX compliant.
It may not be installed in some environments.

## Limitation

`readlinkf` cannot handle filenames that end with a newline.
It is very rare case, therefore I chose performance and code simplicity.

## About the test

[![Test Results](https://img.shields.io/cirrus/github/ko1nksm/readlinkf/master?label=Test%20results&style=for-the-badge)](https://cirrus-ci.com/github/ko1nksm/readlinkf/master)

Tested with `ash` (busybox), `bosh`, `bash`, `dash`, `ksh`, `mksh`, `posh`, `yash`, `zsh` on Debian.
And tested on macOS, FreeBSD, Cygwin, Msys2 and Git BASH.
The tests are compared with the result of GNU `readlink -f` (`greadlink`) command.

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

## Changelog

- v1.0.0: 2020-05-13 Short code version
- v1.1.0: 2020-06-20: Friendly version

## License

Creative Commons Zero v1.0 Universal.
Feel free to modified or embed in your script.
