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
