@namespace "utils"


BEGIN {
    IntToByteMap[0] = "\x00"
    IntToByteMap[1] = "\x01"
    IntToByteMap[2] = "\x02"
    IntToByteMap[3] = "\x03"
    IntToByteMap[4] = "\x04"
    IntToByteMap[5] = "\x05"
    IntToByteMap[6] = "\x06"
    IntToByteMap[7] = "\x07"
    IntToByteMap[8] = "\x08"
    IntToByteMap[9] = "\x09"
    IntToByteMap[10] = "\x0a"
    IntToByteMap[11] = "\x0b"
    IntToByteMap[12] = "\x0c"
    IntToByteMap[13] = "\x0d"
    IntToByteMap[14] = "\x0e"
    IntToByteMap[15] = "\x0f"
    IntToByteMap[16] = "\x10"
    IntToByteMap[17] = "\x11"
    IntToByteMap[18] = "\x12"
    IntToByteMap[19] = "\x13"
    IntToByteMap[20] = "\x14"
    IntToByteMap[21] = "\x15"
    IntToByteMap[22] = "\x16"
    IntToByteMap[23] = "\x17"
    IntToByteMap[24] = "\x18"
    IntToByteMap[25] = "\x19"
    IntToByteMap[26] = "\x1a"
    IntToByteMap[27] = "\x1b"
    IntToByteMap[28] = "\x1c"
    IntToByteMap[29] = "\x1d"
    IntToByteMap[30] = "\x1e"
    IntToByteMap[31] = "\x1f"
    IntToByteMap[32] = "\x20"
    IntToByteMap[33] = "\x21"
    IntToByteMap[34] = "\x22"
    IntToByteMap[35] = "\x23"
    IntToByteMap[36] = "\x24"
    IntToByteMap[37] = "\x25"
    IntToByteMap[38] = "\x26"
    IntToByteMap[39] = "\x27"
    IntToByteMap[40] = "\x28"
    IntToByteMap[41] = "\x29"
    IntToByteMap[42] = "\x2a"
    IntToByteMap[43] = "\x2b"
    IntToByteMap[44] = "\x2c"
    IntToByteMap[45] = "\x2d"
    IntToByteMap[46] = "\x2e"
    IntToByteMap[47] = "\x2f"
    IntToByteMap[48] = "\x30"
    IntToByteMap[49] = "\x31"
    IntToByteMap[50] = "\x32"
    IntToByteMap[51] = "\x33"
    IntToByteMap[52] = "\x34"
    IntToByteMap[53] = "\x35"
    IntToByteMap[54] = "\x36"
    IntToByteMap[55] = "\x37"
    IntToByteMap[56] = "\x38"
    IntToByteMap[57] = "\x39"
    IntToByteMap[58] = "\x3a"
    IntToByteMap[59] = "\x3b"
    IntToByteMap[60] = "\x3c"
    IntToByteMap[61] = "\x3d"
    IntToByteMap[62] = "\x3e"
    IntToByteMap[63] = "\x3f"
    IntToByteMap[64] = "\x40"
    IntToByteMap[65] = "\x41"
    IntToByteMap[66] = "\x42"
    IntToByteMap[67] = "\x43"
    IntToByteMap[68] = "\x44"
    IntToByteMap[69] = "\x45"
    IntToByteMap[70] = "\x46"
    IntToByteMap[71] = "\x47"
    IntToByteMap[72] = "\x48"
    IntToByteMap[73] = "\x49"
    IntToByteMap[74] = "\x4a"
    IntToByteMap[75] = "\x4b"
    IntToByteMap[76] = "\x4c"
    IntToByteMap[77] = "\x4d"
    IntToByteMap[78] = "\x4e"
    IntToByteMap[79] = "\x4f"
    IntToByteMap[80] = "\x50"
    IntToByteMap[81] = "\x51"
    IntToByteMap[82] = "\x52"
    IntToByteMap[83] = "\x53"
    IntToByteMap[84] = "\x54"
    IntToByteMap[85] = "\x55"
    IntToByteMap[86] = "\x56"
    IntToByteMap[87] = "\x57"
    IntToByteMap[88] = "\x58"
    IntToByteMap[89] = "\x59"
    IntToByteMap[90] = "\x5a"
    IntToByteMap[91] = "\x5b"
    IntToByteMap[92] = "\x5c"
    IntToByteMap[93] = "\x5d"
    IntToByteMap[94] = "\x5e"
    IntToByteMap[95] = "\x5f"
    IntToByteMap[96] = "\x60"
    IntToByteMap[97] = "\x61"
    IntToByteMap[98] = "\x62"
    IntToByteMap[99] = "\x63"
    IntToByteMap[100] = "\x64"
    IntToByteMap[101] = "\x65"
    IntToByteMap[102] = "\x66"
    IntToByteMap[103] = "\x67"
    IntToByteMap[104] = "\x68"
    IntToByteMap[105] = "\x69"
    IntToByteMap[106] = "\x6a"
    IntToByteMap[107] = "\x6b"
    IntToByteMap[108] = "\x6c"
    IntToByteMap[109] = "\x6d"
    IntToByteMap[110] = "\x6e"
    IntToByteMap[111] = "\x6f"
    IntToByteMap[112] = "\x70"
    IntToByteMap[113] = "\x71"
    IntToByteMap[114] = "\x72"
    IntToByteMap[115] = "\x73"
    IntToByteMap[116] = "\x74"
    IntToByteMap[117] = "\x75"
    IntToByteMap[118] = "\x76"
    IntToByteMap[119] = "\x77"
    IntToByteMap[120] = "\x78"
    IntToByteMap[121] = "\x79"
    IntToByteMap[122] = "\x7a"
    IntToByteMap[123] = "\x7b"
    IntToByteMap[124] = "\x7c"
    IntToByteMap[125] = "\x7d"
    IntToByteMap[126] = "\x7e"
    IntToByteMap[127] = "\x7f"
    IntToByteMap[128] = "\x80"
    IntToByteMap[129] = "\x81"
    IntToByteMap[130] = "\x82"
    IntToByteMap[131] = "\x83"
    IntToByteMap[132] = "\x84"
    IntToByteMap[133] = "\x85"
    IntToByteMap[134] = "\x86"
    IntToByteMap[135] = "\x87"
    IntToByteMap[136] = "\x88"
    IntToByteMap[137] = "\x89"
    IntToByteMap[138] = "\x8a"
    IntToByteMap[139] = "\x8b"
    IntToByteMap[140] = "\x8c"
    IntToByteMap[141] = "\x8d"
    IntToByteMap[142] = "\x8e"
    IntToByteMap[143] = "\x8f"
    IntToByteMap[144] = "\x90"
    IntToByteMap[145] = "\x91"
    IntToByteMap[146] = "\x92"
    IntToByteMap[147] = "\x93"
    IntToByteMap[148] = "\x94"
    IntToByteMap[149] = "\x95"
    IntToByteMap[150] = "\x96"
    IntToByteMap[151] = "\x97"
    IntToByteMap[152] = "\x98"
    IntToByteMap[153] = "\x99"
    IntToByteMap[154] = "\x9a"
    IntToByteMap[155] = "\x9b"
    IntToByteMap[156] = "\x9c"
    IntToByteMap[157] = "\x9d"
    IntToByteMap[158] = "\x9e"
    IntToByteMap[159] = "\x9f"
    IntToByteMap[160] = "\xa0"
    IntToByteMap[161] = "\xa1"
    IntToByteMap[162] = "\xa2"
    IntToByteMap[163] = "\xa3"
    IntToByteMap[164] = "\xa4"
    IntToByteMap[165] = "\xa5"
    IntToByteMap[166] = "\xa6"
    IntToByteMap[167] = "\xa7"
    IntToByteMap[168] = "\xa8"
    IntToByteMap[169] = "\xa9"
    IntToByteMap[170] = "\xaa"
    IntToByteMap[171] = "\xab"
    IntToByteMap[172] = "\xac"
    IntToByteMap[173] = "\xad"
    IntToByteMap[174] = "\xae"
    IntToByteMap[175] = "\xaf"
    IntToByteMap[176] = "\xb0"
    IntToByteMap[177] = "\xb1"
    IntToByteMap[178] = "\xb2"
    IntToByteMap[179] = "\xb3"
    IntToByteMap[180] = "\xb4"
    IntToByteMap[181] = "\xb5"
    IntToByteMap[182] = "\xb6"
    IntToByteMap[183] = "\xb7"
    IntToByteMap[184] = "\xb8"
    IntToByteMap[185] = "\xb9"
    IntToByteMap[186] = "\xba"
    IntToByteMap[187] = "\xbb"
    IntToByteMap[188] = "\xbc"
    IntToByteMap[189] = "\xbd"
    IntToByteMap[190] = "\xbe"
    IntToByteMap[191] = "\xbf"
    IntToByteMap[192] = "\xc0"
    IntToByteMap[193] = "\xc1"
    IntToByteMap[194] = "\xc2"
    IntToByteMap[195] = "\xc3"
    IntToByteMap[196] = "\xc4"
    IntToByteMap[197] = "\xc5"
    IntToByteMap[198] = "\xc6"
    IntToByteMap[199] = "\xc7"
    IntToByteMap[200] = "\xc8"
    IntToByteMap[201] = "\xc9"
    IntToByteMap[202] = "\xca"
    IntToByteMap[203] = "\xcb"
    IntToByteMap[204] = "\xcc"
    IntToByteMap[205] = "\xcd"
    IntToByteMap[206] = "\xce"
    IntToByteMap[207] = "\xcf"
    IntToByteMap[208] = "\xd0"
    IntToByteMap[209] = "\xd1"
    IntToByteMap[210] = "\xd2"
    IntToByteMap[211] = "\xd3"
    IntToByteMap[212] = "\xd4"
    IntToByteMap[213] = "\xd5"
    IntToByteMap[214] = "\xd6"
    IntToByteMap[215] = "\xd7"
    IntToByteMap[216] = "\xd8"
    IntToByteMap[217] = "\xd9"
    IntToByteMap[218] = "\xda"
    IntToByteMap[219] = "\xdb"
    IntToByteMap[220] = "\xdc"
    IntToByteMap[221] = "\xdd"
    IntToByteMap[222] = "\xde"
    IntToByteMap[223] = "\xdf"
    IntToByteMap[224] = "\xe0"
    IntToByteMap[225] = "\xe1"
    IntToByteMap[226] = "\xe2"
    IntToByteMap[227] = "\xe3"
    IntToByteMap[228] = "\xe4"
    IntToByteMap[229] = "\xe5"
    IntToByteMap[230] = "\xe6"
    IntToByteMap[231] = "\xe7"
    IntToByteMap[232] = "\xe8"
    IntToByteMap[233] = "\xe9"
    IntToByteMap[234] = "\xea"
    IntToByteMap[235] = "\xeb"
    IntToByteMap[236] = "\xec"
    IntToByteMap[237] = "\xed"
    IntToByteMap[238] = "\xee"
    IntToByteMap[239] = "\xef"
    IntToByteMap[240] = "\xf0"
    IntToByteMap[241] = "\xf1"
    IntToByteMap[242] = "\xf2"
    IntToByteMap[243] = "\xf3"
    IntToByteMap[244] = "\xf4"
    IntToByteMap[245] = "\xf5"
    IntToByteMap[246] = "\xf6"
    IntToByteMap[247] = "\xf7"
    IntToByteMap[248] = "\xf8"
    IntToByteMap[249] = "\xf9"
    IntToByteMap[250] = "\xfa"
    IntToByteMap[251] = "\xfb"
    IntToByteMap[252] = "\xfc"
    IntToByteMap[253] = "\xfd"
    IntToByteMap[254] = "\xfe"
    IntToByteMap[255] = "\xff"

    delete ByteToIntMap
    init_b2i_map(ByteToIntMap)

    HexToByteMap["00"] = "\x00"
    HexToByteMap["01"] = "\x01"
    HexToByteMap["02"] = "\x02"
    HexToByteMap["03"] = "\x03"
    HexToByteMap["04"] = "\x04"
    HexToByteMap["05"] = "\x05"
    HexToByteMap["06"] = "\x06"
    HexToByteMap["07"] = "\x07"
    HexToByteMap["08"] = "\x08"
    HexToByteMap["09"] = "\x09"
    HexToByteMap["0a"] = "\x0a"
    HexToByteMap["0b"] = "\x0b"
    HexToByteMap["0c"] = "\x0c"
    HexToByteMap["0d"] = "\x0d"
    HexToByteMap["0e"] = "\x0e"
    HexToByteMap["0f"] = "\x0f"
    HexToByteMap["10"] = "\x10"
    HexToByteMap["11"] = "\x11"
    HexToByteMap["12"] = "\x12"
    HexToByteMap["13"] = "\x13"
    HexToByteMap["14"] = "\x14"
    HexToByteMap["15"] = "\x15"
    HexToByteMap["16"] = "\x16"
    HexToByteMap["17"] = "\x17"
    HexToByteMap["18"] = "\x18"
    HexToByteMap["19"] = "\x19"
    HexToByteMap["1a"] = "\x1a"
    HexToByteMap["1b"] = "\x1b"
    HexToByteMap["1c"] = "\x1c"
    HexToByteMap["1d"] = "\x1d"
    HexToByteMap["1e"] = "\x1e"
    HexToByteMap["1f"] = "\x1f"
    HexToByteMap["20"] = "\x20"
    HexToByteMap["21"] = "\x21"
    HexToByteMap["22"] = "\x22"
    HexToByteMap["23"] = "\x23"
    HexToByteMap["24"] = "\x24"
    HexToByteMap["25"] = "\x25"
    HexToByteMap["26"] = "\x26"
    HexToByteMap["27"] = "\x27"
    HexToByteMap["28"] = "\x28"
    HexToByteMap["29"] = "\x29"
    HexToByteMap["2a"] = "\x2a"
    HexToByteMap["2b"] = "\x2b"
    HexToByteMap["2c"] = "\x2c"
    HexToByteMap["2d"] = "\x2d"
    HexToByteMap["2e"] = "\x2e"
    HexToByteMap["2f"] = "\x2f"
    HexToByteMap["30"] = "\x30"
    HexToByteMap["31"] = "\x31"
    HexToByteMap["32"] = "\x32"
    HexToByteMap["33"] = "\x33"
    HexToByteMap["34"] = "\x34"
    HexToByteMap["35"] = "\x35"
    HexToByteMap["36"] = "\x36"
    HexToByteMap["37"] = "\x37"
    HexToByteMap["38"] = "\x38"
    HexToByteMap["39"] = "\x39"
    HexToByteMap["3a"] = "\x3a"
    HexToByteMap["3b"] = "\x3b"
    HexToByteMap["3c"] = "\x3c"
    HexToByteMap["3d"] = "\x3d"
    HexToByteMap["3e"] = "\x3e"
    HexToByteMap["3f"] = "\x3f"
    HexToByteMap["40"] = "\x40"
    HexToByteMap["41"] = "\x41"
    HexToByteMap["42"] = "\x42"
    HexToByteMap["43"] = "\x43"
    HexToByteMap["44"] = "\x44"
    HexToByteMap["45"] = "\x45"
    HexToByteMap["46"] = "\x46"
    HexToByteMap["47"] = "\x47"
    HexToByteMap["48"] = "\x48"
    HexToByteMap["49"] = "\x49"
    HexToByteMap["4a"] = "\x4a"
    HexToByteMap["4b"] = "\x4b"
    HexToByteMap["4c"] = "\x4c"
    HexToByteMap["4d"] = "\x4d"
    HexToByteMap["4e"] = "\x4e"
    HexToByteMap["4f"] = "\x4f"
    HexToByteMap["50"] = "\x50"
    HexToByteMap["51"] = "\x51"
    HexToByteMap["52"] = "\x52"
    HexToByteMap["53"] = "\x53"
    HexToByteMap["54"] = "\x54"
    HexToByteMap["55"] = "\x55"
    HexToByteMap["56"] = "\x56"
    HexToByteMap["57"] = "\x57"
    HexToByteMap["58"] = "\x58"
    HexToByteMap["59"] = "\x59"
    HexToByteMap["5a"] = "\x5a"
    HexToByteMap["5b"] = "\x5b"
    HexToByteMap["5c"] = "\x5c"
    HexToByteMap["5d"] = "\x5d"
    HexToByteMap["5e"] = "\x5e"
    HexToByteMap["5f"] = "\x5f"
    HexToByteMap["60"] = "\x60"
    HexToByteMap["61"] = "\x61"
    HexToByteMap["62"] = "\x62"
    HexToByteMap["63"] = "\x63"
    HexToByteMap["64"] = "\x64"
    HexToByteMap["65"] = "\x65"
    HexToByteMap["66"] = "\x66"
    HexToByteMap["67"] = "\x67"
    HexToByteMap["68"] = "\x68"
    HexToByteMap["69"] = "\x69"
    HexToByteMap["6a"] = "\x6a"
    HexToByteMap["6b"] = "\x6b"
    HexToByteMap["6c"] = "\x6c"
    HexToByteMap["6d"] = "\x6d"
    HexToByteMap["6e"] = "\x6e"
    HexToByteMap["6f"] = "\x6f"
    HexToByteMap["70"] = "\x70"
    HexToByteMap["71"] = "\x71"
    HexToByteMap["72"] = "\x72"
    HexToByteMap["73"] = "\x73"
    HexToByteMap["74"] = "\x74"
    HexToByteMap["75"] = "\x75"
    HexToByteMap["76"] = "\x76"
    HexToByteMap["77"] = "\x77"
    HexToByteMap["78"] = "\x78"
    HexToByteMap["79"] = "\x79"
    HexToByteMap["7a"] = "\x7a"
    HexToByteMap["7b"] = "\x7b"
    HexToByteMap["7c"] = "\x7c"
    HexToByteMap["7d"] = "\x7d"
    HexToByteMap["7e"] = "\x7e"
    HexToByteMap["7f"] = "\x7f"
    HexToByteMap["80"] = "\x80"
    HexToByteMap["81"] = "\x81"
    HexToByteMap["82"] = "\x82"
    HexToByteMap["83"] = "\x83"
    HexToByteMap["84"] = "\x84"
    HexToByteMap["85"] = "\x85"
    HexToByteMap["86"] = "\x86"
    HexToByteMap["87"] = "\x87"
    HexToByteMap["88"] = "\x88"
    HexToByteMap["89"] = "\x89"
    HexToByteMap["8a"] = "\x8a"
    HexToByteMap["8b"] = "\x8b"
    HexToByteMap["8c"] = "\x8c"
    HexToByteMap["8d"] = "\x8d"
    HexToByteMap["8e"] = "\x8e"
    HexToByteMap["8f"] = "\x8f"
    HexToByteMap["90"] = "\x90"
    HexToByteMap["91"] = "\x91"
    HexToByteMap["92"] = "\x92"
    HexToByteMap["93"] = "\x93"
    HexToByteMap["94"] = "\x94"
    HexToByteMap["95"] = "\x95"
    HexToByteMap["96"] = "\x96"
    HexToByteMap["97"] = "\x97"
    HexToByteMap["98"] = "\x98"
    HexToByteMap["99"] = "\x99"
    HexToByteMap["9a"] = "\x9a"
    HexToByteMap["9b"] = "\x9b"
    HexToByteMap["9c"] = "\x9c"
    HexToByteMap["9d"] = "\x9d"
    HexToByteMap["9e"] = "\x9e"
    HexToByteMap["9f"] = "\x9f"
    HexToByteMap["a0"] = "\xa0"
    HexToByteMap["a1"] = "\xa1"
    HexToByteMap["a2"] = "\xa2"
    HexToByteMap["a3"] = "\xa3"
    HexToByteMap["a4"] = "\xa4"
    HexToByteMap["a5"] = "\xa5"
    HexToByteMap["a6"] = "\xa6"
    HexToByteMap["a7"] = "\xa7"
    HexToByteMap["a8"] = "\xa8"
    HexToByteMap["a9"] = "\xa9"
    HexToByteMap["aa"] = "\xaa"
    HexToByteMap["ab"] = "\xab"
    HexToByteMap["ac"] = "\xac"
    HexToByteMap["ad"] = "\xad"
    HexToByteMap["ae"] = "\xae"
    HexToByteMap["af"] = "\xaf"
    HexToByteMap["b0"] = "\xb0"
    HexToByteMap["b1"] = "\xb1"
    HexToByteMap["b2"] = "\xb2"
    HexToByteMap["b3"] = "\xb3"
    HexToByteMap["b4"] = "\xb4"
    HexToByteMap["b5"] = "\xb5"
    HexToByteMap["b6"] = "\xb6"
    HexToByteMap["b7"] = "\xb7"
    HexToByteMap["b8"] = "\xb8"
    HexToByteMap["b9"] = "\xb9"
    HexToByteMap["ba"] = "\xba"
    HexToByteMap["bb"] = "\xbb"
    HexToByteMap["bc"] = "\xbc"
    HexToByteMap["bd"] = "\xbd"
    HexToByteMap["be"] = "\xbe"
    HexToByteMap["bf"] = "\xbf"
    HexToByteMap["c0"] = "\xc0"
    HexToByteMap["c1"] = "\xc1"
    HexToByteMap["c2"] = "\xc2"
    HexToByteMap["c3"] = "\xc3"
    HexToByteMap["c4"] = "\xc4"
    HexToByteMap["c5"] = "\xc5"
    HexToByteMap["c6"] = "\xc6"
    HexToByteMap["c7"] = "\xc7"
    HexToByteMap["c8"] = "\xc8"
    HexToByteMap["c9"] = "\xc9"
    HexToByteMap["ca"] = "\xca"
    HexToByteMap["cb"] = "\xcb"
    HexToByteMap["cc"] = "\xcc"
    HexToByteMap["cd"] = "\xcd"
    HexToByteMap["ce"] = "\xce"
    HexToByteMap["cf"] = "\xcf"
    HexToByteMap["d0"] = "\xd0"
    HexToByteMap["d1"] = "\xd1"
    HexToByteMap["d2"] = "\xd2"
    HexToByteMap["d3"] = "\xd3"
    HexToByteMap["d4"] = "\xd4"
    HexToByteMap["d5"] = "\xd5"
    HexToByteMap["d6"] = "\xd6"
    HexToByteMap["d7"] = "\xd7"
    HexToByteMap["d8"] = "\xd8"
    HexToByteMap["d9"] = "\xd9"
    HexToByteMap["da"] = "\xda"
    HexToByteMap["db"] = "\xdb"
    HexToByteMap["dc"] = "\xdc"
    HexToByteMap["dd"] = "\xdd"
    HexToByteMap["de"] = "\xde"
    HexToByteMap["df"] = "\xdf"
    HexToByteMap["e0"] = "\xe0"
    HexToByteMap["e1"] = "\xe1"
    HexToByteMap["e2"] = "\xe2"
    HexToByteMap["e3"] = "\xe3"
    HexToByteMap["e4"] = "\xe4"
    HexToByteMap["e5"] = "\xe5"
    HexToByteMap["e6"] = "\xe6"
    HexToByteMap["e7"] = "\xe7"
    HexToByteMap["e8"] = "\xe8"
    HexToByteMap["e9"] = "\xe9"
    HexToByteMap["ea"] = "\xea"
    HexToByteMap["eb"] = "\xeb"
    HexToByteMap["ec"] = "\xec"
    HexToByteMap["ed"] = "\xed"
    HexToByteMap["ee"] = "\xee"
    HexToByteMap["ef"] = "\xef"
    HexToByteMap["f0"] = "\xf0"
    HexToByteMap["f1"] = "\xf1"
    HexToByteMap["f2"] = "\xf2"
    HexToByteMap["f3"] = "\xf3"
    HexToByteMap["f4"] = "\xf4"
    HexToByteMap["f5"] = "\xf5"
    HexToByteMap["f6"] = "\xf6"
    HexToByteMap["f7"] = "\xf7"
    HexToByteMap["f8"] = "\xf8"
    HexToByteMap["f9"] = "\xf9"
    HexToByteMap["fa"] = "\xfa"
    HexToByteMap["fb"] = "\xfb"
    HexToByteMap["fc"] = "\xfc"
    HexToByteMap["fd"] = "\xfd"
    HexToByteMap["fe"] = "\xfe"
    HexToByteMap["ff"] = "\xff"

    delete ByteToHexMap
    init_b2h_map(ByteToHexMap)

    PaddingBytes[1] = "\0"
    PaddingBytes[2] = "\0\0"
    PaddingBytes[3] = "\0\0\0"
    PaddingBytes[4] = "\0\0\0\0"
    PaddingBytes[5] = "\0\0\0\0\0"
    PaddingBytes[6] = "\0\0\0\0\0\0"
    PaddingBytes[7] = "\0\0\0\0\0\0\0"
}

# Compute the sha1sum of a string
function sha1sum_str(str,    sha1sum, hash)
{
    sha1sum = "sha1sum"
    printf("%s", str) |& sha1sum
    close(sha1sum, "to")        # close outbound pipe or coprocess will hang
    sha1sum |& getline hash
    close(sha1sum, "from")      # close inbound pipe

    # sha1sum outputs 40-char hash and filename separated by a single space
    hash = substr(hash, 1, 40) # strip filename from sha1sum

    return hash
}

# Return up to 7 null bytes "\0" for padding
function null_bytes(n)
{
    if (n < 1)
        return

    assert(n < 8, "n < 8")

    return PaddingBytes[n]
}

# Convert, e.g., "abcd" -> "\xab\xcd"
# nbytes may be passed to left-pad
function hex_to_bytes(hex, nbytes,    len, npad, bytes, i)
{
    len = length(hex)
    utils::assert(len % 2 == 0, "hex string has odd length")

    # Left-pad zero bytes as necessary
    npad = nbytes - int(len / 2)
    while (npad > 7) {
        bytes = bytes null_bytes(7)
        npad -= 7
    }
    bytes = bytes null_bytes(npad)

    for (i = 1; i < len; i += 2) {
        bytes = bytes h2b(substr(hex, i, 2))
    }

    return bytes
}

# Convert, e.g., "\xab\xcd" -> "abcd"
# ndigits may be passed to left-pad
function bytes_to_hex(bytes, ndigits,    len, hex)
{
    len = length(bytes)

    # TODO: pad "0" to ndigits

    for (i = 1; i < len; i++) {
        hex = hex b2h(substr(bytes, i, 1))
    }

    return hex
}

# Map n from 0..2,147,483,647 to a 4-byte integer in big-endian order
function num_to_uint32(n,    b1, b2, b3, b4)
{
    b4 = i2b(n % 256)
    n = int(n / 256)
    b3 = i2b(n % 256)
    n = int(n / 256)
    b2 = i2b(n % 256)
    n = int(n / 256)
    b1 = i2b(n % 256)

    return b1 b2 b3 b4
}

# Map a 4-byte integer in big-endian order to an awk number
function uint32_to_num(i,    n, b) {
    split(i, b, "")
    n = b2i(b[4])
    n += b2i(b[3])
    n += b2i(b[2])
    n += b2i(b[1])
    return n
}

# Function interface to IntToByteMap
function i2b(i)
{
    assert(i > -1 && i < 256, "int not in range 0 - 255")
    return IntToByteMap[i]
}

# Function interface to ByteToIntMap
function b2i(b)
{
    assert(match(b, "[\x00-\xff]"), "byte not in range 0 - 255")
    return ByteToIntMap[b]
}

# Function interface to HexToByteMap
function h2b(h)
{
    assert(match(h, /^[[:xdigit:]]{2}$/), "hex not in range 00 - ff")
    return HexToByteMap[h]
}

# Function interface to ByteToHexMap
function b2h(b)
{
    assert(match(b, "[\x00-\xff]"), "byte not in range 0 - ff")
    return ByteToHexMap[b]
}

function init_b2i_map(b2imap,    i)
{
    for (i in IntToByteMap) {
        b2imap[IntToByteMap[i]] = i
    }
}

function init_b2h_map(b2hmap,    h)
{
    for (h in HexToByteMap) {
        b2hmap[HexToByteMap[h]] = h
    }
}

# https://www.gnu.org/software/gawk/manual/html_node/Assert-Function.html
function assert(condition, string)
{
    if (!condition) {
        printf("assertion failed: %s\n", string) > "/dev/stderr"
        exit 1
    }
}
