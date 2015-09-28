#! /bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# --------------------
#  Make sure we are called correctly
# --------------------

if [ -z "$1" ] ; then 
	echo "Please provide Liferay version !"
	exit 1 
fi 

LIFERAY_VERSION=$1
CONTAINER_REPO="azzazzel/liferay-cloud"

# --------------------
#  Run Packer to provision the image 
# --------------------

echo "Runnig packer to create Liferay in cloud docker image :"


../utils/pack.sh build \
	-var "liferay_version=${LIFERAY_VERSION}" \
	-var "container_repository=${CONTAINER_REPO}" \
	liferay-packer.json

