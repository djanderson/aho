@namespace "catfile"


function run_command(    shortopts, longopts, c, show_type, show_size, type,
                         size, pprint, object, bytes, objpath, end_of_hdr,
                         end_of_type, header, rest)
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

    if (!(object = ARGV[getopt::Optind++])) {
        print_help()
        exit 129
    }
    objpath = objects::find_file(object)
    if (!objpath) {
        print "fatal: Not a valid object name " object
        return 128
    }

    bytes = objects::zlib_decompress(objpath)
    end_of_hdr = index(bytes, "\0")
    header = substr(bytes, 1, end_of_hdr - 1)
    end_of_type = index(header, " ")
    type = substr(header, 1, end_of_type - 1)
    size = awk::strtonum(substr(header, end_of_type + 1))
    if (show_size) {
        print size
    } else if (show_type) {
        print type
    } else if (pprint) {
        rest = substr(bytes, end_of_hdr + 1)
        if (type == "tree") {
            print_tree(rest)
        } else {
            printf("%s", rest)
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
