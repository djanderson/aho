@namespace "init"


function run_command(    c, shortopts, longopts, quiet, directory, path, errors)
{
    shortopts = "hq"
    longopts = "help,quiet"

    while ((c = getopt::getopt(ARGC, ARGV, shortopts, longopts)) != -1) {
        if (c == "?") {
            print_usage()
            return 129
        }
        if (getopt::Optopt == "h" || getopt::Optopt == "help") {
            print_help()
            return 0
        }
        if (getopt::Optopt == "q" || getopt::Optopt == "quiet") {
            quiet = 1
            continue
        }
    }

    directory = ARGV[getopt::Optind++]
    if (ARGV[getopt::Optind]) {     # shouldn't have anything after directory
        print_usage()
        return 129
    }

    if (directory) {
        sub(/\/$/, "", directory)   # remove trailing slash
        path = directory "/" path::AhoDir
    } else {
        path = path::AhoDir
    }

    # Fail if path already exists or if we can't create it
    if (system("test -d " path) == 0) {
        print path " already exists" > "/dev/stderr"
        return 1
    } else if (system("mkdir -p " path) != 0) {
        return 1
    }

    print "Unnamed repository; edit this file 'description' to name" \
        " the repository." > (path "/description")

    errors = 0
    errors += branches::init(path)
    errors += config::init(path)
    errors += head::init(path)
    errors += objects::init(path)
    errors += refs::init(path)

    if (!quiet && !errors) {
        print "Initialized empty Git repository in " path
    }

    return errors
}

function print_usage()
{
    print "usage: aho init [-q | --quiet] [<directory>]"
}

function print_help()
{
    print_usage()
    print
    print "  -q, --quiet     Be quiet"
}
