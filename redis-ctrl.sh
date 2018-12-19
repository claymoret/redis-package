#!/bin/bash

cwd=$(dirname $0)
cd $cwd

action=$1
shift

ports="$@"
if [ -z "$ports" ]; then
    #ports="9000 9001 9002 9003 9004 9005"
    ports="6379"
fi

running() {
    port=$1
    pid_file=/var/run/redis-${port}.pid
    if [ -f $pid_file ]; then
        pid=$(cat $pid_file)
        ps aux | awk -v pid=$pid '$2 == pid {print}' | grep $pid > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            return 0
        else
            rm $pid_file
            return 1
        fi
    fi
    return 1
}

start() {
    for i in $@; do
        bin/redis-server conf/redis-${i}.conf
    done
}

stop() {
    for i in $@; do
        bin/redis-cli -p $i shutdown
    done
}

status() {
    for i in $@; do
        if running $i; then
            echo "redis is running at: $i"
        else
            echo "redis is not running at: $i"
        fi
    done
}

help() {
    echo "Usage: $0 {start|stop|status|restart} [ports]"
}

case $action in

    start)
        start $ports
        ;;

    stop)
        stop $ports
        ;;

    status)
        status $ports
        ;;

    *)
        help
        ;;
esac
