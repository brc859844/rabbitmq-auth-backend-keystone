#!/bin/bash -v

# This script augments RabbitMQ Management UI Plugin to remove the
# UI elements responsible for managing passwords. 

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[ "$RABBIT_VERSION" == "" ] && RABBIT_VERSION=3.3.4
pushd /usr/lib/rabbitmq/lib/rabbitmq_server-$RABBIT_VERSION/plugins
unzip rabbitmq_management-$RABBIT_VERSION.ez
cp -f $DIR/*.ejs ./rabbitmq_management-$RABBIT_VERSION/priv/www/js/tmpl
mv -f ./rabbitmq_management-$RABBIT_VERSION.ez ./rabbitmq_management-$RABBIT_VERSION.ez.bak
zip -r -m rabbitmq_management-$RABBIT_VERSION.ez rabbitmq_management-$RABBIT_VERSION
popd
