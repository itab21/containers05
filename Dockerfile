# create from debian image
FROM debian:bullseye

# mount volume for mysql data
VOLUME /var/lib/mysql

# mount volume for logs
VOLUME /var/log

# install supervisor, apache2, php, mod_php for apache2, php-mysql and mariadb
RUN apt-get update && \
    apt-get install -y supervisor apache2 php libapache2-mod-php php-mysql mariadb-server && \
    apt-get clean

ADD https://wordpress.org/latest.tar.gz /var/www/html/

RUN tar -xzf /var/www/html/latest.tar.gz -C /var/www/html --strip-components=1 && \
    rm /var/www/html/latest.tar.gz && \
    chown -R www-data:www-data /var/www/html

# copy the configuration file for apache2 from files/ directory
COPY files/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY files/apache2/apache2.conf /etc/apache2/apache2.conf

# copy the configuration file for php from files/ directory
COPY files/php/php.ini /etc/php/8.2/apache2/php.ini

# copy the configuration file for mysql from files/ directory
COPY files/mariadb/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# copy the supervisor configuration file
COPY files/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# create mysql socket directory
RUN mkdir /var/run/mysqld && chown mysql:mysql /var/run/mysqld

EXPOSE 80

# start supervisor
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]