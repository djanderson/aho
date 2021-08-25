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

function add_files(files,    file, filename, size, hash, num_added)
{
    for (file in files) {
        filename = files[file]
        if (indexfile::file_up_to_date(filename)) {
            continue
        }
        size = indexfile::Entries[filename]["size"]
        hash = add_blob(filename, size)
        if (hash) {
            indexfile::Entries[filename]["object-id"] = hash
            num_added++
        }
    }

    return num_added
}

function add_blob(filename, size)
{
    return add_object(utils::readfile(filename), size, "blob")
}

function add_tree(tree)
{
    return add_object(tree, length(tree), "tree")
}

function add_commit(commit)
{
    return add_object(commit, length(commit), "commit")
}

function add_object(content, size, type,    bytes, hash, first2, rest, objfile)
{
    utils::assert(type == "blob" || type == "tree" || type == "commit",
                  "objects::add_object, unknown object type '" type "'")

    bytes = type " " size "\0" content
    hash = utils::sha1sum_str(bytes)

    first2 = substr(hash, 1, 2)
    rest = substr(hash, 3)
    if (system("mkdir -p " objects::Dir "/" first2) != 0) {
        print "Failed to make object path" > "/dev/stderr"
        return 0
    }

    objfile = objects::Dir "/" first2 "/" rest

    if (zlib_compress(bytes, objfile)) {
        return hash
    } else {
        print "Failed to zlib compress object" > "/dev/stderr"
        return 0
    }
}

# Like read_objfile, but hash may be partial
#
# Return 1 on success, else 0.
function read_object(obj, hash)
{
    if ((objpath = find_file(hash))) {
        obj[EMPTYARRAY]
        return read_objfile(obj, objpath)
    }
    return 0
}

# Given a full commit hash, read the corresponding object file into 'obj'.
#
# The following array structure is used:
#
#   object["type"] = "blob" | "tree" | "commit"
#   object["size"] = num
#   object["bytes"] = raw decompressed bytes after header
#
function read_objfile(obj, objpath,    bytes, end_of_header, header,
                                       end_of_type, type, size,
                                       bytes_after_header)
{
    bytes = objects::zlib_decompress(objpath)
    end_of_hdr = index(bytes, "\0")
    header = substr(bytes, 1, end_of_hdr - 1)
    end_of_type = index(header, " ")
    type = substr(header, 1, end_of_type - 1)
    size = awk::strtonum(substr(header, end_of_type + 1))
    bytes_after_header = substr(bytes, length(header) + 2)

    delete obj
    obj["type"] = type
    obj["size"] = size
    obj["bytes"] = bytes_after_header

    if (type == "blob" || type == "tree" || type == "commit") {
        return 1
    }
    return 0
}

# Given the FULL bytes of a tree object, populate 'files' with all files
# in the tree or subtree.
#
# parse_tree creates a 2-dimensional array of the form:
#
#   files["file1"]["mode"]      = num: raw mode
#   files["file1"]["size"]      = num: file size in bytes
#   files["file1"]["object-id"] = str: sha1sum of object
#   files["dir1/file2"]["mode"]
#   files["dir1/file2"]["size"]
#   files["dir1/file2"]["object-id"]
#   ...
#
# Return 1 on success, else 0.
function parse_tree(files, bytes,    mode, rawmode, path, relpath,
                                     hashbytes, sha1)
{
    if (!match(bytes, /^tree [[:digit:]]+\0/)) {
        print "error: object file is not a tree" > "/dev/stderr"
        return 0
    }
    bytes = substr(bytes, RLENGTH + 1)

    while (match(bytes, /([[:digit:]]+) ([^\0]*)\0(.{20})/, obj)) {
        mode = 1; relpath = 2; hashbytes = 3
        rawmode = awk::strtonum("0" obj[mode])
        bytes = substr(bytes, RLENGTH + 1)
        sha1 = utils::bytes_to_hex(obj[hashbytes], 40)
        if (rawmode == stat::ModeDir) {
            # Recurse into next tree
            objpath = sha1_to_path(sha1)
            if (!parse_tree(files, zlib_decompress(objpath), obj[relpath])) {
                return 0
            }
        } else {
            # Add the file
            path = dir ? dir "/" obj[relpath] : obj[relpath]
            utils::assert(!(path in files),
                          "objects::parse_tree: " path " exists in files!")
            delete files[path]
            files[path]["mode"] = rawmode
            files[path]["size"] = obj[size]
            files[path]["object-id"] = sha1
        }
    }
    return 1
}

# Given the non-header bytes of a tree object, populate 'commit' with:
#
#   commit["tree"] = hash: str
#   commit["parent"] = hash: str or undefined
#   commit["author_name"] = str
#   commit["author_email"] = str
#   commit["author_timestamp"] = str
#   commit["committer_name"] = str
#   commit["committer_email"] = str
#   commit["committer_timestamp"] = str
#   commit["message"] = str
#
# Return 1 if commit parsed successfully, else 0
function parse_commit(commit, bytes,    lines, lineno, line, in_msg, sha1sum,
                                        label, value, person, role, name,
                                        email, timestamp)
{
    delete commit

    split(bytes, lines, "\n")

    PROCINFO["sorted_in"] = "@ind_num_asc"

    for (lineno in lines) {
        line = lines[lineno]

        if (in_msg) {
            commit["message"] = commit["message"] line "\n"
            continue
        }

        if (line == "") {
            # Blank line separates metadata and commit message
            in_msg = 1
            continue
        } else if (match(line, /^(tree|parent) (.{40})$/, sha1sum) > 0) {
            # Like "tree 2c87ef921ddb445b18675bb873495dcd37bf61fa"
            label = 1; value = 2
            commit[sha1sum[label]] = sha1sum[value]
        } else if (match(line, /^(author|committer) (.*) <([^>]+)> (.*)$/, person)) {
            # Like "author Doug A. <dja@example.com> 1629672971 -0600"
            role = 1; name = 2; email = 3; timestamp = 4
            commit[person[role] "_name"] = person[name]
            commit[person[role] "_email"] = person[email]
            commit[person[role] "_timestamp"] = person[timestamp]
        } else {
            utils::assert(0, "unknown line in commit object: '" line "'")
        }

    }
    return 1
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

# zlib decompress 'path' and return bytestring
function zlib_decompress(path,     bytes, zlib, save_rs)
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
# 'hash' can be a full or partial sha1.
function find_file(hash,    len, first2, rest, dir, cmd, path, n)
{
    len = length(hash)
    if (len < 4) {
        return                      # too short
    } else if (len == 40) {
        return sha1_to_path(hash)   # full hash
    }

    first2 = substr(hash, 1, 2)
    rest = substr(hash, 3)
    dir = objects::Dir "/" first2
    cmd = "find " dir " -type f -name '" rest "*'"
    while ((cmd | getline path) > 0) {
        n++
    }

    # If n > 1, then 'hash' was too short and matched multiple files
    if (n == 1) {
        return path
    }
}

# Return full sha1sum of an object if 'hash' matches object in the repo
#
# 'hash' can be a full or partial sha1.
function path_to_sha1(path, sha1)
{
    sha1 = substr(path, length(objects::Dir) + 2) # strip objects dir
    # sha1 will look like 3c/531cd5095969e63a90e614ac3c2b53e4841658; strip /
    sub("/", "", sha1)

    return sha1
}

# Return the absolute path to an object file with the given sha1sum or ""
function sha1_to_path(sha1,    first2, rest, path)
{
    first2 = substr(sha1, 1, 2)
    rest = substr(sha1, 3)
    path = objects::Dir "/" first2 "/" rest

    if (path::is_file(path)) {
        return path
    }
}
