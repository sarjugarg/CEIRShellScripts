set -x


cd /u01/ceirapp/cdr_process/scripts
oprName=$1
DATE=$(date "+%Y-%m-%d")
serverId="Sig-01"
for i in 1 2 3 4 5 6 7 8 9 10
do
echo " allOperatorExtended  $i  $(date "+%Y-%m-%d")"
 ./allOpertorCdrExtnded.sh $1 ${i} &
echo " allOperatorExtended  End $i  $(date "+%Y-%m-%d")"
done

echo "waiting for instances to end"
sleep 60
status_final=`ps -ef | grep 'CEIRCdrParser' | grep -v vi | grep $1 | wc -l`
while [ "$status_final" -gt 0 ]
do
   echo "instances running"
   status_final=`ps -ef | grep 'CEIRCdrParser' | grep $1 |grep -v vi | wc -l`
   sleep 60
done

dbStatusUpdate(){ 
p3_query="insert into cdr_process_status (CREATED_ON ,process_name , START_TIME, status ,SERVER_ID ,OPERATOR , modified_on  )  values( to_date('$DATE','YYYY-MM-DD'), '$1' ,  '$2',   '$3' , '$4' , '$5' ,  to_date('$DATE','YYYY-MM-DD')  )  "
sqlplus -s CRESTELCEIR/CRESTELCEIR123#@//PRO-DBR-SCAN:1522/dmcprdb << EOF
   ${p3_query};
    commit 
EOF

}
end_date_timeScriptV2=$(date "+%Y-%m-%d-%H:%M:%S")
dbStatusUpdate "scriptV2"  "$end_date_timeScriptV2"   "End" "$serverId" "$oprName"


echo "delete Process started"
cd /u01/ceirapp/scripts/sendProcessFileToSSH1
./start.sh $1 1>/u02/ceirdata/scripts/sendProcessFileToSSH1/logs/$1_$(date "+%Y-%m-%d-%H:%M:%S")_log 2>/u02/ceirdata/scripts/sendProcessFileToSSH1/logs/$1_$(date "+%Y-%m-%d-%H:%M:%S")_log 
echo "delete Process ended"
echo " allOperator  End $i  $(date "+%Y-%m-%d")"

exit ;
