#!/bin/bash

CMD_HOME=/home/pi/.cargo/bin
JQ_CMD=/usr/bin/jq

while getopts ":d-:" opt; do
    case "$opt" in
        -)
            case "$OPTARG" in
                dryrun)
                    dry="TRUE"
                    ;;
            esac
            ;;
        d)
            dry="TRUE"
            ;;
    esac
done

CO2=$(${CMD_HOME}/measure_air_quality | ${JQ_CMD} -c -M .co2)
HOME_ENV=$(${CMD_HOME}/measure_home_env_fs --dryrun | ${JQ_CMD} -c -M --argjson co2 ${CO2} '. |= .+ {"co2": $co2}')

if [ "$dry" = "TRUE" ]; then
    echo ${HOME_ENV}
else
    ${CMD_HOME}/post_home_env --collection-name measurements --json "$HOME_ENV"
fi

