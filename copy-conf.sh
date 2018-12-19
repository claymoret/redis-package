#!/bin/bash

help() {
    echo "Usage: $0 conf-to-copy target-ports"
}

if [ -z "$1" ]; then
    help
    exit 1
fi

src_file=$1
if [ ! -f "$src_file" ]; then
    echo "$src_file do not exist"
    exit 1
fi
shift

cwd=$(dirname $src_file)
cd $cwd

src_file=$(basename $src_file)
port=$(grep "^port" $src_file | awk '{print $2}')
if [ -z "$port" ]; then
    echo "could not find port in $src_file"
    exit 1
fi

if [ -z "$1" ]; then
    help
    exit 1
fi

for i in $@; do
    if [ $port -ne $i ]; then
        dest_file=${src_file%-*}-$i.conf
        echo "create $dest_file"
        cp $src_file $dest_file
        sed -i "s/$port/$i/g" $dest_file
    fi
done
