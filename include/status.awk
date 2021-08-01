@namespace "status"

BEGIN {

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

    print long_status()
}

function long_status(    status)
{
    # 1. Branch or detached HEAD commit
    # 2. Differences between index file and current HEAD commit
    # 3. Paths that have differences between the working tree and the index file
    # 4. Paths in the working tree that are in the index (and not ignored)
    status = describe_head()


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
