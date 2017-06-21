FROM seedcloud/php:7.1

ENV SEEDCLOUD_DIR_FILES /mnt/files
ENV SEEDCLOUD_DIR_CONF /var/www/conf

ENV PHP_REALPATH_CACHE_TTL 3600
ENV PHP_OUTPUT_BUFFERING 16384

RUN su-exec www-data composer global require drush/drush && \
    su-exec www-data composer clear-cache && \
    curl https://drupalconsole.com/installer -L -o drupal.phar && \
    mv drupal.phar /usr/local/bin/drupal && \
    chmod +x /usr/local/bin/drupal && \
    mv /usr/local/bin/actions.mk /usr/local/bin/php.mk && \
    # Change overridden target name to avoid warnings.
    sed -i 's/git-checkout:/php-git-checkout:/' /usr/local/bin/php.mk && \
    mkdir -p $SEEDCLOUD_DIR_FILES $SEEDCLOUD_DIR_CONF && \
    chown -R www-data:www-data $SEEDCLOUD_DIR_CONF

COPY templates /etc/gotpl/
COPY actions /usr/local/bin
COPY init /docker-entrypoint-init.d/
