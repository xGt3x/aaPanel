#! /bin/bash
# https://github.com/xGt3x/aaPanel

R(){ #Red
#echo -e "\033[31m\033[01m$1\033[0m"
echo -e "\e[31m$1\e[0m"
}
G(){ #Green
echo -e "\033[32m\033[01m$1\033[0m"
}
Y(){ #Yellow
echo -e "\033[33m\033[01m$1\033[0m"
}
B(){ #Blue
echo -e "\033[34m\033[01m$1\033[0m"
}
P(){ #Purple
echo -e "\033[35m\033[01m$1\033[0m"
}

# 1
function aapanel-install(){
wget -O "/root/aapanel-install.sh" "http://www.aapanel.com/script/install_6.0_en.sh"
G "Installing the original aapanel panel from the official website."
bash "/root/aapanel-install.sh"
}

# 2
function bt-install(){ 
wget -O "/root/bt-install.sh" "https://raw.githubusercontent.com/xGt3x/aaPanel/main/script/install_6.0_en.sh"
bash "/root/bt-install.sh"
}

# 3
function downgrade-aapanel(){
read -p "Do you want to downgrade aaPanel(y/n): " y
if [ "$y" != "y" ]; then
R "Downgrade canceled"
exit
fi

if [ -e /www/server/panel/data/home.json ]
then
wget -O "/root/panel6_en.zip" "https://raw.githubusercontent.com/xGt3x/aaPanel/main/resource/panel6_en.zip"
unzip panel6_en.zip
cd /root/panel
wget -O "/root/downgrade.sh" "https://ghproxy.com/https://raw.githubusercontent.com/xGt3x/aapanel/main/script/downgrade.sh" 
bash "/root/downgrade.sh"
rm /root/panel6_en.zip /root/panel/ -rf
else
R "Downgrade Failed Please install aaPanel."
fi
}

# 4
function panel-happy(){
read -p "Do you want to cracked aaPanel(y/n): " y
if [ "$y" != "y" ]; then
R "Cracked canceled"
exit
fi

if [ -e /www/server/panel/data/plugin.json ]
then
sed -i 's|"endtime": -1|"endtime": 0|g' /www/server/panel/data/plugin.json
sed -i 's|"pro": -1|"pro": 0|g' /www/server/panel/data/plugin.json
chattr +i /www/server/panel/data/plugin.json
G "Cracked successfully."
else
R "Crack Failed Please install aaPanel."
fi
}

# 5
function uninstall(){
G " 7. Uninstall panel only"
Y " 8. Uninstall panel and operating environment"
Y " WARNING:may affect sites, databases and other data"
R " 9. Uninstall panel operating environment and clear"
R " all site-related data"
echo "==================================================="

while true; do
read -p "Please select the operation to perform: " action;
case $action in
[7])
read -p "Uninstall panel only(y/n): " y
if [ "$y" != "y" ]; then
exit
fi
Remove_Bt
;;
[8])
read -p "Uninstall panel and operating environment(y/n): " y
if [ "$y" != "y" ]; then
exit
fi

if [ -f "/usr/bin/yum" ] && [ -f "/usr/bin/rpm" ]; then
Remove_Rpm
fi

Remove_Service
Remove_Bt
;;
[9])
read -p "Uninstall panel all system(y/n): " y
if [ "$y" != "y" ]; then
exit
fi
if [ -f "/usr/bin/yum" ] && [ -f "/usr/bin/rpm" ]; then
Remove_Rpm
fi

Remove_Service
Remove_Bt
Remove_Data
;;
[0])
exit
;;

* ) P "Please type only 7.8.9 or 0 Exit";;
esac
done
}

# 6
function clean-up-trash(){
read -p "Do you want to Cleanup script produces junk files(y/n): " y
if [ "$y" != "y" ]; then
R "Cleanup canceled"
exit
fi

rm panel6_en.zip aapanel-install.sh bt-install.sh downgrade.sh panel/ -rf
Y "If you want to remove this script, run 'rm aapanel.sh -rf'"
G "Cleaned up successfully."
}

# uninstall Menu
Remove_Bt(){
if [ ! -f "/etc/init.d/bt" ] || [ ! -d "/www/server/panel" ]; then
R "This server does not install bt-panel"
exit;
fi

if [ -f "/etc/init.d/bt_syssafe" ]; then
P "This server is installed with Baota system reinforcement, which may cause it to be unable to uninstall normally. Please execute the uninstall command after uninstalling it on the panel!"
exit;
fi

if [ -f "/etc/init.d/bt_tamper_proof" ]; then
G "This server is installed with Baota website anti-tampering"
exit;
fi

/etc/init.d/bt stop
if [ -f "/usr/sbin/chkconfig" ];then
chkconfig --del bt
elif [ -f "/usr/sbin/update-rc.d" ];then
update-rc.d -f bt remove
fi

if [ -e /www/server/panel/data/plugin.json ]
then
chattr -i /www/server/panel/data/plugin.json
fi

chattr -i /www/server/panel/script/site_task.py
rm -rf /www/server/panel
rm -f /etc/init.d/bt 
G "bt-panel uninstall success"
exit;
}

Remove_Rpm(){
P "Query the installed rpm package.."
P -e "Find installed packages"
for lib in bt-nginx bt-httpd bt-mysql bt-curl bt-AliSQL AliSQL-master bt-mariadb bt-php-5.2 bt-php-5.3 bt-php-5.4 bt-php-5.5 bt-php-5.6 bt-php-7.0 bt-php-7.1
do
rpm -qa |grep ${lib} > ${lib}.pl
libRpm=`cat ${lib}.pl`
if [ "${libRpm}" != "" ]; then
rpm -e ${libRpm} --nodeps > /dev/null 2>&1
echo -e ${lib} "\033[32mclean\033[0m"
fi

rm -f ${lib}.pl
done
yum remove bt-openssl* -y
yum remove bt-php* -y
G "Cleaned up"
}

Remove_Service(){
servicePath="/www/server"

for service in nginx httpd mysqld pure-ftpd tomcat redis memcached mongodb pgsql tomcat tomcat7 tomcat8 tomcat9 php-fpm-52 php-fpm-53 php-fpm-54 php-fpm-55 php-fpm-56 php-fpm-70 php-fpm-71 php-fpm-72 php-fpm-73
do
if [ -f "/etc/init.d/${service}" ]; then
/etc/init.d/${service} stop
if [ -f "/usr/sbin/chkconfig" ];then
chkconfig  --del ${service}
elif [ -f "/usr/sbin/update-rc.d" ];then
update-rc.d -f ${service} remove
fi

if [ "${service}" = "mysqld" ]; then
rm -rf ${servicePath}/mysql
rm -f /etc/my.cnf
elif [ "${service}" = "httpd" ]; then
rm -rf ${servicePath}/apache
elif [ "${service}" = "memcached" ]; then
rm -rf /usr/local/memcached
elif [ -d "${servicePath}/${service}" ]; then
rm -rf ${servicePath}/${service}
fi 

rm -f /etc/init.d/${service}
echo -e ${service} "\033[32mclean\033[0m"
fi
done

[ -d "${servicePath}/php" ] && rm -rf ${servicePath}/php
if [ -d "${servicePath}/phpmyadmin" ]; then
rm -rf ${servicePath}/phpmyadmin
echo -e "phpmyadmin" "\033[32mclean\033[0m"
fi

if [ -d "${servicePath}/nvm" ]; then
source /www/server/nvm/nvm.sh
pm2 stop all
rm -rf ${servicePath}/nvm
sed -i "/NVM/d" /root/.bash_profile
sed -i "/NVM/d" /root/.bashrc
echo -e "node.js" "\033[32mclean\033[0m"
fi

Y "Clear the panel operating environment."
}
Remove_Data(){
rm -rf /www/server/data
rm -rf /www/server/
rm -rf /www/wwwlogs
rm -rf /www/wwwroot
rm -rf /www/disk.pl
}

# Menu
function start_menu(){
clear
echo ""
P " Thank you for using the aaPanel tool."
P " https://github.com/xGt3x/aaPanel"
Y " -------------------------------------------------"
G " 1. Install aaPanel Latest version"
G " 2. Install aaPanel version 6.8.37"
Y " -------------------------------------------------"
G " 3. Downgrade to aaPanel version 6.8.37"
G " 4. Crack aaPanel 6.x"
Y " -------------------------------------------------"
G " 5. Uninstall the aaPanel panel"
G " 6. Cleanup script produces junk files"
G " 0. Exit"
Y " -------------------------------------------------"
read -p "Please key in numbers:" menuNumberInput
case "$menuNumberInput" in
1 )
aapanel-install
;;
2 )
bt-install
;;
3 )
downgrade-aapanel
;;
4 )
panel-happy
;;
5 )
uninstall
;;
6 )
clean-up-trash
;;
0 )
exit 
;;
* )
clear
R "Please enter the correct number!"
start_menu
;;
esac
}
start_menu "first"
