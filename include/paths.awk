@namespace "paths"


BEGIN {
    Working = ENVIRON["PWD"]
    Aho = "AHO_DIR" in ENVIRON ? ENVIRON["AHO_DIR"] : ".aho"
}
