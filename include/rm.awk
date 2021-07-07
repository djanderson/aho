@namespace "rm"


function run_command(    shortopts, longopts, c, dryrun, quiet, cached,
                         recurse, force, files, pathspec, got_pathspec)
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
        } else if (getopt::Optopt == "q" || getopt::Optopt == "quiet") {
            quiet = 1
        } else if (getopt::Optopt == "cached") {
            cached = 1
        } else if (getopt::Optopt == "f" || getopt::Optopt == "force") {
            force = 1
        } else if (getopt::Optopt == "r") {
            recurse = 1
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
        remove_files(pathspec, files, dryrun, quiet, cached, force, recurse)
    }

    if (!got_pathspec) {
        print_help()
        return 129
    }
}

function remove_files(pathspec, files, dryrun, quiet, cached, recurse, force,
                      
                      n, modified, file, filestr, cmd)
{
    # Check that all files are tracked in the index
    for (file in files) {
        file = files[file]
        if (!indexfile::has_file(file)) {
            print "fatal: pathspec '" file "' did not match any files"
            exit 128
        }
    }

    # Just marks index[file][removed] = 1; not applied until indexfile::write
    indexfile::remove_files(files)

    if (!force) {
        delete modified
        for (file in files) {
            file = files[file]
            if (!indexfile::file_up_to_date(file)) {
                modified[n++] = file
            }
        }
        if (n) {
            filestr = n > 1 ? "files have" : "file has"
            print "error: the following " filestr " local modifications:" \
                > "/dev/stderr"
            for (file in modified) {
                print "    " file > "/dev/stderr"
            }
            print "(use --cached to keep the file, or -f to force removal)" \
                > "/dev/stderr"
            exit 1
        }
    }

    if (!dryrun) {
        # Do the deletion
        if (!cached) {
            if (recurse) {
                cmd = "rm -r "
            } else {
                cmd = "rm "
            }
            utils::assert(!system(cmd pathspec), "rm command failed")
        }
        
        indexfile::write()
    }
    
    if (!quiet) {
        PROCINFO["sorted_in"] = "@val_str_asc"
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
