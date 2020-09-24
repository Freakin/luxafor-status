#!/bin/bash

## default available unless I'm in a meeting
meeting_status="available"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"            

if [ -a ${DIR}/vars.sh ];
    then
        source ${DIR}/vars.sh
else
    echo "vars.sh not found, exiting"
    exit 1
fi

### Get Webex Status from API
webex_status=$(${DIR}/get-webex.sh -u ${USER_EMAIL} -t ${WEBEX_TOKEN} )
echo "webex_status: ${webex_status}"
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

### Get zoom status by finding meeting window until I can find a better way...
if ps aux|grep -i zoom | grep -i "c[ap]thost.app"; then
    meeting_status="meeting"
    echo "zoom status: meeting running"
else
    echo "zoom status: not running"
fi

### Update status
${DIR}/set-luxafor.sh -s ${meeting_status}