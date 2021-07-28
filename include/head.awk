@namespace "head"


BEGIN {
    Path = path::AhoDir "/HEAD"
    Raw = read()
    Branch = get_ref()
    Commit = get_commit()

    # FIXME: better test runner
    if (ENVIRON["TEST"]) {
        test_setup()
        test_ref()
        test_commit()
        test_teardown()
        print "head:	all tests passed"
    }
}

function init(directory,    path)
{
    if (!directory) {
        print "Must pass directory to init" > "/dev/stderr"
        return 1
    }

    Path = directory "/HEAD"
    set_ref("master")
}

# Read the raw value from HEAD and reset dependent globals
function read(    raw)
{
    getline raw < Path
    close(Path)
    Branch = ""
    Commit = ""
    Raw = raw
    return raw
}

# Read the HEAD and return branch name
function get_ref()
{
    if (Branch) {
        return Branch
    }

    if (match(Raw, /^ref: refs\/heads\/.*$/)) {
        return substr(Raw, 17)  # length("ref: refs/heads/") + 1
    }
}

function get_commit(    refpath, commit)
{
    if (Commit) {
        return Commit
    }

    if (Branch) {
        # HEAD is a ref... follow it
        refpath = path::Dir "/" substr(Raw, 6) # step past 'ref: '
        getline commit < refpath
        close(refpath)
        return commit
    }

    # Detached HEAD
    return Raw
}

function set_ref(ref)
{
    print "ref: refs/heads/" ref > Path
    close(Path)
}

function set_commit(commit)
{
    print commit > Path
    close(Path)
}


#######
# TESTS
#######

function test_setup()
{
    mktemp = "mktemp"
    mktemp | getline Path
    close(mktemp)
}

function test_ref(    branch)
{
    set_ref("develop")
    Raw = read()
    utils::assert(get_ref() == "develop", "set/get_ref failed")
}

function test_commit(    commit)
{
    commit = "c8bfec8f8a2e5e8821dd50fe751fe6f5212201ef"
    set_commit(commit)
    Raw = read()
    utils::assert(get_commit() == commit, "set/get_commit failed")
}

function test_teardown()
{
    system("rm " Path)
}
