@namespace "stat"


BEGIN {

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

# Call stat and populate array 'stats' with the following information:
#
# %n path from repo root without leading ./
# %Z time last changed, seconds since epoch
# %Y time last modified, seconds since epoch
# %d device number
# %i inode number
# %f raw mode (will be converted from hex to num)
# %u user ID of owner
# %g group ID of owner
# %s file size in bytes
function stat_file(relpath, stats,    abspath, cmd, line, mode) {
    abspath = path::Root "/" relpath
    cmd = "stat --printf '%n %Z %Y %d %i %f %u %g %s' " abspath
    cmd | getline line
    split(line, stats)
    close(cmd)
    stats[1] = relpath # use relative file path instead of absolute
    # Use canonical git modes
    mode = awk::strtonum("0x" stats[6])
    if (s_isreg(mode)) {
        if (owner_has_execute(mode)) {
            mode = 0100755
        } else {
            mode = 0100644
        }
    } else if (s_isdir(mode)) {
        mode = 040000
    } else if (s_islnk(mode)) {
        mode = 0120000
    }
    stats[6] = mode
}

# Return true if owner has execute permission
function owner_has_execute(m) {
    return !!awk::and(m, S_IXUSR)
}

# Return true if file type is regular file
function s_isreg(m) {
    return awk::and(m, S_IFMT) == S_IFREG
}

# Return true if file type is directory
function s_isdir(m) {
    return awk::and(m, S_IFMT) == S_IFDIR
}

# Return true if file type is symbolic link
function s_islnk(m) {
    return awk::and(m, S_IFMT) == S_IFLNK
}
