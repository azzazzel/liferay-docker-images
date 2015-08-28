# Liferay Docker Images

This tool can create a Docker image from any released version of Liferay.

If you only want to try it out without getting to know the details, feel free to follow the instructions in [TL;DR] section at your own risk ;) 

## How it works

### The main script

 The main script is `build.sh <VERSION>`. It expects one mandatory argument - the Liferay version. The version is any string and will be used for:

 - finding the environment file with detailed instructions
 - tagging the final Docker image

### The environment file

 The script will look for environment file in the same folder called `env-<VERSION>`. The only purpose of this file is to set some environment variables that are later on used by the script. Here is how it looks like:

```sh
#!/bin/sh

USE_CHECKSUMS=true

JAVA_PACKAGE=jdk
JAVA_VERSION_MAJOR=7
JAVA_VERSION_MINOR=80
JAVA_VERSION_BUILD=15
JAVA_ARCHIVE_NAME="${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz"
JAVA_ARCHIVE_PATH="java-releases/${JAVA_ARCHIVE_NAME}"
JAVA_DOWNLOAD_URL="http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_ARCHIVE_NAME}"

LIFERAY_ARCHIVE_NAME="liferay-portal-${LIFERAY_VERSION}.zip"
LIFERAY_ARCHIVE_PATH="liferay-releases/${LIFERAY_ARCHIVE_NAME}"
LIFERAY_DOWNLOAD_URL="http://tinyurl.com/liferay-portal-`echo ${LIFERAY_VERSION} | tr '.' '-'`"

CONTAINER_REPO="azzazzel/liferay-standalone" 
```

The environment file allows to define:

  - should the script use MD5 checksums to validate the archives. Please note it this is set to `true` and there is local file and checksum does not match it will be overwritten with downloaded one.
  - what JAVA version should be installed and from where (can be local archive or downloaded)
  - what Liferay version (Tomcat bundle) should be installed and from where (can be local archive or downloaded)
  - what would be the name of your image 

### Downloading archives vs local archives
 
 The decision logic regarding should an archive be downloaded or a local one should be used is presented in the following table: 

| USE_CHECKSUMS  | ZIP present | MD5 present | MD5 matches | Result                  |
| -------------- | ----------- | ----------- | ----------- | ----------------------- |
| no             | no          | no          | -           | File will be downloaded |
| no             | no          | yes         | -           | File will be downloaded |
| no             | yes         | no          | -           | Local file will be used |
| no             | yes         | yes         | -           | Local file will be used |
| yes            | no          | no          | -           | Error                   |
| yes            | no          | yes         | -           | File will be downloaded |
| yes            | yes         | no          | -           | Error                   |
| yes            | yes         | yes         | no          | File will be downloaded |
| yes            | yes         | yes         | yes         | Local file will be used |

Please note: 
 - if checksums are disabled and given archive is broken the script will never now and attempt to use it with every next build.
 - if checksums are enabled the first time archive is downloaded it will be used. Next attempts will fail unless correct MD5 checksum is provided.

### Packer

After making sure all the required artifacts are in place, the script will call [Packer] to actually build the image. The reason we use [Packer] and not standard `Dockerfile` is to reduce the amount layering (and thus overall file size) as well as allow for more flexible provisioning in the future. Packer will 

  - start a container from [Alpine linux image] (probably the smallest one that can run Java).
  - copy the Java archive into the image 
  - copy the Liferay archive into the image 
  - copy `.provision_guest.sh` into the image and execute it.
  - commit the image to the local Docker repository
  - tag the image as `CONTAINER_REPO`:`VERSION`

### Docker

Once Packer is done the image will be already in the local Docker's repository. The script will then:
 
  - create a temporary context
  - process `Dockerfile.template` and save it there as `Dockerfile`
  - call `docker build` with the temporary context

This will add things like `CMD`, `ENV`, `EXPOSE`, ... that [Packer] can not do. While this will unfortunately introduce few more layers, it does not infuence the size if the image.


## TL;DR

  * make sure you have both [Docker] and [Packer] installed !
  * clone this repository 
  * create `env-<VERSION>` file for the version of Liferay you want to build container image for (have a look the provided ones to see what it contains)
  * create `liferay-releases/liferay-portal-<VERSION>.zip.md5` file containing the MD5 checksum of the archive. Alternatively set `USE_CHECKSUMS=false` in your `env-<VERSION>` file
  * if you already have the Liferay Tomcat bundle zip downloaded, copy or symlink it to `liferay-releases/liferay-portal-<VERSION>.zip.` If you don't it will be downloaded from the URL specifies in `env-<VERSION>` file
  * run `./build.sh <VERSION>`



[TL;DR]: #tldr
[Docker]: http://www.docker.com/
[Packer]: http://www.packer.io
[Alpine linux image]: https://hub.docker.com/_/alpine/
