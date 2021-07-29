@namespace "tree"


# Given an array of filenames, create a multidimentional tree structure.
# For example, the file list
#
#    test
#    test/README.md
#    test/a
#    test/run
#    test/dir
#    test/dir/b
#    test/dir/c
#    aho.awk
#    LICENSE
#    aho
#
# produces the tree stucture
#
#    tree["test"]["README.md"] = ""
#    tree["test"]["a"] = ""
#    tree["test"]["run"] = ""
#    tree["test"]["dir"]["b"] = ""
#    tree["test"]["dir"]["c"] = ""
#    tree["aho.awk"] = ""
#    tree["LICENSE"] = ""
#    tree["aho"] = ""
#
# If the value is an (empty) string, the index represents a filename. If the
# value is an array, the index represents a directory name. And empty
# directory's value is an empty array.
function add_files(tree, files,    file, parts)
{
    PROCINFO["sorted_in"] = "@val_type_asc"
    for (file in files) {
        file = files[file]
        if (path::is_file(file)) { # skip directory names
            split(file, parts, "/")
            tree::add_file(tree, parts, length(parts), 1)
        }
    }
}

# Given file "test/dir/c", add tree["test"]["dir"]["c"] = ""
#
# Based on https://stackoverflow.com/a/43946907
function add_file(tree, parts, nparts, depth, empty)
{
    if (empty) {
        delete tree[EMPTYTREE]
        empty = 0
    }
    if (depth < nparts) {
        if (!(parts[depth] in tree)) {
            tree[parts[depth]][EMPTYTREE] # ensure tree[parts[depth]] is array
            empty = 1
        }
        tree::add_file(tree[parts[depth]], parts, nparts, depth + 1, empty)
    } else {
        tree[parts[depth]] = ""
    }
}

# Walk tree depth-first
function walk_dfs(tree, visitdir, leavedir, visitfile)
{
    PROCINFO["sorted_in"] = "@val_type_desc" # visit (dir) subarrays first
    walk(tree, visitdir, leavedir, visitfile)
}

# Walk tree breadth-first
function walk_bfs(tree, visitdir, leavedir, visitfile)
{
    PROCINFO["sorted_in"] = "@val_type_asc"  # visit (file) strings first
    walk(tree, visitdir, leavedir, visitfile)
}

# Walk a tree.
#
# If not called via `walk_dfs` or `walk_bfs` above, you are responsible for
# selecting the scan order of the tree.
#
# visitdir  - optional string name of function to call when entering directory,
#             takes single parameter, name of dir without trailing /
# leavedir  - optional string name of function to call when exiting directory,
#             takes single parameter, name of dir without trailing /
# visitfile - optional string name of function to call when visiting file,
#             takes single parameter, filename
function walk(tree, visitdir, leavedir, visitfile,     dir, path) {
    if (visitdir) {
        @visitdir(dir)
    }
    for (name in tree) {
        path = dir ? dir "/" name : name
        if (awk::typeof(tree[name]) == "array") {
            walk(tree[name], visitdir, leavedir, visitfile, path)
        } else {
            # leaf
            if (visitfile) {
                @visitfile(name)
            }
        }
    }
    if (leavedir) {
        @leavedir(dir)
    }
}

# Make a deep copy of 'orig' into 'copy'
#
# https://stackoverflow.com/a/62179751
function clone(orig, copy,    i)
{
    # Empty "copy" for first call and delete the temp array added by
    # copy[i][EMPTYARRAY] below for subsequent
    delete copy

    for (i in orig) {
        if (awk::isarray(orig[i])) {
            copy[i][EMPTYARRAY]
            clone(orig[i], copy[i])
        } else {
            copy[i] = orig[i]
        }
    }
}

# Populate 'difftree' with all elements that are in tree 'a' but not in tree 'b'
function diff(a, b, difftree,    i)
{
    clone(a, difftree)
    remove_tree(difftree, b)
}

# Remove tree 'b' from 'a'. 'a' is modified, 'b' is not.
function remove_tree(a, b)
{
    for (i in b) {
        if (awk::isarray(b[i])) {
            if (i in a) {
                remove_tree(a[i], b[i])
            }
        } else {
            delete a
        }
    }
}

# Example visitdir parameter for tree::walk
function visitdir(dir)
{
    print "starting dir: " dir
}

# Example leavedir parameter for tree::walk
function leavedir(dir)
{
    print "done dir: " dir
}

# Example visitfile parameter for tree::walk
function visitfile(file)
{
    print "done file: " file
}

# Print the tree; return the printed string
function debug_print(tree, indent, depth, acc,    name, line)
{
    # The following will cause a breadth-first search because files (string
    # value types) are visited before directories (array value types)
    PROCINFO["sorted_in"] = "@val_type_asc"
    indent = awk::typeof(indent) == "untyped" ? 2 : indent
    for (name in tree) {
        if (awk::typeof(tree[name]) == "array") {
            line = sprintf("%" depth * indent "s%s\n", "", name "/")
            printf(line)
            acc = acc line
            acc = debug_print(tree[name], indent, depth + 1, acc)
        } else {
            line = sprintf("%" depth * indent "s%s\n", "", name)
            printf(line)
            acc = acc line
        }
    }
    return acc
}


#######
# TESTS
#######

function test_debug_print(    tree, actual, expected)
{
    delete tree
    delete tree["test"]
    tree["test"]["README.md"] = ""
    tree["test"]["a"] = ""
    tree["test"]["run"] = ""
    delete tree["test"]["dir"]
    tree["test"]["dir"]["b"] = ""
    tree["test"]["dir"]["c"] = ""
    tree["aho.awk"] = ""
    tree["LICENSE"] = ""
    tree["aho"] = ""

    actual = debug_print(tree)
    expected =          \
        "LICENSE\n"     \
        "aho\n"         \
        "aho.awk\n"     \
        "test/\n"       \
        "  README.md\n" \
        "  a\n"         \
        "  run\n"       \
        "  dir/\n"      \
        "    b\n"       \
        "    c\n"

    utils::assert(actual == expected, "test_debug_print")
}

function test_clone(    tree, copy)
{
    delete tree
    delete tree["test"]
    tree["test"]["a"] = ""
    delete tree["test"]["dir"]
    tree["test"]["dir"]["b"] = ""

    clone(tree, copy)

    utils::assert(length(copy) == 1, "length(copy) == 1")
    utils::assert("test" in copy, "\"test\" in copy")
    utils::assert(length(copy["test"]) == 2, "length(copy[\"test\"]) == 2")
    utils::assert("a" in copy["test"], "\"a\" in copy[\"test\"]")
    utils::assert(copy["a"] == "", "copy[\"a\"] == \"\"")
    utils::assert("dir" in copy["test"], "\"dir\" in copy[\"test\"]")
    utils::assert(awk::typeof(copy["dir"] == "array"), "typeof(copy[\"dir\"] == \"array\")")
    utils::assert("b" in copy["test"]["dir"], "\"b\" in copy[\"test\"][\"dir\"]")
    utils::assert(copy["test"]["dir"]["b"] == "", "copy[\"test\"][\"dir\"][\"b\"] == \"\"")
}

function test_diff(    a, b, difftree)
{
    delete a
    delete a["test"]
    a["test"]["a"] = ""
    delete a["test"]["dir"]
    a["test"]["dir"]["b"] = ""

    delete b
    delete b["test"]
    delete b["test"]["dir"]
    b["test"]["dir"]["b"] = ""

    delete difftree
    diff(a, b, difftree)

    utils::assert(length(difftree) == 1, "length(difftree) == 1")
    utils::assert("test" in difftree, "\"test\" in difftree")
    utils::assert(length(difftree["test"]) == 2, "length(difftree[\"test\"]) == 2")
    utils::assert("a" in difftree["test"], "\"a\" in difftree[\"test\"]")
    utils::assert(difftree["a"] == "", "difftree[\"a\"] == \"\"")
    utils::assert("dir" in difftree["test"], "\"dir\" in difftree[\"test\"]")
    utils::assert(!("b" in difftree["test"]["dir"]), "!(\"b\" in difftree[\"test\"][\"dir\"])")
}
