# Read and write the index file.
#
# Primary reference: 
# https://github.com/git/git/blob/master/Documentation/technical/index-format.txt

@namespace "indexfile"          # index is a reserved identifier


BEGIN {
    Path = "AHO_INDEX" in ENVIRON ? ENVIRON["AHO_INDEX"] : paths::Aho "/index"
    Exists = ! system("test -e " Path)

    # Files is an array-of-arrays, with layout
    #
    #     Files[filepath] =
    #         IndexEntry[ctime] = 12345
    #         IndexEntry[mtime] = 12345
    #         ...
    #     ...
    NFiles = indexfile::read(Files)

    # IndexEntry keys with associated 'stat' format sequences
    Keys[1] = "ctime"           # %Z, seconds since epoch
    Keys[2] = "mtime"           # %Y, seconds since epoch
    Keys[3] = "dev"             # %d device number
    Keys[4] = "ino"             # %i inode number
    Keys[5] = "mode"            # %f raw mode in hex
    Keys[6] = "uid"             # %u user ID of owner
    Keys[7] = "gid"             # %g group ID of owner
    Keys[8] = "size"            # %s file in bytes
    Keys[9] = "filename"        # %n
    Keys[10] = "object-id"      # Only exists for entries read from index
    Keys[11] = "dirty"          # If 1, file needs to be added to object dir
}

function add(files,    file, entry)
{
    for (file in files) {
        delete entry
        create_entry(entry, files[file])
        update_files_array(entry)
    }
}

# Parse an IndexEntry array from stat:
function create_entry(entry, filepath,    stat, line, stats, idx)
{
    stat = "stat --printf '%Z %Y %d %i %f %u %g %s %n' " filepath
    stat | getline line
    split(line, stats)
    close(stat)

    for (idx in Keys) {
        entry[Keys[idx]] = stats[idx]
    }
}

function update_files_array(entry,    filename, in_index, key)
{
    filename = entry["filename"]
    in_index = filename in Files
    # TODO: check if this how Git decides to add a file to index
    if (in_index &&
        (entry["mtime"] == Files[filename]["mtime"] ||
         entry["ctime"] == Files[filename]["ctime"])) {
        print "DEBUG: " filename " up-to-date in index"
        return 0
    }
    delete Files[filename]
    for (key in entry) {
        Files[filename][key] = entry[key]
    }
    Files[filename]["dirty"] = 1
    NFiles += ! in_index
}

function read(Files)
{
    if (!Exists)
        return

    return 0
    # Read indexfile::Path to Files array
}

# Write Files to index
function write(    file, filename, index_bytes, bytes, nbytes, hash)
{
    # filenames will be a unique and sorted array of filenames in Files
    utils::assert(awk::asorti(Files, filenames) == NFiles,
                  "length(filenames) == NFiles")

    # 4-byte signature DIRC (dircache), 4-byte version 2, and number of entries
    index_bytes = "DIRC\x00\x00\x00\x02" utils::num_to_uint32(NFiles)

    # Serialize each IndexEntry in the Files array in sorted order
    for (f in filenames) {
        filename = filenames[f]
        bytes = ""
        bytes = bytes utils::num_to_uint32(Files[filename]["ctime"])
        bytes = bytes utils::num_to_uint32(0) # 0 nanoseconds
        bytes = bytes utils::num_to_uint32(Files[filename]["mtime"])
        bytes = bytes utils::num_to_uint32(0) # 0 nanoseconds
        bytes = bytes utils::num_to_uint32(Files[filename]["dev"])
        bytes = bytes utils::num_to_uint32(Files[filename]["ino"])
        bytes = bytes utils::hex_to_bytes(Files[filename]["mode"], 4)
        bytes = bytes utils::num_to_uint32(Files[filename]["uid"])
        bytes = bytes utils::num_to_uint32(Files[filename]["gid"])
        bytes = bytes utils::num_to_uint32(Files[filename]["size"])
        bytes = bytes utils::hex_to_bytes(Files[filename]["object-id"], 20)
        bytes = bytes build_flags(filename)
        bytes = bytes filename "\x00"
        nbytes = 62 + length(filename) + 1
        # Bitwise hack for rounding up to powers of 2
        # https://stackoverflow.com/a/9194117
        for (i = nbytes; i < (awk::and(nbytes + 7, awk::compl(7))); i++) {
            # Pad null bytes to a multiple of 8
            bytes = bytes "\x00"
        }
        index_bytes = index_bytes bytes
    }

    hash = utils::sha1sum_str(index_bytes)

    index_bytes = index_bytes utils::hex_to_bytes(hash, 20)

    printf("%s", index_bytes) > indexfile::Path
}

function build_flags(filename,    len, b1, b2)
{
    len = length(filename)
    len = len > 0xfff ? 0xfff : len

    b2 = utils::IntToByteMap[len % 256]
    len = int(len / 256)
    b1 = utils::IntToByteMap[len % 256]
    len = int(len / 256)

    return b1 b2
}

function debug_print_entry(entry,    key) {
    for (key in Keys) {
        print "  IndexEntry['" Keys[key] "'] = " entry[Keys[key]]
    }
}
