@namespace "status"

BEGIN {
    delete Untracked      # in working tree but not in index
    delete Modified       # in working tree and index, but differ in working tree
    delete Deleted        # in index but not in working tree

    delete StagedNew      # in index but not in latest commit
    delete StagedModified # in index and latest commit, but different in index
    delete StagedDeleted  # in latest commit but not in index

    compare_working_tree_to_index()
    compare_index_to_commit()
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

    # git status will automatically refresh the index - man git-status
    indexfile::write()

    for_commit = 0
    colors = 1
    print long_status(for_commit, colors)
}

# for_commit: bool - produce long status variant for inclusion in commit
# colors: bool - colorize output
function long_status(for_commit, colors,    status, file)
{
    # 1. Branch or detached HEAD commit
    # 2. Differences between index file and current HEAD commit
    # 3. Paths that have differences between the working tree and the index file
    # 4. Paths in the working tree that are in the index (and not ignored)
    status = describe_head()

    if (!head::Commit) {
        if (for_commit) {
            status = status "\nInitial commit\n"
        } else {
            status = status "\nNo commits yet\n"
        }
    }

    PROCINFO["sorted_in"] = "@val_str_asc"

    if (have_staged()) {
        status = status "\nChanges to be committed:\n"
        status = status "  (use \"aho rm --cached <file>...\" to unstage)\n"
        if (colors) {
            status = status colors::Green
        }
        for (file in StagedNew) {
            status = status "\tnew file:   " StagedNew[file] "\n"
        }
        for (file in StagedModified) {
            status = status "\tmodified:   " StagedModified[file] "\n"
        }
        for (file in StagedDeleted) {
            status = status "\tdeleted:   " StagedDeleted[file] "\n"
        }
        if (colors) {
            status = status colors::Reset
        }
    }

    if (length(Modified) || length(Deleted)) {
        status = status "\nChanges not staged for commit:\n"
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

    if (length(Untracked)) {
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

        if (!have_staged()) {
            status = status "\nnothing added to commit but untracked files"
            status = status " present (use \"aho add\" to track)"
        }
    }

    return status
}

# Set Modified, Deleted, and Untracked
function compare_working_tree_to_index(    relpath)
{
    for (relpath in workingtree::Stats) {
        if (indexfile::has_file(relpath)) {
            if (!indexfile::entry_up_to_date(workingtree::Stats[relpath])) {
                Modified[length(Modified) + 1] = relpath
            }
        } else {
            if (!stat::s_isdir(workingtree::Stats[relpath]["mode"])) {
                Untracked[length(Untracked) + 1] = relpath
            }
        }
    }
    for (relpath in indexfile::Entries) {
        if (!(relpath in workingtree::Stats)) {
            Deleted[length(Deleted) + 1] = relpath
        }
    }
}

function compare_index_to_commit(    relpath, obj, commit, commit_files)
{
    if (!indexfile::Exists) {
        # There are no staged files
        return
    }

    if (!head::Commit) {
        # All files in the index are new
        for (relpath in indexfile::Entries) {
            StagedNew[length(StagedNew) + 1] = relpath
        }
        return
    }

    # Read and parse the commit file pointed to by HEAD

    delete obj
    delete commit
    delete commit_files

    if (!objects::read_object(obj, head::Commit)) {
        print "error: can't read HEAD file " head::Commit > "/dev/stderr"
        return
    }
    if (obj["type"] != "commit") {
        print "error: HEAD " head::Commit " not a commit" > "/dev/stderr"
        return
    }
    if (!objects::parse_commit(commit, obj["bytes"])) {
        print "error: can't parse HEAD commit " head::Commit > "/dev/stderr"
        return
    }

    # Recursively parse tree objects to build an array of files in this commit

    delete obj

    if (!objects::read_object(obj, commit["tree"])) {
        print "error: can't read tree file " commit["tree"] > "/dev/stderr"
        return
    }
    if (obj["type"] != "tree") {
        print "error: " commit["tree"] " not a tree" > "/dev/stderr"
        return
    }
    # Since parse_tree is recursive, re-append a tree file header
    if (!objects::parse_tree(commit_files, "tree 0\0" obj["bytes"])) {
        print "error: can't parse tree " commit["tree"] > "/dev/stderr"
        return
    }

    # Compare the index and commit
    # - in index but not in commit -> StagedNew
    # - in index and commit but different in index -> StagedModified
    # - in commit but not in index -> StagedDeleted

    for (relpath in indexfile::Entries) {
        if (relpath in commit_files) {
            if (indexfile::Entries[relpath]["object-id"] != \
                commit_files[relpath]["object-id"]) {
                StagedModified[length(StagedModified) + 1] = relpath
            }
        } else {
            StagedNew[length(StagedNew) + 1] = relpath
        }
    }
    for (relpath in commit_files) {
        if (!indexfile::has_file(relpath)) {
            Deleted[length(Deleted) + 1] = relpath
        }
    }
}

function describe_head()
{
    if (head::Branch) {
        return "On branch " head::Branch "\n"
    } else if (head::Commit) {
        return "HEAD detached at " utils::short_hash(head::Commit) "\n"
    }
}

# FIXME: name reads bad (status::have_staged)
function have_staged() {
    return length(StagedNew) || length(StagedModified) || length(StagedDeleted)
}

function print_usage()
{
    print "usage: aho status [<options>] [--] <pathspec>..."
}

function print_help()
{
    print_usage()
}
