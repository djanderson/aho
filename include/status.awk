@namespace "status"

BEGIN {
    delete Modified    # in working tree and index, but differ in working tree
    delete Deleted     # in index but not in working tree
    delete Untracked   # in working tree but not in index
}

function run_command(    shortopts, longopts, c)
{
    shortopts = "h"
    longopts = "help"

    while ((c = getopt::getopt(ARGC, ARGV, shortopts, longopts)) != -1) {
        if (c == "?") {
            print_usage()
            return 129
        }
        if (getopt::Optopt == "h") {
            print_help()
            return 0
        }
    }

    compare_working_tree_to_index()

    colors = 1
    print long_status(colors)
}

# Set Modified, Deleted, and Untracked
function compare_working_tree_to_index(    filename)
{
    for (filename in workingtree::Stats) {
        if (indexfile::has_file(filename)) {
            if (!indexfile::entry_up_to_date(workingtree::Stats[filename])) {
                Modified[length(Modified) + 1] = filename
            }
        } else {
            if (!stat::s_isdir(workingtree::Stats[filename]["mode"])) {
                Untracked[length(Untracked) + 1] = filename
            }
        }
    }
    for (filename in indexfile::Entries) {
        if (!(filename in workingtree::Stats)) {
            Deleted[length(Deleted) + 1] = filename
        }
    }
}

function long_status(colors,    status, file)
{
    # 1. Branch or detached HEAD commit
    # 2. Differences between index file and current HEAD commit
    # 3. Paths that have differences between the working tree and the index file
    # 4. Paths in the working tree that are in the index (and not ignored)
    status = describe_head()

    if (length(Modified) > 0 || length(Deleted) > 0) {
        status = status "\n\nChanges not staged for commit:\n"
        status = status "  (use \"aho add <file>...\" to update what will be committed)\n"
        status = status "  (use \"aho restore <file>...\" to discard changes in working directory)\n"
        if (colors) {
            status = status colors::Red
        }
        for (file in Modified) {
            status = status "\tmodified:   " Modified[file] "\n"
        }
        for (file in Deleted) {
            status = status "\tdeleted:    " Deleted[file] "\n"
        }
        if (colors) {
            status = status colors::Reset
        }
    }

    if (length(Untracked) > 0) {
        status = status "\nUntracked files:\n"
        status = status "  (use \"aho add <file>...\" to include in what will be committed)\n"
        if (colors) {
            status = status colors::Red
        }
        for (file in Untracked) {
            status = status "\t" Untracked[file] "\n"
        }
        if (colors) {
            status = status colors::Reset
        }
    }

    return status
}

function describe_head()
{
    if (head::Branch) {
        return "On branch " head::Branch
    } else if (head::Commit) {
        return "HEAD detached at " utils::short_hash(head::Commit)
    }
}

function print_usage()
{
    print "usage: aho status [<options>] [--] <pathspec>..."
}

function print_help()
{
    print_usage()
}
