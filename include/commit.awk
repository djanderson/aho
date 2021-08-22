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
        prepare_editmsg_file()

        # Launch editor
        editor = config::get("core.editor")
        if (!editor) {
            editor = ENVIRON["EDITOR"]
        }
        if (!editor) {
            editor = "vi"
        }
        if (system(editor " " EditMsgPath) != 0) {
            print "error: There was a problem with the editor '" editor "'." \
                > "/dev/stderr"
            print "Please supply the message using either -m or -F option." \
                > "/dev/stderr"
            exit 1
        }
        msg = cleanup(EditMsgPath)
    }

    if (!msg) {
        print "Aborting commit due to empty commit message." > "/dev/stderr"
        return 1
    }

    do_commit(msg)
}

function do_commit(msg,    indextree, datetime_cmd, tree_hash, datetime, c,
                           name, email, commit_hash)
{
    for (file in indexfile::Entries) {
        if (indexfile::Entries[file]["removed"]) {
            continue
        }
        tree::add_file(indextree, file)
    }

    tree::set_dfs()
    tree_hash = commit_indextree(indextree)

    datetime_cmd = "date '+%s %z'"
    datetime_cmd | getline datetime
    close(datetime_cmd)

    name = config::get("user.name")
    email = config::get("user.email")

    # Build the commit file contents
    c = "tree " tree_hash "\n"
    if (parent) {
        c = c "parent " parent_hash "\n"
    }
    c = c "author " name " <" email "> " datetime "\n"
    c = c "committer " name " <" email "> " datetime "\n"
    c = c "\n"
    c = c msg

    commit_hash = objects::add_commit(c)

    # FIXME: msg summary, insertions, deletions, etc
    print "[" head::Branch " " utils::short_hash(commit_hash) "] " msg
}

# Recursively walk the index tree and add tree objects
function commit_indextree(tree, dir,    path, contents, c, save_sorted, t, hash)
{
    delete contents                # contents in this directory (tree)
    for (name in tree) {
        path = dir ? dir "/" name : name
        if (awk::typeof(tree[name]) == "array") {
            # Recurse next tree
            hash = commit_indextree(tree[name], path)
            contents[path] = sprintf( \
                "%o %s\0%s",
                stat::ModeDir,
                path,
                utils::hex_to_bytes(hash))
        } else {
            # Add file to current tree's content
            contents[path] = sprintf( \
                "%o %s\0%s",
                indexfile::Entries[path]["mode"],
                path,
                utils::hex_to_bytes(indexfile::Entries[path]["object-id"], 20))
        }
    }

    # End of dir: re-read contents in alphabetical order and build tree file
    # contents, then add it to objects store
    save_sorted = PROCINFO["sorted_in"]
    PROCINFO["sorted_in"] = "@ind_str_asc"

    t = ""
    for (c in contents) {
        t = t contents[c]
    }
    hash = objects::add_tree(t)

    PROCINFO["sorted_in"] = save_sorted

    return hash
}

function prepare_editmsg_file(    status, for_commit, color, status_lines,
                                  line, s)
{
    for_commit = 1
    color = 0
    status = status::long_status(for_commit, color)
    split(status, status_lines, "\n")

    s = "\n\n"
    s = s "# Please enter the commit message for your changes. Lines starting\n"
    s = s "# with '#' will be ignored, and an empty message aborts the commit.\n"
    s = s "#\n"

    PROCINFO["sorted_in"] = "@ind_num_asc"
    for (line in status_lines) {
        s = s "# " status_lines[line] "\n"
    }

    print s > EditMsgPath
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
