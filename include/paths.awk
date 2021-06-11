@namespace "paths"

BEGIN {
    CurDir = ENVIRON["PWD"]
    AhoDir = "AHO_DIR" in ENVIRON ? ENVIRON["AHO_DIR"] : ".aho"
    AhoIndex = "AHO_INDEX" in ENVIRON ? ENVIRON["AHO_INDEX"] : AhoDir "/index"
}
