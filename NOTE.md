# NOTE

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
