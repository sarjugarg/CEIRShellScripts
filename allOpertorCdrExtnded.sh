set -x
VAR=""
cd /u01/ceirapp/cdr_process
serverId="Sig-01"
TE=$(date "+%Y-%m-%d")
DATE=$(date "+%Y-%m-%d")
dbStatusUpdate(){ 
p3_query="insert into cdr_process_status (CREATED_ON ,process_name , START_TIME, status ,SERVER_ID ,OPERATOR,INSTANCE_ID ) values(to_date('$DATE','YYYY-MM-DD'), '$1' ,  '$2',   '$3' , '$4' , '$5' ,'$6'  )  "
sqlplus -s CRESTELCEIR/CRESTELCEIR123#@//PRO-DBR-SCAN:1522/dmcprdb << EOF
   ${p3_query};
   commit 
EOF

} 

oprName=$1
i=$2


if [ -e CEIRCdrParser.jar ]
 then
   status=`ps -ef |  grep cdrprocessor/${oprName}/${i}/process/ |grep -v vi | grep java`
   if [ "$status" != "$VAR" ]
     then
       echo 0:0:OK
     else
      
     start_date_time1=$(date "+%Y-%m-%d-%H:%M:%S")
 #        ./status.sh  "$oprName"  "${i}"  " Process Start at $start_date_time1" 
dbStatusUpdate "P3"  "$start_date_time1"   "Start" "$serverId" "$oprName" "${i}"
fileCount=`ls /u02/ceirdata/cdrprocessor/${oprName}/${i}/process/ | wc -l`

for ((k=1; k<=$fileCount; k++))
do
  java  -Dlog4j.configuration=file:./conf/${oprName}${i}log4j.properties -cp ./lib/*:./CEIRCdrParser.jar com.glocks.parser.CdrParserProcess /u02/ceirdata/cdrprocessor/${oprName}/${i}/process/  
sleep 5
done
start_date_time2=$(date "+%Y-%m-%d-%H:%M:%S")
#         ./status.sh  "$oprName"  "${i}"  " Process End at $start_date_time2"  
dbStatusUpdate "P3"  "$start_date_time2"   "End" "$serverId" "$oprName" "${i}"
sleep 5  
 status=`ps -ef |  grep ./runqueryfile.sh | grep -v vi | grep Sql_Loader_Files/${oprName}/${i}/ `
 if [ "$status" != "$VAR" ]
     then
       echo 0:0:OK
     else
 start_date_time3=$(date "+%Y-%m-%d-%H:%M:%S")
 #        ./status.sh  "$oprName"  "${i}"  " Sql Started at  $start_date_time3"
  dbStatusUpdate "SQL"  "$start_date_time3"   "Start" "$serverId" "$oprName" "${i}" 

fileCountSql=`ls /u02/ceirdata/Sql_Loader_Files/${oprName}/${i}/ | wc -l`
for ((t=1; t<=$fileCountSql; t++))
do
  ./runqueryfile.sh /u02/ceirdata/Sql_Loader_Files/${oprName}/${i}/ /u02/ceirdata/Sql_query_logs/${oprName}/${i}/ /u02/ceirdata/Sql_Processed_Files/${oprName}/${i}/   
sleep 5
done
 start_date_time4=$(date "+%Y-%m-%d-%H:%M:%S")
 #        ./status.sh  "$oprName"  "${i}"  " Sql End at  $start_date_time4"   
       dbStatusUpdate "SQL"  "$start_date_time4"   "End" "$serverId" "$oprName" "${i}"   
fi
fi
else
 echo 2
fi


 
#done
#done 


