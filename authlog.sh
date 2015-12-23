#!/bin/bash
#################################
#this script is used to find failed login attempts on your linux machine and send the alert to your number.
#author: Hemant Thakur
#git: hemantthakur 
###############################
sendSMS(){
source /etc/environment
msg='{"src": "9882102908","dst": "+919736151123", "text": "'$1'"}'
resp=`curl -i --user $AUTH_ID:$AUTH_TOKEN -H "Content-Type: application/json" -d "$msg" -s https://api.plivo.com/v1/Account/$AUTH_ID/Message/`
}
# check whether this script is run by root user or not
if [[ $EUID -ne 0 ]]; then
 echo "Please run this script as ROOT" 2>&1
exit 1
fi
#step 1 find the unauthenticated logs
grep "authentication failure" /var/log/auth.log | awk '{ print $2, $3, $14,$15 }'  | grep "rhost" | awk '{print $1,$3,$4}' | sort | cut -b7-  | sort | uniq -c > /tmp/authCheck
#step 2 store them into a file  ... step 2 also performed in above line
#step 3 read the file and send sms to the number
FILENAME='/tmp/authCheck';
while read LINE
do
output_array=(`echo $LINE | sed -e 's/st=/\n/g'`);
count=${output_array[0]}
if [ -z ${output_array[2]} ];then
msg="Someone tried $count times unsuccessful attempt to logon using ${output_array[1]}";
else
msg="Someone tried $count times unsuccessful attempt to logon using ${output_array[1]} IP address on ${output_array[2]}";

fi
# call SMS function
if [ $count -gt 2 ];then
	sendSMS "${msg}"
fi
done < $FILENAME
unlink $FILENAME
#clear log file
# cat /dev/null>/var/log/auth.log;
