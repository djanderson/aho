@namespace "branches"


BEGIN {
    Dir = path::AhoDir "/branches"
}

function init(directory,    path)
{
    if (!directory) {
        print "Must pass directory to init" > "/dev/stderr"
        return 1
    }

    path = directory "/branches"

    return system("mkdir -p " path)
}
