#!/bin/bash

#variables
jssurl="https://activecampaign.jamfcloud.com"
stringtodecrypt="U2FsdGVkX1++CuYSFcAy2TpDZaeVNCjR+/z6usjMk4CWc8BLiOX7fuHiTzyIhC4B"
salt="be0ae61215c032d9"
k="52b9e0815b5ce4a9611994ed"
jssapiuser="unmanageapi"
#Use Jamfs encrypted parameter tool to log in to JSS
#This is found at https://github.com/jamf/Encrypted-Script-Parameters
function DecryptString() {
    # Usage: ~$ DecryptString "Encrypted String" "Salt" "Passphrase"
    echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

jsspw=$(DecryptString $stringtodecrypt $salt $k)

# Get JSS ID for current computer. 
#get serial number and look up JSS ID  
serial=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $NF}')
echo "the computers serial is $serial"
computerID=$(curl -sku $jssapiuser:$jsspw $jssurl/JSSResource/computers/serialnumber/$serial -H "Accept: text/xml" -X GET | xmllint --xpath '/computer/general/id/text()' -)
echo "the computers JSS ID is $computerID"

#Flush All Logs
#/usr/local/jamf/bin/jamf flushPolicyHistory

#Unmanage device in JSS
curl -sku $jssapiuser:$jsspw $jssurl/JSSResource/computers/id/$computerID -H "Content-Type: text/xml" -X PUT -d "<computer><general><remote_management><managed>false</managed></remote_management></general></computer>"
curl -sku $jssapiuser:$jsspw $jssurl/JSSResource/computercommands/command/UnmanageDevice/id/$computerID -X POST