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

    # An IndexEntry has the following keys (1 - 9 are same as stat::Stats)
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

    # Entries is an associative array-of-arrays, with layout
    #
    #     Entries[filepath] =
    #         IndexEntry[ctime] = 12345
    #         IndexEntry[mtime] = 12345
    #         ...
    #     ...
    delete Entries
    indexfile::read(Entries)
}

# Add files to the index.
#
# - relpaths: array of path strings relative to repo root
function add_files(relpaths,    files, p)
{
    stat::stat_files(files, relpaths)
    for (p in relpaths) {
        relpath = relpaths[p]
        files[relpath]["up-to-date"] = entry_up_to_date(files[relpath])
        if (!files[relpath]["up-to-date"]) {
            add_entry(files[relpath])
        }
    }
}

# Remove files from the index.
#
# - file: array of path strings
function remove_files(files,    filename, f)
{
    for (f in files) {
        filename = files[f]
        Entries[filename]["removed"] = 1
    }
}

# Add an IndexEntry to Entries.
function add_entry(entry,    filename, key)
{
    filename = entry["filename"]

    delete Entries[filename]
    for (key in entry) {
        Entries[filename][key] = entry[key]
    }
}

function copy_entry(from, to,    key)
{
    for (key in from) {
        to[key] = from[key]
    }
}

# Given a stats::Stats array or IndexEntry, return 1 if up-to-date in index
# https://github.com/git/git/blob/master/Documentation/technical/racy-git.txt#L36
function entry_up_to_date(entry,    filename)
{
    filename = entry["filename"]
    return (indexfile::has_file(filename) &&
            (entry["ctime"] == Entries[filename]["ctime"] &&
             entry["mtime"] == Entries[filename]["mtime"] &&
             entry["dev"]   == Entries[filename]["dev"]   &&
             entry["ino"]   == Entries[filename]["ino"]   &&
             entry["mode"]  == Entries[filename]["mode"]  &&
             entry["uid"]   == Entries[filename]["uid"]   &&
             entry["gid"]   == Entries[filename]["gid"]   &&
             entry["size"]  == Entries[filename]["size"]))
}

function file_up_to_date(file)
{
    return has_file(file) && Entries[file]["up-to-date"]
}

# Return 1 if index contains an entry with the given filename
function has_file(filename)
{
    return filename in Entries
}

# Read the index file into Entries
function read(Entries,    bytes, nbytes, num_entries, read_entries, filename,
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
        # Seek ahead to read filename to use as Entries array key
        filename_len = read_flags(substr(bytes, offset + 60, 2))
        filename = substr(bytes, offset + 62, filename_len)

        # Read index entry into Entries array
        delete Entries[filename]
        Entries[filename]["filename"] = filename
        Entries[filename]["ctime"] = utils::uint32_to_num(substr(bytes, offset, 4))
        Entries[filename]["mtime"] = utils::uint32_to_num(substr(bytes, offset + 8, 4))
        Entries[filename]["dev"] = utils::uint32_to_num(substr(bytes, offset + 16, 4))
        Entries[filename]["ino"] = utils::uint32_to_num(substr(bytes, offset + 20, 4))
        Entries[filename]["mode"] = utils::uint32_to_num(substr(bytes, offset + 24, 4))
        Entries[filename]["uid"] = utils::uint32_to_num(substr(bytes, offset + 28, 4))
        Entries[filename]["gid"] = utils::uint32_to_num(substr(bytes, offset + 32, 4))
        Entries[filename]["size"] = utils::uint32_to_num(substr(bytes, offset + 36, 4))
        Entries[filename]["object-id"] = utils::bytes_to_hex(substr(bytes, offset + 40, 20))
        Entries[filename]["up-to-date"] = 1
        Entries[filename]["removed"] = 0

        # Each entry is 62 fixed bytes, a NULL-terminated filename, and then as
        # many NULL bytes as required to make the total length a power of 2
        offset += utils::nearest_pow2(62 + filename_len + 1)
        read_entries++
    }

    return num_entries
}

# Write Entries to index
function write(    entries, file, filename, index_bytes, bytes, nbytes, hash)
{
    delete entries                # local copy of Entries without removed entries
    for (file in Entries) {
        if (!Entries[file]["removed"]) {
            entries[file][EMPTYTREE] # ensure entries[file] is passed as array
            copy_entry(Entries[file], entries[file])
        }
    }

    # 4-byte signature DIRC (dircache), 4-byte version 2, and number of entries
    index_bytes = Header Version utils::num_to_uint32(length(entries))

    # Serialize each IndexEntry in the Entries array in sorted order
    PROCINFO["sorted_in"] = "@ind_str_asc"
    for (filename in entries) {
        bytes = ""
        bytes = bytes utils::num_to_uint32(entries[filename]["ctime"])
        bytes = bytes utils::num_to_uint32(0) # 0 nanoseconds
        bytes = bytes utils::num_to_uint32(entries[filename]["mtime"])
        bytes = bytes utils::num_to_uint32(0) # 0 nanoseconds
        bytes = bytes utils::num_to_uint32(entries[filename]["dev"])
        bytes = bytes utils::num_to_uint32(entries[filename]["ino"])
        bytes = bytes utils::num_to_uint32(entries[filename]["mode"])
        bytes = bytes utils::num_to_uint32(entries[filename]["uid"])
        bytes = bytes utils::num_to_uint32(entries[filename]["gid"])
        bytes = bytes utils::num_to_uint32(entries[filename]["size"])
        bytes = bytes utils::hex_to_bytes(entries[filename]["object-id"], 20)
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
