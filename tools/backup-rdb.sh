#!/bin/bash

cd $(dirname $0)

BACKUP_MAX=12

port=${1:-6379}
backup_dir=${2:-./backup_$port}
host=$(netstat -nltp | grep :6379|awk '{print $4}'| awk -F: '{print $1}')

if [[ -z $host ]] || [[ $host == "0.0.0.0" ]]
then
    host="127.0.0.1"
fi

rdb_name=$(redis-cli -h $host -p $port config get dbfilename| grep -v ^dbfilename)
rdb_path=$(redis-cli -h $host -p $port config get dir|grep -v ^dir)
rdb_file=$rdb_path/$rdb_name

test -f $rdb_file || exit 1

test -d $backup_dir || mkdir $backup_dir
cp $rdb_file $backup_dir/$rdb_name.$(date +%s)

backup_num=$(ls $backup_dir/$rdb_name* | wc | awk '{print $1}')
if ((backup_num > BACKUP_MAX))
then
    delete_num=$((backup_num - BACKUP_MAX))
    ls -lt $backup_dir/$rdb_name* | tail -n $delete_num | awk '{print $NF}' | xargs rm -f
fi
