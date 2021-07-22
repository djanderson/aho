@namespace "objects"


BEGIN {
    if ("AHO_OBJECT_DIRECTORY" in ENVIRON) {
        Dir = ENVIRON["AHO_OBJECT_DIRECTORY"]
    } else {
        Dir = path::AbsAhoDir "/objects"
    }
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
        if (indexfile::file_up_to_date(filename)) {
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
function add_blob(filename, size,    blob, hash, first2, rest, objfile)
{
    blob = "blob " size "\0" utils::readfile(filename)
    hash = utils::sha1sum_str(blob)

    first2 = substr(hash, 1, 2)
    rest = substr(hash, 3)
    if (system("mkdir -p " objects::Dir "/" first2) != 0) {
        print "Failed to make object path" > "/dev/stderr"
        return 0
    }

    objfile = objects::Dir "/" first2 "/" rest

    if (zlib_compress(blob, objfile)) {
        return hash
    } else {
        print "Failed to zlib compress object" > "/dev/stderr"
        return 0
    }
}

# zlib compress 'bytes' and write them to 'path' - directory must exist
function zlib_compress(bytes, filepath,    zlib, check)
{
    zlib = "pigz --zlib --fast --stdout > " filepath
    printf("%s", bytes) | zlib
    close(zlib)
    check = ! system("pigz -t " filepath)
    return check
}

# zlib decompress 'path' into string 'bytes'
function zlib_decompress(path, bytes,    zlib, save_rs)
{
    save_rs = RS
    RS = "^$"

    zlib = "cat " path " | pigz --decompress"
    printf("%s", path) |& zlib
    close(zlib, "to")           # close outbound pipe or coprocess will hang
    zlib |& getline bytes
    close(zlib, "from")
    RS = save_rs

    return bytes
}

# Return path relative to repo root for an object file
#
# 'object' can be a full or partial sha1
function find_file(object,    first2, rest, dir, cmd, path, n)
{
    if (length(object) < 4) {
        return                  # too short
    }

    first2 = substr(object, 1, 2)
    rest = substr(object, 3)
    dir = objects::Dir "/" first2
    cmd = "find " dir " -type f -name '" rest "*'"
    while ((cmd | getline path) > 0) {
        n++
    }

    # If n > 1, then 'object' was too short and matched multiple files
    if (n == 1) {
        return path
    }
}

# Return sha1 of an object if it's in the repo
function find(object,    path, sha1)
{
    if (!(path = find_file(object))) {
        return
    }
    sha1 = substr(path, length(objects::Dir) + 2) # strip objects dir
    # sha1 will look like 3c/531cd5095969e63a90e614ac3c2b53e4841658; strip /
    sub("/", "", sha1)
    return sha1
}
