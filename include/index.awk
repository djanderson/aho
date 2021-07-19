# Read and write the index file.
#
# Primary reference:
# https://github.com/git/git/blob/master/Documentation/technical/index-format.txt

@namespace "indexfile"          # index is a reserved identifier


BEGIN {
    if ("AHO_INDEX_FILE" in ENVIRON) {
        Path = ENVIRON["AHO_INDEX_FILE"]
    } else {
        Path = path::AbsAhoDir "/index"
    }
    Exists = path::is_file(Path)

    Header = "DIRC"
    Version = "\0\0\0\2"

    # An IndexEntry has the following keys
    IndexEntry[1] = "filename"    # str: path from repo root without leading ./
    IndexEntry[2] = "ctime"       # num: time last changed, seconds since epoch
    IndexEntry[3] = "mtime"       # num: time last modified, seconds since epoch
    IndexEntry[4] = "dev"         # num: device number
    IndexEntry[5] = "ino"         # num: inode number
    IndexEntry[6] = "mode"        # num: raw mode
    IndexEntry[7] = "uid"         # num: user ID of owner
    IndexEntry[8] = "gid"         # num: group ID of owner
    IndexEntry[9] = "size"        # num: file size in bytes
    IndexEntry[10] = "object-id"  # str: sha1sum of object
    IndexEntry[11] = "up-to-date" # num: if 1, entry is up-to-date in index
    IndexEntry[12] = "removed"    # num: if 1, entry will not be written out

    # Files is an associative array-of-arrays, with layout
    #
    #     Files[filepath] =
    #         IndexEntry[ctime] = 12345
    #         IndexEntry[mtime] = 12345
    #         ...
    #     ...
    delete Files
    indexfile::read(Files)
}

# Add files to the index.
#
# - files: array of path strings
function add(files,    file, entry)
{
    for (file in files) {
        delete entry
        create_entry(entry, files[file])
        if (!entry["up-to-date"]) {
            add_entry(entry)
        }
    }
}

# Remove files from the index.
#
# - file: array of path strings
function remove_files(files,    file)
{
    for (file in files) {
        file = files[file]
        Files[file]["removed"] = 1
    }
}

# Parse an IndexEntry array from stat.
#
# - entry: empty array where index entry will be written
# - filepath: string path relative to repo root
function create_entry(entry, filepath,    stats, key)
{
    stat::stat_file(filepath, stats)

    for (key in IndexEntry) {
        entry[IndexEntry[key]] = stats[key]
    }

    entry["up-to-date"] = entry_up_to_date(entry)
}

# Add an IndexEntry to Files.
function add_entry(entry,    filename, key)
{
    filename = entry["filename"]

    delete Files[filename]
    for (key in entry) {
        Files[filename][key] = entry[key]
    }
}

function copy_entry(from, to,    key)
{
    for (key in IndexEntry) {
        key = IndexEntry[key]
        to[key] = from[key]
    }
}

# Given an IndexEntry, return 1 if up-to-date in index
function entry_up_to_date(entry,    filename)
{
    filename = entry["filename"]
    # TODO: check if this how Git decides file is up-to-date
    return (indexfile::has_file(filename) &&
            (entry["mtime"] == Files[filename]["mtime"] &&
             entry["ctime"] == Files[filename]["ctime"]))
}

function file_up_to_date(file)
{
    return has_file(file) && Files[file]["up-to-date"]
}

# Return 1 if index contains an entry with the given filename
function has_file(filename)
{
    return filename in Files
}

function read(Files,    bytes, nbytes, num_entries, read_entries, filename,
                        filename_len, offset)
{
    if (!Exists)
        return

    # Read the whole index file into memory
    bytes = verify(utils::readfile(indexfile::Path))

    num_entries = utils::uint32_to_num(substr(bytes, 9, 4))
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
        Files[filename]["mode"] = utils::uint32_to_num(substr(bytes, offset + 24, 4))
        Files[filename]["uid"] = utils::uint32_to_num(substr(bytes, offset + 28, 4))
        Files[filename]["gid"] = utils::uint32_to_num(substr(bytes, offset + 32, 4))
        Files[filename]["size"] = utils::uint32_to_num(substr(bytes, offset + 36, 4))
        Files[filename]["object-id"] = utils::bytes_to_hex(substr(bytes, offset + 40, 20))
        Files[filename]["up-to-date"] = 1
        Files[filename]["removed"] = 0

        offset += utils::nearest_pow2(62 + filename_len + 1)
        read_entries++
    }

    return num_entries
}

# Write Files to index
function write(    files, file, filename, index_bytes, bytes, nbytes, hash)
{
    delete files                # local copy of Files without removed entries
    for (file in Files) {
        if (!Files[file]["removed"]) {
            files[file][1]      # force subarray with tmp entry
            copy_entry(Files[file], files[file])
        }
    }

    # 4-byte signature DIRC (dircache), 4-byte version 2, and number of entries
    index_bytes = Header Version utils::num_to_uint32(length(files))

    # Serialize each IndexEntry in the Files array in sorted order
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (filename in files) {
        bytes = ""
        bytes = bytes utils::num_to_uint32(files[filename]["ctime"])
        bytes = bytes utils::num_to_uint32(0) # 0 nanoseconds
        bytes = bytes utils::num_to_uint32(files[filename]["mtime"])
        bytes = bytes utils::num_to_uint32(0) # 0 nanoseconds
        bytes = bytes utils::num_to_uint32(files[filename]["dev"])
        bytes = bytes utils::num_to_uint32(files[filename]["ino"])
        bytes = bytes utils::num_to_uint32(files[filename]["mode"])
        bytes = bytes utils::num_to_uint32(files[filename]["uid"])
        bytes = bytes utils::num_to_uint32(files[filename]["gid"])
        bytes = bytes utils::num_to_uint32(files[filename]["size"])
        bytes = bytes utils::hex_to_bytes(files[filename]["object-id"], 20)
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
                          failed, hdrhex, key, vernum)
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
    return bytes
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
    for (key in IndexEntry) {
        print "  IndexEntry['" IndexEntry[key] "'] = " entry[IndexEntry[key]]
    }
}
