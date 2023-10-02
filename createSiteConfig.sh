#!/bin/bash

# Global Var
NGINX_CONFIG='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'



SELECTEDTEMPATE='drupal.template'

SED=`which sed`

# ARG
SITEURL=$1
SITEUSER=$2
PHPVER=$3
TEMPLATE=$4

PHPFPMDIR=/etc/php/$3/fpm/pool.d
SITE_DIR=/var/www/$SITEURL
SITE_DIR_PUB=$SITE_DIR


# Usage Info
if [ "$1" == "-h" ] || [ "$#" -ne 4 ] ; then
  echo "Usage: `basename $0` URL USER PHP-VERSION TEMPLATE" 
  echo "        PHP-VERSION can be 5.6,7.4"
  echo "        TEMPLATE can be wordpress,drupal,drupal7"
  echo "        example aklawfirm.gr aklawfirm 7.4 drupal"
  exit 0
fi

# Copy virtual hosts templates

if [ "$4" == "drupal" ]; then 
  echo 'template check OK'	
  SELECTEDTEMPATE='drupal.template'
  SITE_DIR_PUB=$SITE_DIR/web
elif [ "$4" == "drupal7" ]; then
  echo 'template check OK'		
  SELECTEDTEMPATE='drupal.template'	
elif [ "$4" == "wordpress" ]; then
  echo 'template check OK'		
  SELECTEDTEMPATE='wordpress.template'		
else 
  echo "Usage: `basename $0` URL USER PHP-VERSION TEMPLATE"
  echo "        PHP-VERSION can be 5.6,7.4"
  echo "        TEMPLATE can be wordpress,drupal,drupal7"
  echo "        example aklawfirm.gr aklawfirm 7.4 drupal"
  exit 0
fi

if [ -d "$PHPFPMDIR" ]; then
	echo 'PHP check OK'
else 
  echo "Usage: `basename $0` URL USER PHP-VERSION TEMPLATE"
  echo "        PHP-VERSION can be 5.6,7.4,8.1"
  echo "        TEMPLATE can be wordpress,drupal,drupal7"
  echo "        example aklawfirm.gr aklawfirm 7.4 drupal"
  exit 0
fi	

# Create User
echo 'creating user...'	
adduser --disabled-password --gecos "" $SITEUSER
cp -r /root/.ssh /home/$SITEUSER/.ssh
chown -R $SITEUSER:$SITEUSER /home/$SITEUSER/.ssh
mkdir -p $SITE_DIR_PUB
chown -R $SITEUSER:$SITEUSER $SITE_DIR

# Create nginx config
CONFIG=$NGINX_CONFIG/$SITEURL.conf
cp $SELECTEDTEMPATE $CONFIG
$SED -i "s/SITEURL/$SITEURL/g" $CONFIG
$SED -i "s!SITE_DIR!$SITE_DIR_PUB!g" $CONFIG
$SED -i "s/VERSION/$PHPVER/g" $CONFIG
$SED -i "s/SITEUSER/$SITEUSER/g" $CONFIG 
ln -s $CONFIG $NGINX_SITES_ENABLED/$SITEURL.conf

# Create php fpm config
FPMCONFIG=$PHPFPMDIR/$SITEURL.conf
cp phpfpm.template $FPMCONFIG
$SED -i "s!SITE_DIR!$SITE_DIR!g" $FPMCONFIG
$SED -i "s/VERSION/$PHPVER/g" $FPMCONFIG
$SED -i "s/SITEUSER/$SITEUSER/g" $FPMCONFIG 


PASSWORDSUGGESTION=`date +%s | sha256sum | base64 | head -c 32` 
echo "finished. Next steps:"
echo "        createDB.sh $SITEUSER ${SITEUSER}_db $PASSWORDSUGGESTION"
echo "        service nginx restart"
echo "        service php$PHPVER-fpm restart"
echo "        make sure the dns is pointing at the site"
echo "        certbot --nginx -d ${SITEURL} -d www.${SITEURL}"
