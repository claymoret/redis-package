#!/bin/bash

cwd=$(dirname $0)
cd $cwd
base_dir=$(pwd)

package_dir=$base_dir/redis
package_bin_dir=$package_dir/bin
package_data_dir=$package_dir/data

redis_src_loc=$(ls backup/redis-*.tar.gz | tail)
if [ -z "$redis_src_loc" ]
then
    echo "failed to find redis source"
    exit 1
fi
redis_src_tgz=$(basename $redis_src_loc)
redis_src_dir=${redis_src_tgz%%.tar.gz}
tar zxf $redis_src_loc
pushd $redis_src_dir
    make
    if [ $? -ne 0 ]
    then
        echo "failed to make, exit"
        exit 1
    fi
    test -d $package_bin_dir || mkdir -p $package_bin_dir
    test -d $package_data_dir || mkdir -p $package_data_dir
    cp src/redis-benchmark $package_bin_dir
    cp src/redis-check-aof $package_bin_dir
    cp src/redis-check-rdb $package_bin_dir
    cp src/redis-cli $package_bin_dir
    cp src/redis-sentinel $package_bin_dir
    cp src/redis-server $package_bin_dir
popd

cp -r conf $package_dir
cp copy-conf.sh $package_dir
cp redis-ctrl.sh $package_dir

tar zcvf redis.tar.gz redis --remove-files
rm -rf $redis_src_dir
