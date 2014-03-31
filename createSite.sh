#!/bin/bash

if [[ $1 = "" ]]; then
    echo "No name supplied"
    exit
fi

WEB_PATH=/data/web
WEB_SIZE=5G
NEW_SITE=$1

echo "Creating base directory for $NEW_SITE"
SITE_PATH=$WEB_PATH/$NEW_SITE

echo "This will create a standard GS linux website in $SITE_PATH"
echo "Confirm [N]/y?"
read CONFIRM
if [[ $CONFIRM = "N" || $CONFIRM = "n" || $CONFIRM = "" && $CONFIRM != "y" && $CONFIRM != "Y" ]]
then
        echo "Operation Aborted..."
        exit
fi

mkdir /data/web/$NEW_SITE

echo "Creating new FS"
FS_NAME=web_$NEW_SITE
lvcreate -L $WEB_SIZE -n $FS_NAME datavg

echo "Formatting FS"
mkfs.ext4 /dev/datavg/$FS_NAME

echo "Mounting FS"
mount /dev/datavg/$FS_NAME $SITE_PATH

echo "Adding FS to fstab"
echo "/dev/datavg/$FS_NAME $SITE_PATH ext4 defaults 1 2" >> /etc/fstab

echo "Creating site folders"
mkdir $SITE_PATH/www $SITE_PATH/conf $SITE_PATH/livrable $SITE_PATH/logs $SITE_PATH/fcgi

echo "Add index.php file"
cp ~/tools/conf/index.php $SITE_PATH/www/index.php

echo "Creating basic config file"
sed -e "s/_sample_/$NEW_SITE/g" ~/tools/conf/vhost_sample.conf > $SITE_PATH/conf/vhost_$NEW_SITE.conf
sed -e "s/_sample_/$NEW_SITE/g" ~/tools/conf/fpm_sample.conf > $SITE_PATH/conf/fpm_$NEW_SITE.conf
sed -e "s/_sample_/$NEW_SITE/g" ~/tools/conf/maintenance_sample.conf > $SITE_PATH/conf/maintenance_$NEW_SITE.conf

echo "Creating LogRotate Script"
sed -e "s/_SAMPLE_/$NEW_SITE/g" ~/tools/conf/app_log_rotate > /etc/logrotate.d/app_$NEW_SITE

echo "Fixing ACL"
chown -R webadmin:www $SITE_PATH
chown -R apache:apache $SITE_PATH/fcgi
chown -R root:root $SITE_PATH/lost+found
chmod 775 $SITE_PATH/logs

echo "Linking Config"
echo "Include $SITE_PATH/conf/vhost_$NEW_SITE.conf" >> /etc/httpd/conf.d/zz_gs.conf
echo "include=$SITE_PATH/conf/fpm_$NEW_SITE.conf" >> /etc/php-fpm.d/gs.conf

echo "Reloading http conf"
/etc/init.d/httpd reload
/etc/init.d/php-fpm reload

