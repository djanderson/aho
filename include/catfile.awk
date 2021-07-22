@namespace "catfile"


function run_command(    shortopts, longopts, c, show_type, show_size, type,
                         size, pprint, object, objpath)
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
        printf("%s", rest)
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
