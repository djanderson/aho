# Aho

A Git implementation in AWK.

# But why?

This is a silly personal project to explore the deep corners of GNU Awk
(_gawk_) and Git.

# Capabilities

```bash
$ ./aho init  # initialize a Git repo
Initialized empty Git repository in .aho
$ ./aho add .  # add files to the object tree and index
$ GIT_DIR=.aho git ls-files --stage  # git can read the index
100664 d88545d4bb077b2e3fcefbddcf5bae071b426e9f 0	.gitignore
100664 a6ccf43e60c7876e67e3358952c0bf60a2882eef 0	LICENSE
100664 06ba7ad002f435d3f1f5dbf021021f2560363c09 0	README.md
100775 9fafffe816334a9fc749e78b6cd591fb8e32b6b4 0	aho
100664 f7d5b2ea0d7eb1b7801b6d01cd5914536d0f68a2 0	aho.awk
100664 c7d89dadeb1f8934f3552bb64b26b2d725f4f72d 0	include/add.awk
100664 184bb6f53d4110d0ec45df7f51a5cd4c2da981d2 0	include/branches.awk
100664 270a52d40ab63a720dcb0f9e9f04828ae24c6a09 0	include/config.awk
100664 629effea54a58d8734f57d9412a5964f69578477 0	include/getopt.awk
100664 d6d18f3fd4749812c04d704f0a6fb3915e559fab 0	include/head.awk
100664 98ff3d0993ea52a6a95a797428f18bddd80f26ba 0	include/index.awk
100664 92ce735a8d7e528f61905324fbe6118a79557add 0	include/init.awk
100664 50e74f2be9da7bf8d4edae0be0a9a1dda855ab6e 0	include/objects.awk
100664 44a22e0b97418e09b403a79c47a6f8092a9c0bee 0	include/paths.awk
100664 41eb8fd31ebbd8b403cb09a94f0eb4e7e420e1fc 0	include/refs.awk
100664 ee2ee78936c9d98b5dcef00a7de49adba474a800 0	include/utils.awk
100664 8a79bad5398edfa6d7e9ed53f5a8571c4acd51c8 0	include/version.awk
# blob objects are byte-compatible with git's
$ sha1sum .aho/objects/06/ba7ad002f435d3f1f5dbf021021f2560363c09 .git/objects/06/ba7ad002f435d3f1f5dbf021021f2560363c09 
94fb1982888bc5fb2d69c8f567afff55c84ca56b  .aho/objects/06/ba7ad002f435d3f1f5dbf021021f2560363c09
94fb1982888bc5fb2d69c8f567afff55c84ca56b  .git/objects/06/ba7ad002f435d3f1f5dbf021021f2560363c09
```

I don't plan to add network functionality to this (even though you totally
[can](https://www.gnu.org/software/gawk/manual/gawkinet/gawkinet.html)), so no
_clone_ or _push_.

# TODO:

- [X] init
- [X] add
- [ ] status
- [ ] commit
- [ ] config
- [ ] ls-files
- [ ] cat-file
