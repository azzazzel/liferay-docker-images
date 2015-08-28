# Liferay Docker Scripts

An attempt to provide some scripts that make it easier to work with [Liferay] [Docker] images.

## What is there and why we need scripts
  
There is currently only one script: `liferayctl` which only works on Linux :(

**Pull request about other scripts and support for other operating systems are more than welcome!!** 

If you are very comfortable working with Docker you may argue those are needles. 
However for those that don't care much about Docker but rather want to have a quick, simple and convenient to run particular [Liferay] version, it should come handy.

## Example worth a thousand words ;)

Lets try it out:

```bash
wget -nc http://tiny.cc/liferayctl && chmod +x liferayctl
liferayctl start
```

This will:

 - download the `liferayctl` script and make it executable
 - run the the latest stable version of Liferay (6.2ga4 at the time of writing) in a Docker container. 

Since this the first time you run the command it needs to download the image so it will take some time

Cool, isn't it? Lets have another one: 

```bash
liferayctl -v latest -p 8180 -a 8108 start
```

which will run the the latest released version of Liferay (7.0m7 at the time of writing) in another Docker container (it will take while to download that image too).
Here apart form `-v latest` which tells we want the latest version we also have `-p 8180 -a 8108` to specify different HTTP and AJP ports to avoid conflicts with the container we started earlier.

Once we are done playing we can stop them:

```bash
liferayctl stop
liferayctl -v latest stop
```

Containers are gone but you can start new ones at any time. And guess what - your data is persisted in a data volume container so you can change the execution parameters without loosing any data.


[Docker]: http://www.docker.com/
[Liferay]: http://www.liferay.com/
