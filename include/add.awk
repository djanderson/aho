@namespace "add"


function run_command(    shortopts, longopts, c, dryrun, verbose, pathspec,
                         got_pathspec, files)
{
    shortopts = "hvn"
    longopts = "help,verbose,dry-run"

    while ((c = getopt::getopt(ARGC, ARGV, shortopts, longopts)) != -1) {
        if (c == "?") {
            print_usage()
            return 129
        }
        if (getopt::Optopt == "h" || getopt::Optopt == "help") {
            print_help()
            return 0
        }
        if (getopt::Optopt == "n" || getopt::Optopt == "dry-run") {
            dryrun = 1
            continue
        }
        if (getopt::Optopt == "v" || getopt::Optopt == "verbose") {
            verbose = 1
            continue
        }
    }

    while ((pathspec = ARGV[getopt::Optind++])) {
        got_pathspec = 1
        path::expand_pathspec(files, pathspec)
        if (length(files) == 0) {
            print "fatal: pathspec '" pathspec "' did not match any files"
            return 128
        }
        add_files(files, dryrun, verbose)
    }

    if (!got_pathspec) {
        print "Nothing specified, nothing added." > "/dev/stderr"
        print "Maybe you want to say 'aho add .'?" > "/dev/stderr"
        return 0
    }
}

function add_files(files, dryrun, verbose,    file, added)
{
    indexfile::add(files)

    if (!dryrun) {
        # objects::add adds object-id to indexfile::Files array
        added = objects::add(files)
        if (added) {
            indexfile::write()
        }
    }

    if (verbose) {
        PROCINFO["sorted_in"] = "@val_str_asc"
        for (file in files) {
            file = files[file]
            if (!indexfile::file_up_to_date(file)) {
                print "add '" file "'"
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
    print "  -n, --dry-run     Dry run"
    print "  -v, --verbose     Be verbose"
}
