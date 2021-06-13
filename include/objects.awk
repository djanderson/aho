@namespace "objects"


BEGIN {
    Path = paths::Aho "/objects"
}

function init(directory,    path) {
    if (!directory) {
        print "Must pass directory to init" > "/dev/stderr"
        return 1
    }

    path = directory "/objects"

    return system("mkdir -p " path)
}
