@namespace "paths"


BEGIN {
    Working = ENVIRON["PWD"]
    Aho = "AHO_DIR" in ENVIRON ? ENVIRON["AHO_DIR"] : ".aho"
    # TODO: find root if we're deeper in the repo
}

# Fill array 'files' with all files matching 'pathspec'
function expand_pathspec(files, pathspec,    searchstr, cmd, dir, file, i)
{
    dir = dirname(pathspec)
    file = basename(pathspec)

    if (file && file != ".")
        searchstr = "-name '" file "'"

    cmd = "find " dir " -type f " \
        "-not -path '*/\\.git/*' " \
        "-not -path '*\\" Aho "/*' " \
        searchstr

    i = 1
    while ((cmd | getline file) > 0) {
        files[i++] = index(file, "./") ? substr(file, 3) : file # strip ./
    }

    close(cmd)
}

# Return directory part of path or '.' if no directory separator '/' in path
function dirname(path,    dir, found)
{
    found = match(path, "/[^/]*$")
    if (found) {
        dir = substr(path, 1, found - 1)
        return dir ? dir : "/"
    } else {
        return "."
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
