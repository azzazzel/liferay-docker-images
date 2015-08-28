#! /bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# --------------------
#  Make sure we are colled correctly and the environment is set up 
# --------------------

if [ -z "$1" ] ; then 
	echo "Please provide Liferay version !"
	exit 1 
fi 

LIFERAY_VERSION=$1
ENV_FILE="$DIR/env-$LIFERAY_VERSION"


if ! [ -f "${ENV_FILE}" ]; then 
	echo "No environment file exists for version '$LIFERAY_VERSION'!"
	echo "Please provide environment details in '$ENV_FILE'!"
	exit 1 
fi 

. $ENV_FILE

# --------------------
#  Make sure we have a Java release to use 
# --------------------

cd java-releases

if $USE_CHECKSUMS && ! [ -f "${JAVA_ARCHIVE_NAME}.md5" ]; then 
	echo "No Java realease checksum found in 'java-releases/${JAVA_ARCHIVE_NAME}.md5'! Please add one first!"
	exit 1 
fi 

DOWNLOAD_JAVA=true
if [ -f "$JAVA_ARCHIVE_NAME" ]; then
	echo "Java realease found in '${JAVA_ARCHIVE_PATH}'"
	if $USE_CHECKSUMS ; then
		if md5sum --status -c "${JAVA_ARCHIVE_NAME}.md5" ; then
			echo "Checksum OK! Will use '${JAVA_ARCHIVE_PATH}' instead of downloading one!"
			DOWNLOAD_JAVA=false
		else
			echo "Checksum failed! Need to download new archive!"
			mv ${JAVA_ARCHIVE_NAME} "${JAVA_ARCHIVE_NAME}.backup-`date +%s`"
		fi
	else
		echo "Checksum ignored! Will use '${JAVA_ARCHIVE_PATH}' instead of downloading one!"
		DOWNLOAD_JAVA=false
	fi;
else 
	echo "No Java realease found! Need to download one!"
fi

if [ "$DOWNLOAD_JAVA" = true ] ; then
	curl -OjkSLH "Cookie: oraclelicense=accept-securebackup-cookie" ${JAVA_DOWNLOAD_URL}
fi

# --------------------
#  Make sure we have a Liferay release to use 
# --------------------

cd ../liferay-releases

if $USE_CHECKSUMS && ! [ -f "liferay-portal-${LIFERAY_VERSION}.zip.md5" ]; then 
	echo "No Liferay realease checksum found in 'liferay-releases/liferay-portal-${LIFERAY_VERSION}.zip.md5'! Please add one first!"
	exit 1 
fi 

DOWNLOAD_LIFERAY=true
if [ -f "${LIFERAY_ARCHIVE_NAME}" ]; then
	echo "Liferay realease found in '${LIFERAY_ARCHIVE_PATH}'"
	if $USE_CHECKSUMS ; then
		if md5sum --status -c "${LIFERAY_ARCHIVE_NAME}.md5" ; then
			echo "Checksum OK! Will use '${LIFERAY_ARCHIVE_PATH}' instead of downloading one!"
			DOWNLOAD_LIFERAY=false
		else
			echo "Checksum failed! Need to download new archive!"
			mv ${LIFERAY_ARCHIVE_NAME} "${LIFERAY_ARCHIVE_NAME}.backup-`date +%s`"
		fi
	else
		echo "Checksum ignored! Will use '${LIFERAY_ARCHIVE_PATH}' instead of downloading one!"
		DOWNLOAD_LIFERAY=false
	fi	
else 
	echo "No Liferay realease found! Need to download one!"
fi

if [ "$DOWNLOAD_LIFERAY" = true ] ; then
	curl -o ${LIFERAY_ARCHIVE_NAME} -jkSL ${LIFERAY_DOWNLOAD_URL}
fi

# --------------------
#  Run Packer to provision the image 
# --------------------

cd ..

echo "Runnig packer to create the base docker image using:"
echo " - Java --> ${JAVA_ARCHIVE_PATH}" 
echo " - Liferay --> ${LIFERAY_ARCHIVE_PATH}" 

utils/pack.sh build \
	-var "java_archive=${JAVA_ARCHIVE_PATH}" \
	-var "liferay_archive=${LIFERAY_ARCHIVE_PATH}" \
	-var "liferay_version=${LIFERAY_VERSION}" \
	-var "container_repository=${CONTAINER_REPO}" \
	liferay-packer.json

# --------------------
#  Run Docker to add the things Packer can not do   
# --------------------

echo "Finally calling docker to add CMD and some ENV variables" 

TMPDIR="/tmp/docker-build-`date +%s`"
mkdir -p $TMPDIR
cp Dockerfile.template $TMPDIR/Dockerfile
sed -i  "s|__CONTAINER_REPO__|${CONTAINER_REPO}|" "/$TMPDIR/Dockerfile"
sed -i  "s|__LIFERAY_VERSION__|${LIFERAY_VERSION}|" "/$TMPDIR/Dockerfile"
docker build -t ${CONTAINER_REPO}:${LIFERAY_VERSION} $TMPDIR/.
rm -rf $TMPDIR
