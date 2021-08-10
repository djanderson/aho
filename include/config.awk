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

    if (get_value) {
        if ((value = get(key, file))) {
            print value
            return 0
        } else {
            return 1
        }
    } else {
        return set(section, subsection, name, value, file)
    }
}

# Get a value for a given key
function get(key, file,    parts, nparts, section, subsection, name)
{
    split(key, parts, ".")
    nparts = length(parts)
    if (nparts < 2) {
        print "error: key does not contain a section: " value > "/dev/stderr"
    } else if (nparts == 2) {
        section = parts[1]
        name = parts[2]
    } else {
        section = parts[1]
        subsection = parts[2]
        name = parts[3]
    }

    return get_(section, subsection, name, file)
}

function get_(section, subsection, name, file,    files, in_section, groups,
                                                  value, value_update)
{
    if (file) {
        files[1] = file
    } else {
        files[1] = config::GlobalPath
        files[2] = config::LocalPath
    }

    if (subsection) {
        section = section " \"" subsection "\""
    }

    for (file in files) {
        file = files[file]
        while ((getline line < file) > 0) {
            if (match(line, /^[[:blank:]]*[;#].*$/)) {
                # Comment line, ignore
                continue
            } else if (match(line, /^\[(.*)\]/, groups)) {
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
                # Evaluate each line of section this looking for "name = value"
                if ((value_update = parse_line(line, name))) {
                    value = value_update
                }
            }
        }
        close(file)
        in_section = 0
    }

    return value
}

# Parse line, return "value" associated with key "name"
#
# Known issue - values with escaped quote, "something like \"this\""
function parse_line(line, name,    groups, value)
{
    if (match(line, /^[[:blank:]]*([[:alpha:]]+)[[:blank:]]*=[[:blank:]]*(.*)/, groups)) {
        if (groups[1] == name) {
            value = groups[2]
            if (match(value, /^"([^"]*)"/, groups)) {
                # If value is quoted, use part inside.
                value = groups[1]
            } else if (match(value, /(^[^;#]+)/, groups)) {
                # Strip trailing comments
                value = utils::trim(groups[1])
            }
        }
    }
    return value
}

function set(section, subsection, name, value, file)
{
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

function print_config_tree(tree)
{
    PROCINFO["sorted_in"] = "@val_type_desc" # visit (dir) subarrays first
}
