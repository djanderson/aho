@namespace "head"


BEGIN {
    Path = path::Aho "/HEAD"
}

function init(directory,    path)
{
    if (!directory) {
        print "Must pass directory to init" > "/dev/stderr"
        return 1
    }

    path = directory "/HEAD"

    print "ref: refs/heads/master" > path
}
