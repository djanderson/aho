# Utils and metadata
@include "version.awk"
@include "paths.awk"
@include "getopt.awk"
# Commands
@include "init.awk"


function print_usage() {
    print "usage: aho [--version] [--help] <command> [<args>]"
}

function print_help() {
    print_usage()
    print
    print "Commands:"
    print "  init        Create an empty repo"
    print "  add         Add file contents to the index"
}

function print_version() {
    print "aho version " version::String
}

BEGIN {
    if (ARGC == 1) {
        print_help()
        exit 1
    }

    getopt::Optind = 1          # start at first option
    getopt::Opterr = 1          # print parse errors

    shortopts = "h"
    longopts = "version,help"

    while ((c = getopt::getopt(ARGC, ARGV, shortopts, longopts)) != -1) {
        if (c == "?") {
            usage()
            exit 129
        }
        if (getopt::Optopt == "h" || getopt::Optopt == "help") {
            print_help()
            exit 0
        }
        if (getopt::Optopt == "version") {
            print_version()
            exit 0
        }
    }

    command = ARGV[getopt::Optind]

    if (command == "init") {
        init::init()
    } else if (command == "add") {
        add::add()
    } else {
        print "aho: " command " is not an aho command. See 'aho --help'\n" \
            > "/dev/stderr"
        print_usage()
        exit 1
    }
}
