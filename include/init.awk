@namespace "init"


function init() {
    if (system("test -d " paths::AhoDir) == 0) {
        print paths::AhoDir " exists!"
    } else {
        print paths::AhoDir " doesn't exist!"        
    }
}
