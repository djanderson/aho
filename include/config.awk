@namespace "config"


BEGIN {
    Path = path::AhoDir "/config"
}

function init(directory,    path)
{
    if (!directory) {
        print "Must pass directory to init" > "/dev/stderr"
        return 1
    }

    path = directory "/config"

    print "[core]" > path
    print "	repositoryformatversion = 0" >> path
    print "	filemode = true" >> path
    print "	bare = false" >> path
    print "	logallrefupdates = true" >> path
}
