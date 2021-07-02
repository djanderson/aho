# Read and write the index file.
#
# Primary reference: 
# https://github.com/git/git/blob/master/Documentation/technical/index-format.txt

@namespace "indexfile"          # index is a reserved identifier


BEGIN {
    Path = "AHO_INDEX" in ENVIRON ? ENVIRON["AHO_INDEX"] : paths::Aho "/index"
    Exists = ! system("test -e " Path)

    Header = "DIRC"
    Version = "\0\0\0\2"

    # IndexEntry is an associative array that represents an entry in the index.
    # It has the following keys (with associated 'stat' format sequences)
    Keys[1] = "filename"        # %n filename from repo root without leading ./
    Keys[2] = "ctime"           # %Z time last changed, seconds since epoch
    Keys[3] = "mtime"           # %Y time last modified, seconds since epoch
    Keys[4] = "dev"             # %d device number
    Keys[5] = "ino"             # %i inode number
    Keys[6] = "mode"            # %f raw mode in hex
    Keys[7] = "uid"             # %u user ID of owner
    Keys[8] = "gid"             # %g group ID of owner
    Keys[9] = "size"            # %s file size in bytes
    Keys[10] = "object-id"      # sha1sum of object file - set by objects::add
    Keys[11] = "dirty"          # If 1, file needs to be added to object dir

    # Files is an associative array-of-arrays, with layout
    #
    #     Files[filepath] =
    #         IndexEntry[ctime] = 12345
    #         IndexEntry[mtime] = 12345
    #         ...
    #     ...
    delete Files
    NFiles = indexfile::read(Files)
}

function add(files,    file, entry)
{
    for (file in files) {
        delete entry
        create_entry(entry, files[file])
        update_files_array(entry)
    }
}

# Parse an IndexEntry array from stat
function create_entry(entry, filepath,    stat, line, stats, idx)
{
    stat = "stat --printf '%n %Z %Y %d %i %f %u %g %s' " filepath
    stat | getline line
    split(line, stats)
    close(stat)

    for (idx in Keys) {
        entry[Keys[idx]] = stats[idx]
    }
}

# Add an IndexEntry to Files. If it differs from what's in index, mark dirty=1.
function update_files_array(entry,    filename, in_index, key)
{
    filename = entry["filename"]
    in_index = filename in Files
    # TODO: check if this how Git decides to add a file to index
    if (in_index &&
        (entry["mtime"] == Files[filename]["mtime"] &&
         entry["ctime"] == Files[filename]["ctime"])) {
        #print "DEBUG: " filename " up-to-date in index"
        return 0
    }
    delete Files[filename]
    for (key in entry) {
        Files[filename][key] = entry[key]
    }
    Files[filename]["dirty"] = 1
    NFiles += ! in_index
}

function read(Files,    bytes, nbytes)
{
    if (!Exists)
        return

    # Read the whole index file into memory
    bytes = verify(utils::readfile(indexfile::Path))

    num_entries = utils::uint32_to_num(substr(bytes, 9, 4))
    print "About to read num entries: " num_entries

    # TODO: read entries and add to Files
    read_entries = 0
    offset = 13                 # byte after header

    while (read_entries < num_entries) {
        # Seek ahead to read filename to use as Files array key
        filename_len = read_flags(substr(bytes, offset + 60, 2))
        filename = substr(bytes, offset + 62, filename_len)

        # Read index entry into Files array
        delete Files[filename]
        Files[filename]["filename"] = filename
        Files[filename]["ctime"] = utils::uint32_to_num(substr(bytes, offset, 4))
        Files[filename]["mtime"] = utils::uint32_to_num(substr(bytes, offset + 8, 4))
        Files[filename]["dev"] = utils::uint32_to_num(substr(bytes, offset + 16, 4))
        Files[filename]["ino"] = utils::uint32_to_num(substr(bytes, offset + 20, 4))
        Files[filename]["mode"] = utils::bytes_to_hex(substr(bytes, offset + 26, 2), 2)
        Files[filename]["uid"] = utils::uint32_to_num(substr(bytes, offset + 28, 4))
        Files[filename]["gid"] = utils::uint32_to_num(substr(bytes, offset + 32, 4))
        Files[filename]["size"] = utils::uint32_to_num(substr(bytes, offset + 36, 4))
        Files[filename]["object-id"] = utils::bytes_to_hex(substr(bytes, offset + 40, 20))

        offset += utils::nearest_pow2(62 + filename_len + 1)
        read_entries++
        NFiles++
    }

    return num_entries
}

# Write Files to index
function write(    file, filename, index_bytes, bytes, nbytes, hash)
{
    # filenames will be a unique and sorted array of filenames in Files
    utils::assert(awk::asorti(Files, filenames) == NFiles,
                  "length(filenames) == NFiles")

    # 4-byte signature DIRC (dircache), 4-byte version 2, and number of entries
    index_bytes = Header Version utils::num_to_uint32(NFiles)

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
        bytes = bytes filename "\0"
        nbytes = length(bytes)
        # Append null bytes to round index entry size up to nearest power of 2
        bytes = bytes utils::null_bytes(utils::nearest_pow2(nbytes) - nbytes)
        index_bytes = index_bytes bytes
    }

    hash = utils::sha1sum_str(index_bytes)

    index_bytes = index_bytes utils::hex_to_bytes(hash, 20)

    printf("%s", index_bytes) > indexfile::Path
}

# Verify index header, version, and checksum. Return bytes without checksum.
function verify(bytes,    nbytes, expected_checksum, checksum, header, version,
                          failed)
{
    nbytes = length(bytes)
    if (nbytes < 22) {
        print "fatal: " indexfile::Path ": index file smaller than expected" \
            > "/dev/stderr"
        exit 128
    }
    expected_checksum = utils::bytes_to_hex(substr(bytes, nbytes - 19), 40)
    bytes = substr(bytes, 1, nbytes - 20) # strip checksum
    checksum = utils::sha1sum_str(bytes)
    if (checksum != expected_checksum) {
        print "fatal: index file corrupt" > "/dev/stderr"
        exit 128
    }
    header = substr(bytes, 1, 4)
    if (header != indexfile::Header) {
        hdrhex = "0x" utils::bytes_to_hex(header, 4)
        print "error: bad signature " hdrhex > "/dev/stderr"
        failed = 1
    }
    version = substr(bytes, 5, 4)
    if (version != indexfile::Version) {
        vernum = utils::uint32_to_num(version)
        print "error: bad version " vernum " (aho only supports version 2)" \
            > "/dev/stderr"
        failed = 1
    }
    if (failed) {
        print "fatal: index file corrupt" > "/dev/stderr"
        exit 128
    }
    # Strip checksum
    return substr(bytes, 1, nbytes - 19)
}

function build_flags(filename,    len, b1, b2)
{
    len = length(filename)
    len = len > 0xfff ? 0xfff : len

    b2 = utils::i2b(len % 256)
    len = int(len / 256)
    b1 = utils::i2b(len % 256)

    return b1 b2
}

# Given the 16-bit flags field, return filename size up to 0xfff
# TODO: take optional array as second arg and pass all 3 flag vals?
function read_flags(flags)
{
    # FIXME: only works for slot 0 and "assume-valid" bit unset
    return utils::uint32_to_num("\0\0" flags)
}

function debug_print_entry(entry,    key) {
    for (key in Keys) {
        print "  IndexEntry['" Keys[key] "'] = " entry[Keys[key]]
    }
}
