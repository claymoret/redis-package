#!/bin/bash

while read host port
do
	echo $host $port
	redis-cli -h $host -p $port info replication | grep role
	redis-cli -h $host -p $port config get save
	redis-cli -h $host -p $port config get appendonly
done < redis.host
