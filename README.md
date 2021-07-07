# Aho

A Git implementation in AWK.

# But why?

To explore the deep corners of GNU Awk (_gawk_) and Git.

 - Can AWK read and write Git's binary `index` file?
 - Where does AWK start to break down as a general-purpose programming language?
 - How does Git magic actually work?
 - etc...

# Quickstart

You'll need `gawk` >= 5.0, and I currently use `pigz` for zlib compression.
Everything else should be provided by coreutils.

```bash
$ source ./modpath
$ aho init
Initialized empty Git repository in .aho
$ aho add -v .
add 'LICENSE'
add 'modpath'
add 'include/add.awk'
add 'include/refs.awk'
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
│   ├── 75
│   │   └── c4bb2d662072539ec9c9df59e0bc38b08859a1
│   ├── 86
│   │   └── 57d76021987bc2cd3c2d4c5958fdab053c6326
│   ├── 8a
│   │   └── 79bad5398edfa6d7e9ed53f5a8571c4acd51c8
│   ├── 90
│   │   └── f5018152506ead374c091df7aa4bd50d1f2711
│   ├── 91
│   │   └── 89ced5c87ed27aba7e69056a4977707f8eea1f
│   ├── 92
│   │   └── 9acae2b1c6a028db6fd951ec409cb403e7c644
│   ├── a4
│   │   ├── f760268b8927dde9e5c456c6609f966596726b
│   │   └── f8a94be65ff3db1e4eae6f1b2d17be29549831
│   ├── a6
│   │   └── ccf43e60c7876e67e3358952c0bf60a2882eef
│   ├── a9
│   │   └── 622230b6300414b725e4f30bdd7384036eadec
│   ├── ae
│   │   └── 8710f78478cd81223c6129aaadd3b9c0bbfac9
│   ├── b1
│   │   └── c9cc72d22414a18635d33656dbc216ff774e57
│   ├── b7
│   │   └── c251ec5e8689b8b8198e80c87bad85981e2633
│   ├── bc
│   │   └── e7654988c975a479cefa67dc22aad49a22569d
│   ├── be
│   │   └── be8ccf15bc60314702a9a00e1416fc9b223b00
│   ├── d8
│   │   └── 8545d4bb077b2e3fcefbddcf5bae071b426e9f
│   ├── e3
│   │   └── 451647a3d96b27022772ac1a6b864868a2ec22
│   ├── ea
│   │   └── b633c732fc64ee486eeb22c0e588d110b64a09
│   ├── f2
│   │   └── aeb629f8513094675557138b3f83dbfa5a4895
│   └── f8
│       └── 8631a9692c0b9f9bc2f484c6fc68587bb90770
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

I don't plan to add network functionality to this (even though you totally
[can](https://www.gnu.org/software/gawk/manual/gawkinet/gawkinet.html)), so no
_clone_ or _push_.

# TODO:

- [X] init
- [X] add/rm
- [ ] status
- [ ] commit
- [ ] config
- [ ] ls-files
- [ ] cat-file
