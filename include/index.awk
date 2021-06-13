@namespace "indexfile"          # index is a reserved identifier


BEGIN {
    Path = "AHO_INDEX" in ENVIRON ? ENVIRON["AHO_INDEX"] : paths::Aho "/index"
}
