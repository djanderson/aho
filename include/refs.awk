@namespace "refs"


BEGIN {
    Dir = path::AhoDir "/refs"
}

function init(directory,    path)
{
    if (!directory) {
        print "Must pass directory to init" > "/dev/stderr"
        return 1
    }

    path = directory "/refs"

    return system("mkdir -p " path "/heads " path "/tags")
}
