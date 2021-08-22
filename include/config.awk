# Read and write config file values.
#
# For simplicity, aho inherits from Git's global ~/.gitconfig, but can write
# values to .aho/config.

@namespace "config"


BEGIN {
    LocalPath = path::AhoDir "/config"
    GlobalPath = path::Home "/.gitconfig"
}

function run_command(    shortopts, longopts, c, file, get_value, key, value)
{
    shortopts = "hf:"
    longopts = "help,file:,get"

    while ((c = getopt::getopt(ARGC, ARGV, shortopts, longopts)) != -1) {
        if (c == "?") {
            print_usage()
            return 129
        }
        if (getopt::Optopt == "h" || getopt::Optopt == "help") {
            print_help()
            return 0
        } else if (getopt::Optopt == "f" || getopt::Optopt == "file") {
            file = getopt::Optarg
        } else if (getopt::Optopt == "get") {
            get_value = 1
        }
    }

    while ((value = ARGV[getopt::Optind++])) {
        if (!key) {
            key = value
            value = ""
        } else {
            # break here to keep value, otherwise we lose it on last iteration
            break
        }
    }

    if (!value) {
        # Implicit --get
        get_value = 1
    }

    if (!get_value) {
        printf "fatal: config set/add not implemented" > "/dev/stderr"
        print " - modify " LocalPath " manually" > "/dev/stderr"
        return 1
    }

    value = get(key, file)
    if (value) {
        print value
        return 0
    } else {
        return 1
    }
}

function get(key, file,    parts, nparts, section, subsection, name, value)
{
    # Parse key into a [section <"subsection">] header and name
    split(key, parts, ".")
    nparts = length(parts)
    if (nparts < 2) {
        print "error: key does not contain a section: " key > "/dev/stderr"
    } else if (nparts == 2) {
        section = parts[1]
        header = section
        name = parts[2]
    } else {
        section = parts[1]
        subsection = parts[2]
        header = section " \"" subsection "\""
        name = parts[3]
    }

    # Decide which files to read
    if (file) {
        files[1] = file
    } else {
        # Scan local first so that values found there "override" global values
        files[1] = config::LocalPath
        files[2] = config::GlobalPath
    }

    for (file in files) {
        file = files[file]
        FS = "[[:blank:]]*=[[:blank:]]*"
        while ((getline < file) > 0) {
            if (match($0, /^[[:blank:]]*[;#].*$/)) {
                # Comment line, ignore
                continue
            } else if (match($0, /^\[(.*)\]/, groups)) {
                # Found section header [.*]
                if (in_section) {
                    # Got to start of next section
                    break
                }
                if (groups[1] == section) {
                    # Found start of target section
                    in_section = 1
                }
            } else {
                # Parse lines
                if (in_section && utils::trim($1) == name) {
                    if (match($2, /^"([^"]*)"/, groups)) {
                        # If value is quoted, use part inside.
                        value = groups[1]
                    } else if (match($2, /(^[^;#]+)/, groups)) {
                        # Strip trailing comments
                        value = utils::trim(groups[1])
                    } else {
                        value = utils::trim($2)
                    }

                    return value
                }
            }
        }
        close(file)
        in_section = 0
    }

}

function init(directory,    path)
{
    if (!directory) {
        print "Must pass directory to init" > "/dev/stderr"
        return 1
    }

    path = directory "/config"

    print "[core]" > path
    print "	repositoryformatversion = 0" >> path
    print "	filemode = true" >> path
    print "	bare = false" >> path
    print "	logallrefupdates = true" >> path
}
