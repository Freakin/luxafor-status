#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"            

if [ -a ${DIR}/vars.sh ];
    then
        source ${DIR}/vars.sh
else
    echo "vars.sh not found, exiting"
    exit 1
fi

webex_status=$(${DIR}/get-webex.sh -u ${USER_EMAIL} -t ${WEBEX_TOKEN} )
echo "webex_status: ${webex_status}"
${DIR}/set-luxafor.sh -s ${webex_status}