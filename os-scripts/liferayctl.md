# liferayctl

This script is probably the easiest way to run a recent version of [Liferay] as standalone portal. It's meant to be used for local demo / testing / development / ... environment. **DO NOT** use this script to run a production environment unless you absolutely know what you are doing and are willing to take all the risks of exposing such basic setup to general public. 

This script is basically a wrapper around [Docker] and it needs [Docker] to be installed on the system it is run. It is cable of downloading Liferay Docker images, creating containers out of them and managing those. Here is the help screen:

```
usage: ./liferayctl options command

COMMANDS:
   start    Starts Liferay
   stop     Stop Liferay
   restart  Restart Liferay

OPTIONS:
   -v version   Specific Liferay version to run. Default is "stable" which is latest stable release. Use "./liferayctl -l to see available versions"
   -l           List Liferay versions available as docker containers
   -c name      The name of the container to be started. Default is 'liferay_[VERSION]_run' 
                Container will be created on start and destroyed on stop. Data is persisted in a separate data only cotainer (see -d flag).
   -d name      The name of the data container. Default is 'liferay_[VERSION]_data' or '[CONTAINER_NAME]_data' if container name is provided.
                Container will be created if it does not exists and never removed. Remove it manually if you are OK with loosing the data!
   -p port      The HTTP port. Default is 8080  
   -a port      The AJP port. Default is 8009  
   -n           Exit right after the container is started (do not wait for Liferay itself to start)  
   -f           Force removing exiting stopped container with the same name 
   -x           Debug mode. Logging command outputs to './.liferayctl.log'
   -h 	        Displays this help

``` 

One of the main reasons to create the script was to provide a tool that can be used by people who do NOT need to know in details how Docker works _(it may work with different containers in the future)_. However there are few important design decisions that you need to understand if you intend to use it for something more then just playing around with Liferay. 

## `Start` process 
 
This is what happens when the script is called with `start` command:

 * `liferayctl` will calculate the Docker image's tag to create a container(s) from. The image used is always `azzazzel/lferay-standalone` and the tag is the desired Liferay version. Unless a version is provided via `-v` flag it will use `stable`. So the following 2 commands will do the exact same thing:

	```
	 ./liferayctl start
	```

	```
	 ./liferayctl -v stable start
	```

	The `stable` tag refers to the latest stable version. At the time of writing the latest stable release is `6.2ga4`. At first it may seems that running 

	```
	 ./liferayctl -v 6.2ga4 start 
	```

	will also do the same thing as the commands above, but that is not exactly the case. While it will indeed run the same Liferay version, it will create/use different [data volume container]. 

 * `liferayctl` will check if the image with that tag is available locally and if not it will download it form [docker hub](https://hub.docker.com/r/azzazzel/liferay-standalone/).

 * `liferayctl` will check if a [data volume container] container for that version exists locally and if not it will try to create one. The [data volume container] is one that holds the data (HSQL, files, ...). It does not need to be started but needs to exists so the runtime container _(the one that actually runs Liferay)_ can use it to store it's data. The name of the [data volume container] can be provided with `-d` option. If it is not, it will be `liferay_[VERSION]_data` where `[VERSION]` is the provided or calculated Liferay version. This allows to persist data between containers. For example one can start Liferay _(`./liferayctl start`)_, change something _(add page/content, ...)_, stop it _(`./liferayctl stop`)_ and then start new one on different port _(`./liferayctl -p 8081 start`)_ without loosing changes. 

 * `liferayctl` will check that runtime container (one that starts and runs Liferay) with specified name doe not already exists and then create one. That is because it always create new one on `start` and then destroys it on `stop`. If at this point a container with specified name exists, `liferayctl` will report that and exit. If the container exists but it's stopped, `liferayctl` can automatically remove it if the `-f` option is provided. If the container does not exists (or was removed), `liferayctl` will create new one. The name of the runtime container can be provided with `-c` option. If it is not, it will be `liferay_[VERSION]_run` where `[VERSION]` is the provided or calculated Liferay version.

 * `liferayctl` will start the newly created runtime container. 

 * if running on OS X `liferayctl` will call `boot2docker` to create ssh tunnels between `boot2docker` and the host to forward the ports specified by `-p` ans `-a`. It currently uses the solution from [this issue](https://github.com/docker/docker/issues/4007). Please let me know if there is a better way to do it!

 * `liferayctl` will scan container logs and wait for a message indicating that Liferay has started. This behavior can be disabled with `-n` switch

## `Stop` process 

This is what happens when the script is called with `stop` command:

 * `liferayctl` will calculate version and runtime container name using the exact same logic described in the `start` process 
 * if running on OS X `liferayctl` will kill the ssh tunnels between `boot2docker` and the host
 * `liferayctl` will stop the container with given name
 * `liferayctl` will remove the container with given name

## `Restart` process 

`Restart` process is just a convenient shortcut for `./liferayctl stop; ./liferayctl start` 

## What Liferay versions are available 

The available container image tags are listed here: [https://hub.docker.com/r/azzazzel/liferay-standalone/tags/](https://hub.docker.com/r/azzazzel/liferay-standalone/tags/)

`liferayctl` will display the same names if called with `-l` option. 
 


[Docker]: http://www.docker.com/
[Liferay]: http://www.liferay.com/
[data volume container]: https://docs.docker.com/userguide/dockervolumes/ 
