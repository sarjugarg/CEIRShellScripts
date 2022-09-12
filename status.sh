#!/bin/bash

op_name=$1
status_folder="/u02/ceirdata/status_cdr/$op_name"
set -x
date=$(date "+%Y-%m-%d")
month=$(date "+%m")
year=$(date "+%Y")
day=$(date "+%d")

cd $status_folder

[[ -d $2  ]]  || mkdir $2
cd $2/

[[ -d $year ]] || mkdir $year
cd $year/
[[ -d $month ]] || mkdir $month
cd $month/
[[ -d $day ]] || mkdir $day
cd $day/

echo "$3" >> status.txt 
