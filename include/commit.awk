@namespace "commit"


BEGIN {
    EditMsgPath = path::AhoDir "/COMMIT_EDITMSG"

}

function run_command(    shortopts, longopts, c, dryrun, file, message,
                         pathspec, got_pathspec)
{
    shortopts = "hF:m:"
    longopts = "help,dry-run,file:message:"

    while ((c = getopt::getopt(ARGC, ARGV, shortopts, longopts)) != -1) {
        if (c == "?") {
            print_usage()
            return 129
        }
        if (getopt::Optopt == "h" || getopt::Optopt == "help") {
            print_help()
            return 0
        }
        if (getopt::Optopt == "dry-run") {
            dryrun = 1
            continue
        }
        if (getopt::Optopt == "F" || getopt::Optopt == "file") {
            file = getopt::Optarg
            continue
        }
        if (getopt::Optopt == "m" || getopt::Optopt == "message") {
            message = getopt::Optarg
            continue
        }
    }

    if (message) {
        msg = message
    } else if (file) {
        msg = cleanup(file)
    } else {
        # Launch editor
        editor = config::get("core.editor")
        if (!editor) {
            editor = ENVIRON["EDITOR"]
        }
        if (!editor) {
            editor = "vi"
        }
        exit
        if (system(editor " " EditMsgPath) != 0) {
            print "error: There was a problem with the editor '" editor "'." \
                > "/dev/stderr"
            print "Please supply the message using either -m or -F option." \
                > "/dev/stderr"
        }
        msg = cleanup(EditMsgPath)
    }

    print "COMMIT_EDITMSG:"
    print msg
    print "Commit not implemented."
    exit

    while ((pathspec = ARGV[getopt::Optind++])) {
        got_pathspec = 1
        path::expand_pathspec(files, pathspec)
        if (length(files) == 0) {
            print "fatal: pathspec '" pathspec "' did not match any files" \
                > "/dev/stderr"
            return 128
        }
    }
}

# Read the contents of 'file' and return a "cleaned-up" string.
#
# From `man git-commit`, the strip and whitespace modes are described as:
# strip      - Strip leading and trailing empty lines, trailing whitespace,
#              commentary and collapse consecutive empty lines.
# whitespace - Same as strip except #commentary is not removed.
# default    - Same as strip if the message is to be edited. Otherwise
#              whitespace.
function cleanup(file, mode,    msg, in_msg, blank, fmt)
{
    if (!mode || mode == "default") {
        mode = (file == EditMsgPath) ? "strip" : "whitespace"
    }

    while ((getline line < file) > 0) {
        if (!in_msg && !line) {
            continue            # skip leading empty lines
        }
        in_msg = 1
        if (mode == "strip" && substr(line, 1, 1) == "#") {
            continue            # strip comments
        }
        if (line) {
            fmt = blank ? "\n%s\n" : "%s\n"
            sub("[[:blank:]]+$", "", line) # strip trailing whitespace
            msg = msg sprintf(fmt, line)
            blank = 0
        } else {
            blank = 1
        }
    }
    close(file)

    return msg
}

function print_usage()
{
    print "usage: aho commit [<options>] [--] <pathspec>..."
}

function print_help()
{
    print_usage()
    print
    print "  -n, --dry-run     Dry run"
    print "  -v, --verbose     Be verbose"
    print "  -F, --file        Read message from file"
    print "  -m, --message <message>\n                    Commit message"
}
