rabbitmq-auth-backend-keystone
==============================

#Overview
This plugin provides the ability for the RabbitMQ broker to perform authentication (determining who can log in) using the OpenStack Keystone identity service. Authorization (determining what permissions users have) is currently still managed by the internal RabbitMQ authorization mechanism and so users still need to be defined in the internal database; it is currently only authentication that uses Keystone. This provides a simple mechanism for OpenStack cloud tenants using RabbitMQ to provide other tenants with access to their RabbitMQ servers using a common authentication mechanism. The plugin is essentially just a simple modification of the default auth module.

The current version of the plugin uses the Keystone V3 API and is not compatible with earlier versions of the Keystone API. It shoudl be noted that the V3 API requires users to either specify a domain ID in addition to a username and password when authenticating or for there to be a default domain defined in Keystone for the athenticating user. If no default domain ID is defined, users must specify a domain ID when connecting to RabbitMQ by concatinating it with the username according to the syntax `domain-id\username`. If no default domain is defined in Keystone for the user and no domain ID is specified when logging in, an error will be returned by Keystone and the user will not be authenticated.

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
    
The following entry instructs RabbitMQ to use both the Keystone and the internal authentication providers, such that if a user cannot be authenticated via the Keystone plugin, then the internal provider will be tried (this is probably a good way to have things set up initially, until you are happy that the plugin is working as expected).

    [{rabbit,
       [{auth_backends, [rabbit_auth_backend_keystone, rabbit_auth_backend_internal]}]
    }].
    
Additionally, it is necessary to configure the plugin to know which URL to use for Keystone authentication. This may be done by adding the `rabbitmq_auth_backend_keystone` application to `rabbitmq.config` and setting the value of the configuration item `user_path` to the necessary URL, as illustrated below:

    [
       {rabbit, [{auth_backends, [rabbit_auth_backend_keystone,rabbit_auth_backend_internal]}]},
       {rabbitmq_auth_backend_keystone,
           [{user_path, "https://region-a.geo-1.identity.hpcloudsvc.com:35357/v3/auth/tokens"}]}
    ].
    
Alternatively, the value for the URL may be specified in the plugins `rabbitmq_auth_backend_http.app` file (note that any value specified in `rabbitmq.config` as illustrated above will override any value specified in `rabbitmq_auth_backend_http.app`).

Lastly it is necessary to activate the Keystone plugin in the usual fashion:

    rabbitmq-plugins enable rabbitmq_auth_backend_keystone
    
The broker must then be restarted to pick up the new configuration. If things do not seem to be working correctly, check the RabbitMQ logs for messages containing "rabbit_auth_backend_keystone failed" or similar such text. 

#Versions
The latest tagged version of the code works with (has been tested with) RabbitMQ 3.3.0 through 3.4.0 and Erlang 16B. The plugin should work with other versions of RabbitMQ and other reasonably recent versions of Erlang. Testing was done using HP Cloud (http://www.hpcloud.com); some tweaks might be required for other OpenStack deployments.

As noted previously, the current version of the plugin uses the Keystone V3 API and is not compatible with earlier versions of the Keystone API. 

#Changes to the management UI (optional)
The `ui` directory includes modified versions of Management UI web pages associated with login and username/password management that are intended to be more intuitive to the user when Keystone-based authentication is being used. The script `./ui/install.sh` can be used to replace the relevant files in the management plugin `.ez` with the modified versions prior to plugin activation.

#Usage notes
Once the plugin has been installed and configured, the administrator can define additional users and their permissions. This can be done via the command line using rabbitmqctl (assuming appropriate access to the host server) or via the RabbitMQ Management Web UI (or any other that uses the RabbitMQ Management REST API). Regardless of the approach, it is important to appreciate that the defined user names must exist in Keystone, and that any password specified when defining a new RabbitMQ user is meaningless, as users will be authenticated against Keystone using their existing Keystone username and password credentials. For this reason, provided with the plugin (see above) are a set of modified Management Web UI pages that do not require a password to be entered when setting up a new users, and the initial Web UI login page clearly indicates users should log into the UI using their Keystone credentials. In short, new RabbitMQ users should be defined as usual; however the specified usernames must exist in Keystone in order for the users to connect to RabbitMQ.   
