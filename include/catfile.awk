@namespace "catfile"


function run_command(    shortopts, longopts, c, show_type, show_size, type,
                         size, pprint, hash, obj, objpath)
{
    shortopts = "htsp"
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
        if (getopt::Optopt == "t") {
            show_type = 1
            continue
        }
        if (getopt::Optopt == "s") {
            show_size = 1
            continue
        }
        if (getopt::Optopt == "p") {
            pprint = 1
            continue
        }
    }

    if (!(hash = ARGV[getopt::Optind++])) {
        print_help()
        exit 129
    }
    objpath = objects::find_file(hash)
    if (!objpath) {
        print "fatal: Not a valid object name " hash  > "/dev/stderr"
        return 128
    }

    delete obj
    if (!objects::read_objfile(obj, objpath)) {
        # FIXME: what's the right error msg?
        print "fatal: not a valid object" > "/dev/stderr"
        return 128
    }

    if (show_size) {
        print obj["size"]
    } else if (show_type) {
        print obj["type"]
    } else if (pprint) {
        if (obj["type"] == "tree") {
            print_tree(obj["bytes"])
        } else {
            printf("%s", obj["bytes"])
        }
    }
}

function print_tree(rest,    mode, path, hash, type)
{
    while (match(rest, /([^[:blank:]]*) ([^\0]*)\0(.{20})/, groups) > 0) {
        rest = substr(rest, RLENGTH + 1)

        mode = awk::strtonum("0" groups[1]) # append 0 to force read as octal
        path = groups[2]
        hash = utils::bytes_to_hex(groups[3], 40)
        type = (mode == stat::ModeDir) ? "tree" : "blob"

        printf("%06o %s %s\t%s\n", mode, type, hash, path)
    }
}

function print_usage()
{
    print "usage: aho cat-file [<options>] [--] <object>"
}

function print_help()
{
    print_usage()
    print
    print "  -t                Show object type"
    print "  -s                Show object size"
    print "  -p                Pretty-print object's content"
}
