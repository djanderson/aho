@namespace "reflog"


BEGIN {
    Dir = path::AhoDir "/logs"
}

# Append a line to a reflog
#
# ref: str - HEAD or branch name in refs/heads/
# oldsha: str - what hash the ref pointed to before
# newsha: str - what hash the ref points to now
# name: str - user.name that performed this action
# email: str - user.email that performed this action
# timestamp: str - time including tz offset of the action
# action: str - one of "commit, reset, clone" etc
# summary: str
#     - for commit: first line of commit message
#     - for reset: "moving to " new ref/HEAD
#     - for clone: "from " location
function append(ref, oldsha, newsha, name, email, timestamp, action, summary,
                    dir, path)
{
    utils::assert(ref == "HEAD" ||
                  path::is_file(path::AhoDir "/refs/heads/" ref),
                  "reflog::update: unknown ref " ref)

    dir = ref == "HEAD" ? Dir : Dir "/refs/heads"
    assure_dir = "mkdir -p " dir
    system(assure_dir)
    close(assure_dir)
    path = dir "/" ref

    if (!oldsha) {
        oldsha = "0000000000000000000000000000000000000000"
        if (action == "commit") {
            action = "commit (initial)"
        }
    }

    printf("%s %s %s <%s> %s\t%s: %s\n", oldsha, newsha, name, email,
                                         timestamp, action, summary) >> path
}
