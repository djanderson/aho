# Aho

A Git implementation in AWK.

# But why?

To explore the deep corners of GNU Awk (_gawk_) and Git.

 - Can AWK read and write Git's binary `index` file?
 - Where does AWK start to break down as a general-purpose programming language?
 - How does Git magic actually work?
 - etc...

I will write-up my takeaways in this README as I get more features implemented.

# Quickstart

You'll need `gawk` >= 5.0, and I currently use `pigz` for zlib compression.
Everything else should be provided by coreutils.

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

This is a toy project just for fun and learning. Therefore, Issues are closed
(I know there are many!). I would be happy to evaluate Pull requests fixing
 - blatant errors
 - areas where AWK can be made more effective or idiomatic
 - misunderstandings of Git internals

I'm not looking for new-feature PRs at this time, but feel free to fork and
play along.

[Discussions](https://github.com/djanderson/aho/discussions) are open for
ideas, questions, etc.

Thanks!

# TODO:

- [X] init
- [X] add/rm
- [ ] status
- [ ] commit
- [ ] config
- [ ] ls-files
- [X] cat-file

I don't plan to add network functionality to this (even though you totally
[can](https://www.gnu.org/software/gawk/manual/gawkinet/gawkinet.html)), so no
_clone_ or _push_.
