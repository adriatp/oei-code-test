#!/bin/bash

API_ENDPOINT="http://localhost:3000"

(
    # colors
    COLOR_RESET="$(tput sgr0)"
    COLOR_RED="$(tput setaf 1)"
    COLOR_GREEN="$(tput setaf 2)"
    COLOR_CYAN="$(tput setaf 6)"

    TEST_DIR="test_cases"
    cd $TEST_DIR
    TEST_FILES=`ls *.txt`
    for entry in $TEST_FILES
    do
        echo "* TEST $entry"
        TEST_NUMBER=1
        cat $entry | egrep -v '^#' | while read line
        do
            INPUT=$(echo "$line" | cut -d"|" -f1)
            EXPECTED=$(echo "$line" | cut -d"|" -f2)

            if [ "$INPUT" != "" ]
            then
                OUTPUT=$(curl --silent \
                    -H "Content-Type: application/json" \
                    -X POST \
                    -d "$INPUT" \
                    "$API_ENDPOINT/api_app/v1/editions/filter"
                )

                if [ "$EXPECTED" == "$OUTPUT" ]
                then
                    echo " > $TEST_NUMBER : ${COLOR_GREEN}[  OK  ]${COLOR_RESET}"
                else
                    echo " > $TEST_NUMBER : ${COLOR_RED}[ FAIL ]${COLOR_RESET}"
                    echo " > ${COLOR_CYAN}INPUT${COLOR_RESET}:    $INPUT"
                    echo " > ${COLOR_CYAN}EXPECTED${COLOR_RESET}: $EXPECTED"
                    echo " > ${COLOR_CYAN}OUTPUT${COLOR_RESET}:   $OUTPUT"
                exit 1
                fi

                TEST_NUMBER=$((TEST_NUMBER+1))
            fi
        done
    done
)