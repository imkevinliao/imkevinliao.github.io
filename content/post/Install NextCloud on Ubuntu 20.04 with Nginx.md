---
title: "Install NextCloud on Ubuntu 20.04 with Nginx "
date: 2022-02-15T21:16:59+08:00
draft: false
---
more details please click source:<https://www.linuxbabe.com/ubuntu/install-nextcloud-ubuntu-20-04-nginx-lemp-stack>
# What’s NextCloud?
NextCloud is a free open-source self-hosted cloud storage solution. It’s functionally similar to Dropbox. Proprietary cloud storage solutions (Dropbox, Google Drive, etc) are convenient, but at a price: they can be used to collect personal data because your files are stored on their computers. If you worried about privacy, you can switch to NextCloud, which you can install on your private home server or on a virtual private server (VPS). You can upload your files to your server via NextCloud and then sync those files to your desktop computer, laptop or smartphone. This way you have full control of your data.
# Step 1: Download NextCloud on Ubuntu 20.04
Log into your Ubuntu 20.04 server. Then download the NextCloud zip archive onto your server. The latest stable version is 21.0.1 at time of this writing. You may need to change the version number. Go to https://nextcloud.com/install and click the download for server button to see the latest version.
```
wget https://download.nextcloud.com/server/releases/nextcloud-21.0.1.zip
sudo apt install unzip
sudo unzip nextcloud-21.0.1.zip -d /usr/share/nginx/
sudo chown www-data:www-data /usr/share/nginx/nextcloud/ -R
```
# Step 2: Create a Database and User for Nextcloud in MariaDB Database Server
```
sudo mysql
create database nextcloud;
create user nextclouduser@localhost identified by 'your-password';
grant all privileges on nextcloud.* to nextclouduser@localhost identified by 'your-password';
flush privileges;
exit;
```
# Step 3: Create a Nginx Config File for Nextcloud
sudo vim /etc/nginx/conf.d/nextcloud.conf
```
server {
    listen 80;
    listen [::]:80;
    server_name nextcloud.example.com;

    # Add headers to serve security related headers
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header X-Download-Options noopen;
    add_header X-Permitted-Cross-Domain-Policies none;
    add_header Referrer-Policy no-referrer;

    #I found this header is needed on Ubuntu, but not on Arch Linux. 
    add_header X-Frame-Options "SAMEORIGIN";

    # Path to the root of your installation
    root /usr/share/nginx/nextcloud/;

    access_log /var/log/nginx/nextcloud.access;
    error_log /var/log/nginx/nextcloud.error;

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # The following 2 rules are only needed for the user_webfinger app.
    # Uncomment it if you're planning to use this app.
    #rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
    #rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json
    # last;

    location = /.well-known/carddav {
        return 301 $scheme://$host/remote.php/dav;
    }
    location = /.well-known/caldav {
       return 301 $scheme://$host/remote.php/dav;
    }

    location ~ /.well-known/acme-challenge {
      allow all;
    }

    # set max upload size
    client_max_body_size 512M;
    fastcgi_buffers 64 4K;

    # Disable gzip to avoid the removal of the ETag header
    gzip off;

    # Uncomment if your server is build with the ngx_pagespeed module
    # This module is currently not supported.
    #pagespeed off;

    error_page 403 /core/templates/403.php;
    error_page 404 /core/templates/404.php;

    location / {
       rewrite ^ /index.php;
    }

    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
       deny all;
    }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console) {
       deny all;
     }

    location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+|core/templates/40[34])\.php(?:$|/) {
       include fastcgi_params;
       fastcgi_split_path_info ^(.+\.php)(/.*)$;
       try_files $fastcgi_script_name =404;
       fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
       fastcgi_param PATH_INFO $fastcgi_path_info;
       #Avoid sending the security headers twice
       fastcgi_param modHeadersAvailable true;
       fastcgi_param front_controller_active true;
       fastcgi_pass unix:/run/php/php7.4-fpm.sock;
       fastcgi_intercept_errors on;
       fastcgi_request_buffering off;
    }

    location ~ ^/(?:updater|ocs-provider)(?:$|/) {
       try_files $uri/ =404;
       index index.php;
    }

    # Adding the cache control header for js and css files
    # Make sure it is BELOW the PHP block
    location ~* \.(?:css|js)$ {
        try_files $uri /index.php$uri$is_args$args;
        add_header Cache-Control "public, max-age=7200";
        # Add headers to serve security related headers (It is intended to
        # have those duplicated to the ones above)
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        add_header Referrer-Policy no-referrer;
        # Optional: Don't log access to assets
        access_log off;
   }

   location ~* \.(?:svg|gif|png|html|ttf|woff|ico|jpg|jpeg)$ {
        try_files $uri /index.php$uri$is_args$args;
        # Optional: Don't log access to other assets
        access_log off;
   }
}
```

```
sudo nginx -t
sudo systemctl reload nginx
```
# Step 4: Install and Enable PHP Modules
```
sudo apt install imagemagick php-imagick php7.4-common php7.4-mysql php7.4-fpm php7.4-gd php7.4-json php7.4-curl  php7.4-zip php7.4-xml php7.4-mbstring php7.4-bz2 php7.4-intl php7.4-bcmath php7.4-gmp
```
# Step 5: Enable HTTPS
# Step 6: Finish the Installation in your Web Browser
Now you can access the Nextcloud web install wizard using HTTPS connection.

https://nextcloud.example.com
```
sudo mkdir /usr/share/nginx/nextcloud-data
sudo chown www-data:www-data /usr/share/nginx/nextcloud-data -R
```
# How to Reset Nextcloud User Password From Command Line
```
sudo -u www-data php /usr/share/nginx/nextcloud/occ user:resetpassword nextcloud_username
```
