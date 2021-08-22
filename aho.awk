@include "version.awk"
@include "utils.awk"
@include "path.awk"
@include "tree.awk"
@include "stat.awk"
@include "getopt.awk"
@include "refs.awk"
@include "branches.awk"
@include "objects.awk"
@include "head.awk"
@include "index.awk"
@include "workingtree.awk"
@include "colors.awk"
# Commands
@include "config.awk"
@include "init.awk"
@include "add.awk"
@include "rm.awk"
@include "status.awk"
@include "commit.awk"
@include "catfile.awk"

@namespace "main"


BEGIN {
    if (ARGC == 1) {
        print_help()
        exit 1
    }

    exit main()
}

function main(    shortopts, longopts, c, command, exitcode)
{
    getopt::Optind = 1          # start at first option
    getopt::Opterr = 1          # print parse errors

    shortopts = "h"
    longopts = "version,help"

    while ((c = getopt::getopt(ARGC, ARGV, shortopts, longopts)) != -1) {
        if (c == "?") {
            print_usage()
            return 129
        }
        if (getopt::Optopt == "h" || getopt::Optopt == "help") {
            print_help()
            return 0
        }
        if (getopt::Optopt == "version") {
            print_version()
            return 0
        }
    }

    command = ARGV[getopt::Optind++]

    if (command != "init") {
        path::assert_in_repo()
    }

    if (command == "init") {
        exitcode = init::run_command()
    } else if (command == "add") {
        exitcode = add::run_command()
    } else if (command == "rm") {
        exitcode = rm::run_command()
    } else if (command == "commit") {
        exitcode = commit::run_command()
    } else if (command == "cat-file") {
        exitcode = catfile::run_command()
    } else if (command == "status") {
        exitcode = status::run_command()
    } else if (command == "config") {
        exitcode = config::run_command()
    } else {
        print "aho: " command " is not an aho command. See 'aho --help'\n" \
            > "/dev/stderr"
        print_usage()
        exitcode = 1
    }
    return exitcode
}

function print_usage()
{
    print "usage: aho [--version] [--help] <command> [<args>]"
}

function print_help()
{
    print_usage()
    print
    print "Commands:"
    print "  init        Create an empty repo"
    print "  add         Add file contents to the index"
    print "  rm          Remove files from the working tree and from the index"
    print "  config      Read or modify " path::AhoDir "/config"
    print "  status      Show the working tree status"
    print "  commit      Record changes to the repository"
}

function print_version()
{
    print "aho version " version::String
}
