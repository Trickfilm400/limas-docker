#!/bin/env bash

cd /var/www/html

chown www-data:www-data -R /var/www/html/data
su -l www-data -s /bin/bash
# migrate database always to newest state
php bin/console doctrine:migrations:migrate

# onetime generation
if [[ ! -f /var/www/html/data/.docker_installed ]]; then
  php bin/console --env=dev doctrine:fixtures:load --group=setup --append
  php bin/console limas:user:create --role super_admin admin admin@example.com admin || exit 2
  php bin/console lexik:jwt:generate-keypair || exit 2
  php bin/console limas:extjs:models || exit 2
  php bin/console cache:warmup || exit 2
  touch /var/www/html/data/.docker_installed
fi

# start apache
docker-php-entrypoint apache2-foreground