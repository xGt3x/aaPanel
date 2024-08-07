#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
LANG=en_US.UTF-8

# aapanel downgrade script

panel_path='/www/server/panel'

if [ ! -d $panel_path ];then
echo "The aapanel panel is currently not installed!"
exit 0;
fi

base_dir=$(cd "$(dirname "$0")";pwd)
if [ $base_dir = $panel_path ];then
echo "Cannot execute downgrade command in panel root directory!"
exit 0;
fi

if [ ! -d $base_dir/class ];then
echo "No downgrade file found!"
exit 0;
fi

rm -f $panel_path/*.pyc $panel_path/class/*.pyc
\cp -r -f $base_dir/. $panel_path/
/etc/init.d/bt restart
echo "===================================="
echo "The rollback to a previous version has been completed.!"