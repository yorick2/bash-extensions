#!/usr/bin/env bash

# n98-magerun.phar
alias n98='echo running n98-magerun.phar; n98-magerun.phar'
alias n98fl='echo running n98-magerun.phar cache:flush; n98-magerun.phar cache:flush'
alias n98nu='echo running n98-magerun.phar admin:user:create; n98-magerun.phar admin:user:create'
alias n98pass='echo running n98-magerun.phar admin:user:change-password; n98-magerun.phar admin:user:change-password'
alias n98re='echo running n98-magerun.phar index:reindex:all; n98-magerun.phar index:reindex:all'
alias n98dis='echo running n98-magerun.phar cache:disable; n98-magerun.phar cache:disable'

# magento 1
alias rmcache='echo "rm -rf var/cache/* var/session/*"; rm -rf var/cache/* var/session/*'

# magento 2
alias n982='echo running n98-magerun2.phar; n98-magerun2.phar'
alias n982fl='echo running n98-magerun2.phar cache:flush; n98-magerun2.phar cache:flush'
alias n982nu='echo running n98-magerun2.phar admin:user:create; n98-magerun2.phar admin:user:create'
alias n982pass='echo running n98-magerun2.phar admin:user:change-password; n98-magerun2.phar admin:user:change-password'
alias n982re='echo running n98-magerun2.phar index:reindex:all; n98-magerun2.phar index:reindex:all'
alias n982dis='echo running n98-magerun2.phar cache:disable; n98-magerun2.phar cache:disable'

alias magento2DevMode="echo 'php bin/magento deploy:mode:set developer' ; php bin/magento deploy:mode:set developer"
alias magento2ProdMode="echo 'php bin/magento deploy:mode:set production' ; php bin/magento deploy:mode:set production"

alias magento2UpgradeNStatic="echo 'php bin/magento setup:upgrade \
 && php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean' \
 ; php bin/magento setup:upgrade \
 && php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean"
alias magento2staticFlush="echo 'php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean' \
 ; php bin/magento setup:static-content:deploy \
 && php bin/magento cache:clean"