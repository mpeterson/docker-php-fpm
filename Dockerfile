FROM mpeterson/base:0.2
MAINTAINER mpeterson <docker@peterson.com.ar>

# Make APT non-interactive
ENV DEBIAN_FRONTEND noninteractive

# Ensure UTF-8
ENV LANG       en_US.UTF-8
ENV LC_ALL     en_US.UTF-8

# Change this ENV variable to skip the docker cache from this line on
ENV LATEST_CACHE 2017-04-10T13:00+02:00

# Upgrade the system to the latest version
RUN apt-get update
RUN apt-get upgrade -y

# Install packages needed for this image
RUN apt-get install -y --force-yes php-fpm php-cli php-memcached php-mbstring\
	php-mysql php-pgsql php-sqlite3 php-gd php-json php-iconv php-simplexml php-zip\
	php-curl php-intl php-mcrypt php-imagick php-imap ca-certificates php-apcu

# This after the package installation so we can use the docker cache
RUN mkdir /build
ADD . /build

# Starting the installation of this particular image

# Recreate the cluster in UTF-8, allow external connections, create
# new user and modify the location of the data
VOLUME ["/data"]
ENV DATA_DIR /data

# Sane defaults php.ini
RUN sed -i -e '/^max_execution_time/c\
max_execution_time = 300' /etc/php/7.0/fpm/php.ini
RUN sed -i -e '/^upload_max_filesize/c\
upload_max_filesize = 16G' /etc/php/7.0/fpm/php.ini
RUN sed -i -e '/^post_max_size/c\
post_max_size = 16G' /etc/php/7.0/fpm/php.ini
RUN sed -i -e '/^output_buffering/c\
output_buffering = 16384' /etc/php/7.0/fpm/php.ini

# Sane defaults php-fpm.conf
RUN sed -i -e '/^;emergency_restart_threshold/c\
emergency_restart_threshold = 10' /etc/php/7.0/fpm/php-fpm.conf

RUN sed -i -e '/^;emergency_restart_interval/c\
emergency_restart_interval = 1m' /etc/php/7.0/fpm/php-fpm.conf

RUN sed -i -e '/^;process_control_timeout/c\
process_control_timeout = 10' /etc/php/7.0/fpm/php-fpm.conf

# Sane defaults www.conf
RUN sed -i -e '/^;pm.max_requests/c\
pm.max_requests = 10000' /etc/php/7.0/fpm/pool.d/www.conf

RUN sed -i -e '/^;request_terminate_timeout/c\
request_terminate_timeout = 300s' /etc/php/7.0/fpm/pool.d/www.conf

RUN sed -i -e 's/^;env/env/g' /etc/php/7.0/fpm/pool.d/www.conf

# Sane defaults OPCache
RUN echo 'opcache.memory_consumption=128' \ 
	>> /etc/php/7.0/fpm/conf.d/05-opcache.ini
RUN echo 'opcache.interned_strings_buffer=8' \ 
	>> /etc/php/7.0/fpm/conf.d/05-opcache.ini
RUN echo 'opcache.max_accelerated_files=4000' \
	 >> /etc/php/7.0/fpm/conf.d/05-opcache.ini
RUN echo 'opcache.revalidate_freq=60' \
	 >> /etc/php/7.0/fpm/conf.d/05-opcache.ini
RUN echo 'opcache.max_wasted_percentage=5' \
	 >> /etc/php/7.0/fpm/conf.d/05-opcache.ini
RUN echo 'opcache.fast_shutdown=1' \
	 >> /etc/php/7.0/fpm/conf.d/05-opcache.ini

# Allow external connections
RUN sed -i -e '/^listen/c\listen = 0.0.0.0:9000' /etc/php/7.0/fpm/pool.d/www.conf

# Keep originals for later restore and make the appropriate links
RUN cp -a /var/www /var/.www.orig || :
RUN rm -rf /var/www
RUN ln -s $DATA_DIR /var/www

RUN cp /build/run_php.sh /sbin/run_php.sh
RUN chown root:root /sbin/run_php.sh

EXPOSE 9000
EXPOSE 22

# End of particularities of this image

# Give the possibility to override any file on the system
RUN cp -R /build/overrides/. / || :

# Clean everything up
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /build

CMD ["/sbin/run_php.sh"]
