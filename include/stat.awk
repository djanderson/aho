@namespace "stat"


BEGIN {
    # A Stats array has the following keys
    Stats[1] = "filename"    # str: path from repo root without leading ./
    Stats[2] = "ctime"       # num: time last changed, seconds since epoch
    Stats[3] = "mtime"       # num: time last modified, seconds since epoch
    Stats[4] = "dev"         # num: device number
    Stats[5] = "ino"         # num: inode number
    Stats[6] = "mode"        # num: raw mode
    Stats[7] = "uid"         # num: user ID of owner
    Stats[8] = "gid"         # num: group ID of owner
    Stats[9] = "size"        # num: file size in bytes

    # Canonical Git modes
    ModeFile  = 0100644  # Regular file
    ModeXFile = 0100755  # Executable file
    ModeDir   = 040000   # Directory
    ModeLnk   = 0120000  # Symbolic link

    # stat st_mode bitfield constants - from `man 7 inode`

    S_IFMT   = 0170000   # bit mask for the file type bit field

    S_IFSOCK = 0140000   # socket
    S_IFLNK  = 0120000   # symbolic link
    S_IFREG  = 0100000   # regular file
    S_IFBLK  = 0060000   # block device
    S_IFDIR  = 0040000   # directory
    S_IFCHR  = 0020000   # character device
    S_IFIFO  = 0010000   # FIFO

    S_ISUID  = 04000     # set-user-ID bit (see execve(2))
    S_ISGID  = 02000     # set-group-ID bit (see below)
    S_ISVTX  = 01000     # sticky bit (see below)

    S_IRWXU  = 00700     # owner has read, write, and execute permission
    S_IRUSR  = 00400     # owner has read permission
    S_IWUSR  = 00200     # owner has write permission
    S_IXUSR  = 00100     # owner has execute permission

    S_IRWXG  = 00070     # group has read, write, and execute permission
    S_IRGRP  = 00040     # group has read permission
    S_IWGRP  = 00020     # group has write permission
    S_IXGRP  = 00010     # group has execute permission

    S_IRWXO  = 00007     # others (not in group) have read, write, execute
    S_IROTH  = 00004     # others have read permission
    S_IWOTH  = 00002     # others have write permission
    S_IXOTH  = 00001     # others have execute permission
}

# Given an array of relative file paths, stats will contain a Stats array under
# each relpath.
#
# e.g., if "README.md" is in relpaths, its size is stats["README.md"]["size"].
function stat_files(stats, relpaths,    abspaths, relpath, mode, i, a, key)
{
    # Build a space-delimited list of abspaths
    for (p in relpaths) {
        abspaths = abspaths " " path::Root "/" relpaths[p]
    }
    cmd = "stat --printf '%n %Z %Y %d %i %f %u %g %s\n' " abspaths
    i = 1
    while ((cmd | getline line) > 0) {
        relpath = relpaths[i++]
        split(line, a)
        for (key in Stats) {
            stats[relpath][Stats[key]] = a[key]
        }
        stats[relpath]["filename"] = relpath # reset absolute -> relative path
        mode = awk::strtonum("0x" stats[relpath]["mode"])
        if (s_isreg(mode)) {
            if (owner_has_execute(mode)) {
                mode = ModeXFile
            } else {
                mode = ModeFile
            }
        } else if (s_isdir(mode)) {
            mode = ModeDir
        } else if (s_islnk(mode)) {
            mode = ModeLnk
        }
        stats[relpath]["mode"] = mode
    }
    close(cmd)
}

# Return true if Stats["mode"] indicates owner has execute permission
function owner_has_execute(m) {
    return !!awk::and(m, S_IXUSR)
}

# Return true if Stats["mode"] indicates file type is regular file
function s_isreg(m) {
    return awk::and(m, S_IFMT) == S_IFREG
}

# Return true if Stats["mode"] indicates file type is directory
function s_isdir(m) {
    return awk::and(m, S_IFMT) == S_IFDIR
}

# Return true if Stats["mode"] indicates file type is symbolic link
function s_islnk(m) {
    return awk::and(m, S_IFMT) == S_IFLNK
}

function debug_print(stats,    key) {
    for (key in Stats) {
        print "  Stats['" Stats[key] "'] = " stats[Stats[key]]
    }
}
