#!/bin/bash

VAR=""
DPATH="/u01/ceirapp/CDR_copy_remote/"
process_name=$1
operator=$2
source=$3

echo "Start $1 $2 $3  $(date "+%Y-%m-%d")"


build="file_move_remote.jar"
cd $DPATH 
status=`ps -ef | grep $build $1 $2 $3 | grep -v grep| grep java`
if [ "$status" != "$VAR" ]
then
echo "The process is already running"
else
echo "The process is not running. Starting the process"
#java -jar $build $1 $2 $3 -Dspring.config.location=:./application.properties &
java  -Dlog4j.configuration=file:./conf/log4j.properties -cp ./lib/*:./file_move_remote.jar com.gl.FileScpProcess.Application $1 $2 $3 &
echo "Process Started"
fi
echo "End $1 $2 $3  $(date "+%Y-%m-%d")"

