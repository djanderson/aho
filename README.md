# Aho

A Git implementation in AWK.

# But why?

I've had the irrational desire to write something substantial in AWK for a
while. Figured I might as well learn some Git internals while I scratch this
itch.

# Quickstart

You'll need `gawk` >= 5.0, and I currently use `pigz` for zlib compression.
Everything else should be provided by GNU coreutils. In other words, this
should run on most linuxes, not so much on BSDs/Mac.

```bash
$ source ./modpath
$ aho init
Initialized empty Git repository in .aho
$ aho add -v .
add '.gitignore'
add 'LICENSE'
add 'README.md'
add 'aho'
add 'aho.awk'
add 'include/add.awk'
add 'include/branches.awk'
add 'include/config.awk'
[...]
$ echo "neat" > testfile
$ aho add -v .
add 'testfile'
$ tree .aho/
.aho/
├── branches
├── config
├── description
├── HEAD
├── index
├── objects
│   ├── 16
│   │   └── dfbb852d5efb5e1a75ad336c8f62ebb94a82f0
│   ├── 42
│   │   └── 2c6135819b57720ace71e3c6c97eb072b5b430
│   ├── 51
│   │   └── 2807153b4d4abffab8490ce97e5a164fe7de1f
│   ├── 62
│   │   └── 9effea54a58d8734f57d9412a5964f69578477
│   ├── 64
│   │   └── c66bb623af4a10aa3bca2da143c75ab4e2186f
[...]
└── refs
    ├── heads
    └── tags

29 directories, 29 files
$ GIT_DIR=.aho git ls-files --stage
100664 d88545d4bb077b2e3fcefbddcf5bae071b426e9f 0	.gitignore
100664 a6ccf43e60c7876e67e3358952c0bf60a2882eef 0	LICENSE
100664 f88631a9692c0b9f9bc2f484c6fc68587bb90770 0	README.md
100775 8657d76021987bc2cd3c2d4c5958fdab053c6326 0	aho
100664 f2aeb629f8513094675557138b3f83dbfa5a4895 0	aho.awk
100664 b1c9cc72d22414a18635d33656dbc216ff774e57 0	include/add.awk
100664 512807153b4d4abffab8490ce97e5a164fe7de1f 0	include/branches.awk
100664 16dfbb852d5efb5e1a75ad336c8f62ebb94a82f0 0	include/config.awk
[...]
```

# Contributing

I welcome any input that helps improve my knowledge of AWK or Git!

# TODO:

- [X] init
- [X] add/rm
- [X] status
- [ ] commit
- [ ] reset
- [ ] branch
- [ ] switch
- [X] config (read-only)
- [ ] ls-files
- [X] cat-file

I don't plan to add network functionality to this (even though you totally
[can](https://www.gnu.org/software/gawk/manual/gawkinet/gawkinet.html)), so no
_clone_ or _push_.
