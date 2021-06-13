# Aho

A Git implementation in AWK.

# But why?

- I want to better understand git iternals
- I like AWK

# Capabilities

I don't plan to add network functionality to this (even though you totally
[can](https://www.gnu.org/software/gawk/manual/gawkinet/gawkinet.html)), so no
_clone_ or _push_.

If I can figure out how to do the `index` file, it will be a minor miracle.
Maybe I'll write a C
[extension](https://www.gnu.org/software/gawk/manual/html_node/Dynamic-Extensions.html)
for that?

# TODO:

- [X] init
- [ ] add
- [ ] status
- [ ] commit
- [ ] config
- [ ] ls-files
- [ ] cat-file
