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

function long_status()
{
    return describe_head()
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
