FROM tomruttle/apache-php
MAINTAINER Tom Ruttle <tom@tomruttle.com>

ENV DEBIAN_FRONTEND noninteractive

# Install base packages
RUN apt-get update &&\
    apt-get -yq install \
        php5-fpm \
        php5-mcrypt \
        php-console-table \
        php5-mysql \
        mysql-client

# Install so we can run drush commands: sql-sync, rsync, etc.
RUN apt-get -yq install \
        openssh-client \
        rsync

# Need allow_url_fopen for S3 upload to work; Need huge memory for Drupal to work
RUN sed -i -e"s/allow_url_fopen.*/allow_url_fopen = On/" /etc/php5/apache2/php.ini ;\
    sed -i -e"s/^memory_limit.*/memory_limit = 256M/" /etc/php5/apache2/php.ini

RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/sites-available/default
RUN a2enmod headers rewrite vhost_alias

# Install Drush
RUN composer self-update && \
    COMPOSER_BIN_DIR=/usr/local/bin/ composer global require drush/drush:6.*

# These are unnecessary, as they are specified in the base image
# but they make it clearer what's going on.
EXPOSE 80
ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-D", "FOREGROUND", "-k", "start"]
