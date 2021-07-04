@namespace "rm"


function run_command(    shortopts, longopts, c, dryrun, quiet, recurse,
                         cached, files, pathspec)
{
    shortopts = "hnqr"
    longopts = "help,dry-run,quiet,cached"

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
        if (getopt::Optopt == "q" || getopt::Optopt == "quiet") {
            quiet = 1
            continue
        }
        if (getopt::Optopt == "r") {
            recurse = 1
            continue
        }
        if (getopt::Optopt == "cached") {
            cached = 1
            continue
        }
    }

    while ((pathspec = ARGV[getopt::Optind++])) {
        got_pathspec = 1
        delete files

        if (path::is_dir(pathspec) && !recurse) {
            print "fatal: not removing '" pathspec "' recursively without -r" \
                > "/dev/stderr"
            return 128
        }
        path::expand_pathspec(files, pathspec)
        if (length(files) == 0) {
            print "fatal: pathspec '" pathspec "' did not match any files"
            return 128
        }
        remove_files(files, dryrun, quiet, recurse, cached)
    }

    if (!got_pathspec) {
        print_help()
        return 129
    }
}

function remove_files(files, dryrun, quiet, recurse, cached)
{
    
    if (!quiet) {
        for (file in files) {
            file = files[file]
            print "rm '" file "'"
        }
    }
}

function print_usage()
{
    print "usage: aho rm [<options>] [--] <file>..."
}

function print_help()
{
    print_usage()
    print
    print "  -n, --dry-run     Dry run"
    print "  -q, --quiet       Do not list removed files"
    print "  --cached          Only remove from the index"
    print "  -f, --force       Override the up-to-date check"
    print "  -r                Allow recursive removal"
}
