@namespace "path"


BEGIN {
    Working = ENVIRON["PWD"]
    Home = ENVIRON["HOME"]

    if ("AHO_DIR" in ENVIRON) {
        AhoDir = ENVIRON["AHO_DIR"]
        if (path::is_absolute(AhoDir)) {
            AbsAhoDir = AhoDir
            Root = dirname(AhoDir)
        } else {
            AbsAhoDir = Working "/" AhoDir
            Root = Working
        }
    } else {
        AhoDir = ".aho"
        Root = find_root(Working)
        AbsAhoDir = Root "/" AhoDir
    }

    InRepo = is_dir(AbsAhoDir)
}

function find_root(    dir)
{
    if (is_dir(dir == "/" ? dir AhoDir : dir "/" AhoDir)) {
        # Found the repo root, return it
        return dir
    }
    if (dir == Home || dir == "/") {
        # Don't look any further
        return
    }
    # Look in parent directory
    dir = substr(dir, 1, match(dir, /\/[^\/]*$/) - 1)
    return find_root(dir ? dir : "/")
}

# Check that we're in a valid AhoDir repo or die
function assert_in_repo()
{
    if (!InRepo) {
        printf("%s", "fatal: not a git repository") > "/dev/stderr"
        if (!("AHO_DIR" in ENVIRON)) {
            printf("%s", " (or any of the parent directories)") > "/dev/stderr"
        }
        print ": " AhoDir > "/dev/stderr"
        exit 128
    }
}

# Fill array 'files' with all files matching 'pathspec'
function expand_pathspec(files, pathspec,    searchstr, find, dir, file, i,
                                             len_root)
{
    dir = path::Working "/"
    if (pathspec != "." && is_dir(pathspec)) {
        dir = dir pathspec
    } else {
        dir = dir dirname(pathspec)
        file = basename(pathspec)
    }

    if (file && file != ".")
        searchstr = "-name '" file "'"

    find = "find " dir " -type f " \
        "-not -path '*/\\.git/*' " \
        "-not -path '*/\\.aho/*' " \
        "-not -path '*\\" AhoDir "/*' " \
        searchstr

    i = 1
    len_root = length(path::Root)
    while ((find | getline file) > 0) {
        files[i++] = substr(file, len_root + 2)
    }
    close(find)
}

# Return directory part or an empty string if no directory separator in path
function dirname(path,    dir, found)
{
    found = match(path, "/[^/]*$")
    if (found) {
        dir = substr(path, 1, found - 1)
        return dir ? dir : "/"
    }
}

# Return filename part of path or empty string if path ends in '/'
function basename(path,    found)
{
    found = match(path, "/[^/]*$")
    if (found) {
        return substr(path, found + 1)
    } else {
        return path
    }
}

function is_dir(path)
{
    if (path) {
        return system("test -d " path) == 0
    } else {
        return 0
    }
}

function is_file(path)
{
    if (path) {
        return system("test -f " path) == 0
    } else {
        return 0
    }
}

# Return true if a path string starts with "/"
function is_absolute(path)
{
    return substr(path, 1, 1) == "/"
}


function exists(path)
{
    if (path) {
        return system("test -e " path) == 0
    } else {
        return 0
    }
}

# Given an array of filenames, return a multidimentional tree structure.
# For example, for the file list
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
#    tree["test"] = [
#        "README.md" = "",
#        "a" = "",
#        "run" = "",
#        "dir" = [
#            "b" = "",
#            "c" = ""
#        ]
#    ]
#    tree["aho.awk"] = ""
#    tree["LICENSE"] = ""
#    tree["aho"] = ""
#
function make_tree(tree, files,    file)
{
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (file in files) {

    }
}

# Print the tree; return the printed string
function print_tree(tree, indent, depth, acc,    name, line)
{
    PROCINFO["sorted_in"] = "@val_type_asc" # breadth-first search
    indent = awk::typeof(indent) == "untyped" ? 2 : indent
    for (name in tree) {
        if (awk::typeof(tree[name]) == "array") {
            line = sprintf("%" depth * indent "s%s\n", "", name "/")
            printf(line)
            acc = acc line
            acc = print_tree(tree[name], indent, depth + 1, acc)
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

function test_print_tree(    tree, actual, expected)
{
    delete tree
    delete test["test"]
    tree["test"]["README.md"] = ""
    tree["test"]["a"] = ""
    tree["test"]["run"] = ""
    delete tree["test"]["dir"]
    tree["test"]["dir"]["b"] = ""
    tree["test"]["dir"]["c"] = ""
    tree["aho.awk"] = ""
    tree["LICENSE"] = ""
    tree["aho"] = ""

    actual = print_tree(tree)
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

    utils::assert(actual == expected, "test_print_tree")
}
