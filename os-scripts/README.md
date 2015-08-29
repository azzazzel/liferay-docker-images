# Liferay Docker Scripts

An attempt to provide some scripts that make it easier to work with [Liferay] [Docker] images.

## What is there and why we need scripts
  
There is currently only one script: `liferayctl` which can be used on Linux and OS X! 

**Pull request about other scripts and support for other operating systems are more than welcome!!** 

For people comfortable with working with Docker directly, such scripts may not bring a lot of value. 
However for those that don't care much about Docker itself but rather want to have a quick, simple and convenient way
to run particular [Liferay] version - it should come very handy.

## Example worth a thousand words ;)

Lets try it out. Make sure you have [Docker] installed. If you are running OS X, make sure you are in `boot2docker` terminal window.
Then type:

```bash
curl -LO http://tiny.cc/liferayctl && chmod +x liferayctl
./liferayctl start
```

This will:

 - download the `liferayctl` script and make it executable
 - download the Docker image of the latest stable Liferay version (6.2ga4 at the time of writing) 
 - create a container from that image and run it 
 - make container's HTTP and AJP ports to you host 

Since this is the first time you run the command it needs to download the container image so it will take some time. 
Once it's ready go to `localhost:8080` 

Like that? Cool, Lets have another one: 

```bash
liferayctl -v latest -p 8180 -a 8108 start
```

this will run the the latest released version of Liferay (7.0m7 at the time of writing) in another Docker container (it will also take a while to download the new image).
Here apart form `-v latest` which specifies the latest released version, we also have `-p 8180 -a 8108` to specify different HTTP and AJP ports to avoid conflicts with the container we started earlier. Time to go to `localhost:8180` and enjoy Liferay 7 ;) 

Once we are done playing with them, we can stop them:

```bash
liferayctl stop
liferayctl -v latest stop
```

This will stop and remove both containers. New ones can be created and started at any time though with `liferayctl <OPTIONS> start`. 
The data is persisted in a data volume container(s), so destroying and recreating containers does not cause any data loss.


[Docker]: http://www.docker.com/
[Liferay]: http://www.liferay.com/
