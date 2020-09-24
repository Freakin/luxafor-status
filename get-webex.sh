#!/bin/bash

## Returns status string for user in webex API
## Sources WEBEX_TOKEN from vars.sh
## Requires -u flag for email address to look up in webex


    

while getopts u:t: flag
do
    case "${flag}" in
        u) username=${OPTARG};;
        t) token=${OPTARG}
    esac
done

if [ -z ${token} ];
    then
        echo 'token (-t) not set, exiting'
        exit 1
fi
if [ -z ${username} ];
    then
        echo 'username (-u) not set, exiting'
        exit 1
fi


resp=$(/usr/bin/curl -s -f -H "Authorization: Bearer ${token}" -X GET "https://webexapis.com/v1/people?email=${username}")
status="$?"
if [ $status -ne 0 ];
    then
        echo "error calling webex api"
        exit $status
else
    echo "$resp" | /usr/local/bin/jq -r '.items[]|.status'
fi