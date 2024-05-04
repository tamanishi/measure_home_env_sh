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

BASE=$(${CMD_HOME}/measure_home_env_fs --dryrun)
CO2="{\"co2\": $(${CMD_HOME}/measure_air_quality | ${JQ_CMD} -c -M .co2)}"
DUST="{\"dust\": $(${CMD_HOME}/measure_air_dust | ${JQ_CMD} -c -M .dust_density)}"
HOME_ENV=$(echo "$BASE" "$CO2" "$DUST" | ${JQ_CMD} -s -c '.[0] * .[1] * .[2]')

if [ "$dry" = "TRUE" ]; then
    echo ${HOME_ENV}
else
    ${CMD_HOME}/post_home_env --collection-name measurements --json "$HOME_ENV"
fi

