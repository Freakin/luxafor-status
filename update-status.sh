#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"            
timestamp=`date`

printlog() {
    
    printf "[ $timestamp ] $1\n"
}

printerr() {
     printf "\e[31;1m%s\e[0m\n" "[ $timestamp ] $*" >&2; 
}

get_webex_status() {
    resp=$(/usr/bin/curl -s -f -H "Authorization: Bearer ${WEBEX_TOKEN}" -X GET "https://webexapis.com/v1/people?email=${USER_EMAIL}")
    status="$?"
    if [ $status -ne 0 ];
        then
            printerr "error calling webex api" && exit $status
    else
        echo "$resp" | /usr/local/bin/jq -r '.items[]|.status'
    fi
}

generate_luxafor_post_data() {
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

update_luxafor_status() {
    if [ -z $1 ];
        then
            printerr "status must be provided as first positional argument. valid values are 'available' or 'meeting'" && exit 1
    else
        case $1 in
            available)
                status_color="00ff00"
                ;;    
            meeting)
                status_color="ff0000"
                ;;
            *)
                printerr "invalid status provided, unable to set luxafor" && exit 1
        esac
    fi
    
    /usr/bin/curl -s -X POST -H "Content-Type: application/json" --data "$(generate_luxafor_post_data)" "https://api.luxafor.com/webhook/v1/actions/solid_color" 
}


## Setup variables from vars.sh
if [ -a ${DIR}/vars.sh ]; then
    source ${DIR}/vars.sh
else
    printerr "vars.sh not found, exiting" && exit 1
fi

## Ensure env vars are set
if [ -z ${LUXAFOR_ID} ]; then printerr "LUXAFOR_ID not set, exiting" && exit 1; fi
if [ -z ${USER_EMAIL} ]; then printerr "USER_EMAIL not set, exiting" && exit 1; fi
if [ -z ${WEBEX_TOKEN} ]; then printerr "WEBEX_TOKEN not set, exiting" && exit 1; fi

## Default available unless I'm in a meeting
meeting_status="available"

## Get Webex Status from API
webex_status=$(get_webex_status)
printlog "webex_status: ${webex_status}"

## Set meeting status if webex is in a meeting
case $webex_status in
    inactive)
        meeting_status="available"
        ;;
    active)
        meeting_status="available"
        ;;            
    meeting)
        meeting_status="meeting"
        ;;
esac

## Get zoom status by finding meeting window until I can find a better way...
if ps aux|grep -i zoom | grep -i "c[ap]thost.app"; then
    meeting_status="meeting"
    printlog "zoom status: meeting running"
else
    printlog "zoom status: not running"
fi

printlog "setting luxafor status as '${meeting_status}'"

## Update Luxafor status via webhook
printlog $(update_luxafor_status ${meeting_status})