#!/bin/bash

cd $(dirname $0)

path=$1
back_file=backup-rdb.sh
cron_file=redis-backup

port=${2:-7900}

if [[ -z $path ]]
then
    echo "Usage: $0 path"
    exit 1
fi

which redis-cli
if [[ $? -ne 0 ]]
then
    echo "check redis-cli error!"
    exit 1
fi

test -d $path || mkdir -p $path
cp $back_file $path

cat <<EOF > $cron_file
0 */2 * * * root /bin/bash $path/$back_file $port > $path/backup.log 2>&1
EOF

mv $cron_file /etc/cron.d
