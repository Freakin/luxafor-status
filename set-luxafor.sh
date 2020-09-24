#!/bin/bash

generate_post_data()
{
cat << EOF
{ 
    "userId": "${LUXAFOR_ID}", 
    "actionFields":
        { 
            "color": "custom", 
            "custom_color": "${status_color}" 
        }
}
EOF
}


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"            

if [ -a ${DIR}/vars.sh ];
    then
        source ${DIR}/vars.sh
else
    echo "vars.sh not found, exiting"
    exit 1
fi

if [ -z ${LUXAFOR_ID} ];
    then
        echo "LUXAFOR_ID not set, exiting"
        exit 1
fi

while getopts s: flag
do
    case "${flag}" in
        s) status=${OPTARG};;
    esac
done

if [ -z $status ];
    then
        echo "status (-s) not provided, exiting"
        exit 1
else
    case $status in
        available)
            status_color="00ff00"
            ;;    
        meeting)
            status_color="ff0000"
            ;;
        *)
            echo "invalid status provided, unable to set luxafor"
            exit 1
    esac
fi

/usr/bin/curl -X POST -H "Content-Type: application/json" --data "$(generate_post_data)" "https://api.luxafor.com/webhook/v1/actions/solid_color"