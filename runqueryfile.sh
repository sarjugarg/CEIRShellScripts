#!/bin/bash 
set -x

. /home/ceirapp/.bash_profile
repdate=$(date +"%Y_%m_%d_%F_%T")
repdate1=$(date +"%Y_%m_%d")
fpath=$1
logfile2=$2SqlLogs.log_$repdate1
fCntLog=/u02/ceirdata/Sql_query_logs/Sql_Report/sqlReportFile_"$repdate1".log

cd $1
ls -tr *sql > test.txt
echo test.txt >> $logfile2
totalfile=`cat test.txt|wc -l`
echo $totalfile >> $logfile2
i=1
totalUpdateCount=0
while [ $i -le $totalfile ]

do

file=`cat test.txt|head -$i|tail -1`
echo $file >> $logfile2
if [ "$file" == '' ] 
then
	echo "File Not Found"
else
logfile=${2}${file}_${repdate}
wordcnt=`cat ${file}|wc -l`
now1="$(date +%F_%T)"
printf "start date and time %s\n" "$now1" >> $logfile
#echo name of file to be processsed ${fpath}${file}
echo name of file to be processsed  ${file}
get_week_date()
{
  `sqlplus -s CRESTELCEIR/CRESTELCEIR123#@//PRO-DBR-SCAN:1522/dmcprdb >> $logfile << EOF
    SET AUTOCOMMIT ON 
   @${fpath}${file} 
  commit;
EOF
        `
#echo "$file $wordcnt $now1 $(date +%F+%T)" >> "$fCntLog"
sql_return_code=$?

if [ $sql_return_code != 0 ]
then
#totalErrorCount=`expr $totalErrorCount + 1`
echo "The upgrade script failed. Please refer to the log results.txt for more information"
echo "Error code $sql_return_code"
	printf "End date and time %s\n" "$(date +%F+%T)" >> $logfile
#echo "$file $wordcnt $now1 $(date +%F+%T)" >> "$fCntLog"
exit 0;
fi
}
get_week_date
now2="$(date +%F_%T)"
	printf "End date and time %s\n" "$(date +%F+%T)" >> $logfile
totalUpdateCount=`cat ${logfile}|grep '1 row updated'|wc -l`
realFileName=$(echo $file | sed -e 's/.sql//g')
query="update cdr_file_details_db set status = 'Done' , sql_process_start_time= '$now1' , sql_process_end_time = '$now2' , total_query_sql = '$wordcnt'  , total_update_sql = '$totalUpdateCount' where FILE_NAME = '$realFileName' ;"
echo $query
updateSqlCount(){
`sqlplus -s CRESTELCEIR/CRESTELCEIR123#@//PRO-DBR-SCAN:1522/dmcprdb >> $logfile << EOF
  $query
  commit;
EOF
        `	 
	}
updateSqlCount	
echo "$query" >>  $logfile
#echo "$fname $wordcnt $now1 $(date +%F+%T)" >> "$fCntLog"
echo "The File Name is  $realFileName "
# java  -Dlog4j.configuration=file:/u01/ceirapp/recoveryProcess/conf/log4j.properties -cp /u01/ceirapp/recoveryProcess/lib/*:/u01/ceirapp/recoveryProcess/CdrProcessses.jar com.gl.FileScpProcess.ScpJavaProcess $realFileName &
mv ${file} $3
fi
#printf "start date and time %s\n" "$(date +%F+%T)" >> $logfile
echo "$file $wordcnt $now1 $(date +%F+%T)" >> "$fCntLog"
i=`expr $i + 1`
exit
done

rm $1/test.txt

