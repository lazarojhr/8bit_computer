#!/bin/bash

# Don't run as root.
if [[ ${UID} -eq 0 ]]
then
    echo "Don't run as root." >&2
    exit 1
fi

# Check for arguments.
if [[ ${#} -ne 2 ]]
then
    echo "USAGE: ${0} ASSEMBLY_CODE_FILE OUTPUT_FILE" >&2
    exit 1
fi

# Functions.
loop_word() {
    LOOP_WORD_RESULT=""
    for i in $(seq ${1} ${2}) 
    do
        LOOP_WORD_RESULT="${LOOP_WORD_RESULT}$(echo ${WORD:${i}:1})"
    done
}

convert_to_hex() {
    echo -n "${1}: " >> ${OUTPUT_FILE}
    for i in $(seq ${2} ${3})
    do
        for j in $(seq 1 4)
        do
            CURRENT=$(echo $(($(cat ${TEMP_FILE} | cut -d ' ' -f${j} | head -n${i} | tail -n+${i}))))
            case ${CURRENT} in
                10)
                    CURRENT_LINE="${CURRENT_LINE}a"
                    ;;
                11)
                    CURRENT_LINE="${CURRENT_LINE}b"
                    ;;
                12)
                    CURRENT_LINE="${CURRENT_LINE}c"
                    ;;
                13)
                    CURRENT_LINE="${CURRENT_LINE}d"
                    ;;
                14)
                    CURRENT_LINE="${CURRENT_LINE}e"
                    ;;
                15)
                    CURRENT_LINE="${CURRENT_LINE}f"
                    ;;
                *)
                    CURRENT_LINE="${CURRENT_LINE}${CURRENT}"
                    ;;
            esac
        done
        echo -n "${CURRENT_LINE} " >> ${OUTPUT_FILE}
        CURRENT_LINE=""
    done
    echo "" >> ${OUTPUT_FILE}
}

# Variables.
ASSEMBLY_FILE_SIZE=$(cat ${1} | wc -l)

COMMAND=""
LOCATION=""
LITERAL_ADDRS=""

SKIP=""

CODE_1=""
CODE_2=""
CODE_3=""
WORD=""
WORD_1=""
WORD_2=""
WORD_3=""
WORD_4=""
    
LOOP_WORD_RESULT=""

OUTPUT_FILE=${2}

# Temp file.
TEMP_FILE="/tmp/temp_binary_nums$(date +%F%H%M%S%N)"

# Clear the output file.
echo -n > ${2}

# Loop through the input file and extract the code.
for i in $(seq 1 ${ASSEMBLY_FILE_SIZE}) 
do
    # COMMAND
    COMMAND=$(cat ${1} | awk '{print $1}' | head -n${i} | tail -n+${i})
    
    if [[ -z ${COMMAND} ]] 
    then
        echo "Error on line ${i}" >&2
        exit 1
    fi

    case ${COMMAND} in
        addl)
            CODE_1='00000'
            ;;
        addw)
            CODE_1='00001'
            ;;
        andl)
            CODE_1='00010'
            ;;
        andw)
            CODE_1='00011'
            ;;
        orl)
            CODE_1='00100'
            ;;
        orw)
            CODE_1='00101'
            ;;
        nandw)
            CODE_1='00110'
            ;;
        norw)
            CODE_1='00111'
            ;;
        xorl)
            CODE_1='01000'
            ;;
        xorw)
            CODE_1='01001'
            ;;
        xnorw)
            CODE_1='01010'
            ;;
        notw)
            CODE_1='01011'
            ;;
        clrw)
            CODE_1='01100'
            ;;
        subl)
            CODE_1='01101'
            ;;
        subw)
            CODE_1='01110'
            ;;
        mul)
            CODE_1='01111'
            ;;
        shftl)
            CODE_1='10000'
            ;;
        shftr)
            CODE_1='10001'
            ;;
        rotl)
            CODE_1='10010'
            ;;
        rotr)
            CODE_1='10011'
            ;;
        movl)
            CODE_1='10100'
            ;;
        movw)
            CODE_1='10101'
            ;;
        movr)
            CODE_1='10110'
            ;;
        mova)
            CODE_1='10111'
            ;;
        nop)
            CODE_1='11000'
            ;;
        halt)
            CODE_1='11001'
            ;;
        goto)
            CODE_1='11010'
            ;;
        skipn)
            CODE_1='11011'
            ;;
        skipz)
            CODE_1='11100'
            ;;
        skipnz)
            CODE_1='11101'
            ;;
        movf)
            CODE_1='11110'
            ;;
        *)
            FIRST_LETTER=${COMMAND:0:1}
            if [[ ${FIRST_LETTER} = '#' ]]
            then
                # We have a comment.
                continue
            else
                echo "Error on line ${i}" >&2
                exit 1
            fi
    esac
    
    # LOCATION
    LOCATION=$(cat ${1} | awk '{print $2}' | head -n${i} | tail -n+${i})
    LOCATION_LENGTH=$(echo ${LOCATION} | awk '{print length}')
    
    if [[ -z ${LOCATION} ]] 
    then
        CODE_2='000'
        SKIP='1'
    elif [[ ${LOCATION_LENGTH} -gt 3 ]]
    then
        CODE_3=${LOCATION}
        CODE_2='000'
        SKIP='2'
    else
        CODE_2=${LOCATION}
        SKIP='0'
    fi

    # LITERAL OR ADDRESS
    if [[ ${SKIP} -eq '1' ]]
    then
        CODE_3='00000000'
    elif [[ ${SKIP} -eq '2' ]]
    then
        echo -n
    else
        LITERAL_ADDRS=$(cat ${1} | awk '{print $3}' | head -n${i} | tail -n+${i})
        LITERAL_ADDRS_LENGTH=$(echo ${LITERAL_ADDRS} | awk '{print length}')

        if [[ -z ${LITERAL_ADDRS} ]]
        then
            CODE_3='00000000'
        else
            CODE_3=${LITERAL_ADDRS}
        fi
    fi
    SKIP='0'

    if [[ ${CODE_1} = '01100' ]]
    then
        CODE_3='00000000'
    fi

    # Convert to hex.
    WORD="${CODE_1}${CODE_2}${CODE_3}"

    loop_word '0' '3'
    WORD_1=${LOOP_WORD_RESULT}
    WORD_1="2#${WORD_1}"
    
    loop_word '4' '7'
    WORD_2=${LOOP_WORD_RESULT}
    WORD_2="2#${WORD_2}"
    
    loop_word '8' '11'
    WORD_3=${LOOP_WORD_RESULT}
    WORD_3="2#${WORD_3}"
    
    loop_word '12' '15'
    WORD_4=${LOOP_WORD_RESULT}
    WORD_4="2#${WORD_4}"

    # Store in temp file.
    echo "${WORD_1} ${WORD_2} ${WORD_3} ${WORD_4}" >> ${TEMP_FILE}

    WORD=""
    WORD_1=""
    WORD_2=""
    WORD_3=""
    WORD_4=""
    COMMAND=""
    LOCATION=""
    LITERAL_ADDRS=""
    CODE_1=""
    CODE_2=""
    CODE_3=""
done

echo "v3.0 hex words addressed" > ${OUTPUT_FILE}
convert_to_hex "00" "1" "16"
convert_to_hex "10" "17" "32"
convert_to_hex "20" "33" "48"
convert_to_hex "30" "49" "64"
