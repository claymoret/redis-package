#!/bin/bash

server_path=$1
port=$2

if [[ ! -e $server_path ]]
then
    echo "server $server_path do not exist"
    exit 1
fi

cd $server_path
server_path=$(pwd)
cd -

if [[ -z $port ]]
then
    echo "port not specified"
    exit 1
fi

new_server=server_$port
mkdir $new_server
cd $new_server
new_server_data_path=$(pwd)/data
mkdir $new_server_data_path
cp -r $server_path/config .
old_port=$(cat config/* | grep ^port | head -n 1 | awk '{print $2}')
echo "change port from $old_port to $port"
for f in config/*
do
    sed -i "s/$old_port/$port/" $f
done
sed -i "s#^dir.*#dir $new_server_data_path#" config/redis.conf

cp -r $server_path/admin .
for f in admin/*
do
    sed -i "s/$old_port/$port/" $f
done

cp -r $server_path/bin .

mkdir log
