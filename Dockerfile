FROM ubuntu:xenial

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN echo "deb http://opensource.xtdv.net/ubuntu/ xenial main restricted" > /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial-updates main restricted" >> /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial universe" >> /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial-updates universe" >> /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial multiverse" >> /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial-updates multiverse" >> /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial-security main restricted" >> /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial-security universe" >> /etc/apt/sources.list.d/xtdv.list && \
  echo "deb http://opensource.xtdv.net/ubuntu/ xenial-security multiverse" >> /etc/apt/sources.list.d/xtdv.list && \
  apt-get update
RUN apt-get -y install git supervisor apache2 software-properties-common mariadb-server php7.0 libapache2-mod-php7.0 php7.0-cli php7.0-common php7.0-mbstring php7.0-gd php7.0-intl php7.0-xml php7.0-mysql php7.0-mcrypt php7.0-zip && \
  echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add image configuration and scripts
ADD start-apache2.sh /start-apache2.sh
ADD start-mysqld.sh /start-mysqld.sh
ADD run.sh /run.sh
RUN chmod 755 /*.sh
ADD my.cnf /etc/mysql/conf.d/my.cnf
ADD hosts /etc/hosts
ADD supervisord-apache2.conf /etc/supervisor/conf.d/supervisord-apache2.conf
ADD supervisord-mysqld.conf /etc/supervisor/conf.d/supervisord-mysqld.conf

# Remove pre-installed database
RUN rm -rf /var/lib/mysql/*

# Add MySQL utils
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN chmod 755 /*.sh

# config to enable .htaccess
ADD apache_default /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Configure /app folder with sample app
RUN git clone https://github.com/fermayo/hello-world-lamp.git /app
RUN mkdir -p /app && rm -fr /var/www/html && ln -s /app /var/www/html

#Environment variables to configure php
ENV PHP_UPLOAD_MAX_FILESIZE 10M
ENV PHP_POST_MAX_SIZE 10M

# Add volumes for MySQL 
VOLUME  ["/etc/mysql", "/var/lib/mysql" ]

EXPOSE 80 3306
CMD ["/run.sh"]
