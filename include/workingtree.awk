@namespace "workingtree"


BEGIN {

    delete Ignore
    if (path::InRepo) {
        load_ignore(Ignore, path::Root "/.gitignore")
        load_ignore(Ignore, path::AbsAhoDir "/info/exclude")
    }

    delete Files
    if (path::InRepo) {
        load_files(Files, path::Root, Ignore)
    }

    delete Stats
    if (path::InRepo) {
        stat::stat_files(Stats, Files)
    }

    delete Tree
    if (path::InRepo) {
        tree::add_files(Tree, Files)
    }
}

function load_ignore(ignore, ignorefile,    line, n)
{
    if (path::is_file(ignorefile)) {
        n = length(ignore) + 1
        while ((getline line < ignorefile) > 0) {
            if (line && !match(line, /^#/)) { # skip blank and comment lines
                if (match(line, /^!/)) {
                    print "warning: aho does not support the '!' syntax " \
                        "in .gitignore"                                   \
                        > "/dev/stderr"
                    continue
                }
                ignore[n++] = line
            }
        }
        close(ignorefile)
    }
}

# Load all files in the working tree at root, except those matched in ignore
#
# The way this function works in principle is to convert each line in a
# .gitignore file into a term in a `find` command. If the pattern is a
# directory (ends with /), then any matching directory is pruned with the
# syntax
#
#     \( -type d -[whole]name PAT -prune \)
#
# otherwise either a file or directory can be ignored with the syntax
#
#     -not -[whole]name PAT1 -not -[whole]name PAT2 ... -print
#
# where PAT and name/wholename are combined to best match the described
# behavior in `man gitignore`.
#
# files - empty array to be populated with working tree files
# ignored - empty array to be populated with ignored working tree files
# root - path string for repo root
# ignore - array of patterns to ignore
function load_files(files, root, ignore,    find, i, pat, lpat, isep,
                                            predicate, first2, all_others,
                                            prune_dir, file)
{
    # Find's -name/-wholename accept a fnmatch syntax similar to .gitignore's
    find = "cd " root "; find . \\( -type d -wholename './.git' -prune \\) "

    for (i in ignore) {
        pat = ignore[i]
        lpat = length(pat)
        isep = index(pat, "/")
        if ((prune_dir = substr(pat, lpat, 1) == "/")) {
            pat = substr(pat, 1, lpat - 1) # strip trailing /
        }
        if (isep == 1)  {
            # Pattern like /abc/ - indicates directory in repo root
            pat = "." pat
            predicate = "-wholename"
        } else if (isep && isep < lpat) {
            # Patterns like ./abc/, abc/def/, **/abc/
            first2 = substr(pat, 1, 2)
            if (first2 != "./" && first2 != "**") {
                pat = "./" pat
            }
            predicate = "-wholename"
        } else {
            predicate = "-name"
        }

        if (prune_dir) {
            find = find "-or \\( -type d " predicate " '" pat "' -prune \\) "
        } else {
            # Ignore file _or_ dir matching pat
            all_others = all_others "-not " predicate " '" pat "' "
        }
    }

    find = find "-or " all_others "-print"

    # Run the command
    i = 1
    while ((find | getline file) > 0) {
        if (file != ".") {
            files[i++] = substr(file, 3) # drop leading ./
        }
    }
    close(find)
}
