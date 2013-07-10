rabbitmq-auth-backend-keystone
==============================

#Overview
This plugin provides the ability for the RabbitMQ broker to perform authentication (determining who can log in) using the OpenStack Keystone identity service (specifically HP's variant thereof, http://docs.hpcloud.com/identity/). Authorization (determining what permissions users have) is still managed by the internal RabbitMQ authorization mechanism (this may change in future) and so users still need to be defined in the internal database; it is currently only authentication that uses Keystone.
This provides a simple mechanism for OpenStack cloud tenants using RabbitMQ to provide other tenants with access to their RabbitMQ servers using a common authentication mechanism.
The plugin is essentially just a simple modification of the default auth module.

#Installation
To install from source:

    git clone https://github.com/brc859844/rabbitmq-auth-backend-keystone
    cd rabbitmq-auth-backend-keystone
    make deps
    make
    make package
    cp dist/*.ez $RABBITMQ_HOME/plugins
    
To enable the plugin, set the value of the `auth_backends` configuration item for the rabbit application (in `rabbitmq.config`) to include `rabbit_auth_backend_keystone`. 

The configuration item auth_backends is a list of authentication providers to try in order. A configuration fragment that enables the Keystone plugin only would be:

    [{rabbit, [{auth_backends, [rabbit_auth_backend_keystone]}]}].
    
The following entry instructs RabbitMQ to use both the Keystone and the internal authentication providers, such that if a user cannot be authenticated via the Keystone plugin, then the internal provider will be tried.

    [{rabbit,
       [{auth_backends, [rabbit_auth_backend_http, rabbit_auth_backend_internal]}]
    }].
    
Additionally, it is necessary to configure the plugin to know which URL to use for Keystone authentication. This may be done by adding the `rabbitmq_auth_backend_keystone` application to `rabbitmq.config` and setting the value of the configuration item `user_path` to the necessary URL, as illustrated below:

    [
       {rabbit, [{auth_backends, [rabbit_auth_backend_keystone]}]},
       {rabbitmq_auth_backend_keystone,
           [{user_path, "https://region-b.geo-1.identity.hpcloudsvc.com:35357/v2.0/tokens"}]}
    ].
    
Alternatively, the value for the URL may be specified in the plugins `rabbitmq_auth_backend_http.app` file (note that any value specified in `rabbitmq.config` as illustrated above will override any value specified in `rabbitmq_auth_backend_http.app`).

Lastly it is necessary to activate the Keystone plugin in the usual fashion:

    rabbitmq-plugins enable rabbitmq_auth_backend_keystone
    
The broker must then be restarted to pick up the new configuration. If things do not seem to be working correctly, check the RabbitMQ logs for messages containing "rabbit_auth_backend_keystone failed" or similar such text.

#Versions
The latest tagged version of the code works with (has been tested with) RabbitMQ 3.1.0 and Erlang 16B. The plugin should work with later versions of RabbitMQ and other reasonably recent versions of Erlang. Testing was done using HP Cloud (http://www.hpcloud.com); some tweaks might be required for other OpenStack deployments.

