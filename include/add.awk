@namespace "add"


function run_command(    shortopts, longopts, c, verbose, pathspec)
{
    shortopts = "hv"
    longopts = "help,verbose"

    while ((c = getopt::getopt(ARGC, ARGV, shortopts, longopts)) != -1) {
        if (c == "?") {
            print_usage()
            return 129
        }
        if (getopt::Optopt == "h" || getopt::Optopt == "help") {
            print_help()
            return 0
        }
        if (getopt::Optopt == "v" || getopt::Optopt == "verbose") {
            verbose = 1
            continue
        }
    }

    while ((pathspec = ARGV[getopt::Optind++])) {
        got_pathspec = 1
        paths::expand_pathspec(files, pathspec)
        if (length(files) == 0) {
            print "fatal: pathspec '" pathspec "' did not match any files"
            return 128
        }
        add_files(files, verbose)
    }

    if (!got_pathspec) {
        print "Nothing specified, nothing added." > "/dev/stderr"
        print "Maybe you want to say 'aho add .'?" > "/dev/stderr"
        return 0
    }
}

function add_files(files, verbose,    file, filename, added, size, hash)
{
    indexfile::add(files)
    # objects::add modifies the indexfile::Files array with computed sha1sum
    added = objects::add(files)
    if (added) {
        indexfile::write()   
        if (verbose) {
            for (file in files) {
                print "add '" files[file] "'"
            }
        }
    }
}

function print_usage()
{
    print "usage: aho add [<options>] [--] <pathspec>..."
}

function print_help()
{
    print_usage()
    print
    print "  -v, --verbose     Be verbose"
}
