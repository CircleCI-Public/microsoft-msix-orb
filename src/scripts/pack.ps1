$parameters = ""

if ( $Env:PACK_MAPPING_FILE -ne "") {
    "/f ${Env.PACK_MAPPING_FILE}"
}

MakeAppx pack /d $Env:PACK_INPUT_DIR /p $Env:PACK_OUTPUT_DIR $parameters