@namespace "objects"


BEGIN {
    Path = path::Aho "/objects"
}

function init(directory,    path)
{
    if (!directory) {
        print "Must pass directory to init" > "/dev/stderr"
        return 1
    }

    path = directory "/objects"

    return system("mkdir -p " path)
}

function add(files,    file, filename, size, hash, num_added)
{
    for (file in files) {
        filename = files[file]
        if (indexfile::up_to_date(filename)) {
            continue
        }
        size = indexfile::Files[filename]["size"]
        hash = add_blob(filename, size)
        if (hash) {
            indexfile::Files[filename]["object-id"] = hash
            num_added++
        }
    }

    return num_added
}

# Add file object to tree and return sha1 hash or 0 if failed
function add_blob(filename, size,    blob, line, sha1sum, hash, first2, rest,
                                     objfile, zlib)
{
    blob = "blob " size "\x00"
    while ((getline line < filename) > 0) {
        blob = blob line "\n"
    }
    close(filename)

    hash = utils::sha1sum_str(blob)

    first2 = substr(hash, 1, 2)
    rest = substr(hash, 3)
    if (system("mkdir -p " objects::Path "/" first2) != 0) {
        print "Failed to make object path" > "/dev/stderr"
        return 0
    }

    objfile = objects::Path "/" first2 "/" rest
    zlib = "pigz --zlib --fast --stdout > " objfile
    printf("%s", blob) | zlib
    close(zlib)

    if (system("test -e " objfile) == 0) {
        return hash
    } else {
        return 0
    }
}
