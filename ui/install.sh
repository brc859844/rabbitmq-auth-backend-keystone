#!/bin/bash -v

# This script augments RabbitMQ Management UI Plugin to remove the
# UI elements responsible for managing passwords. 

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RABBITMQ_VERSION=`find /usr/lib/rabbitmq/lib -name plugins -print | head -n1 | grep -o '[0-9]\.[0-9]\.[0-9]'`
pushd /usr/lib/rabbitmq/lib/rabbitmq_server-$RABBITMQ_VERSION/plugins
cp rabbitmq_management-$RABBITMQ_VERSION.ez rabbitmq_management-$RABBITMQ_VERSION.ez.original
unzip rabbitmq_management-$RABBITMQ_VERSION.ez
cp -f $DIR/*.ejs ./rabbitmq_management-$RABBITMQ_VERSION/priv/www/js/tmpl
mv -f ./rabbitmq_management-$RABBITMQ_VERSION.ez ./rabbitmq_management-$RABBITMQ_VERSION.ez.bak
zip -r -m rabbitmq_management-$RABBITMQ_VERSION.ez.cue rabbitmq_management-$RABBITMQ_VERSION
#
# Now let's tidy up after ourselves...
rm -rf ./rabbitmq_management-$RABBITMQ_VERSION
popd
