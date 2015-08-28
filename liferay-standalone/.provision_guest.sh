#! /bin/sh


# Install glibc 
apk add --update openssl
wget -O glibc-2.21-r2.apk https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk
apk add --allow-untrusted glibc-2.21-r2.apk
wget -O glibc-bin-2.21-r2.apk https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk
apk add --allow-untrusted glibc-bin-2.21-r2.apk
/usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib
echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf


# Install Java 
tar -xz -C /tmp -f /tmp/java.zip
rm /tmp/java.zip
mkdir -p /opt/java
mv /tmp/`ls -1 /tmp | grep '^jdk'`/* /opt/java


# Install Liferay 
unzip -q /tmp/liferay-portal.zip -d /tmp
rm /tmp/liferay-portal.zip
mkdir -p /opt/liferay
mv /tmp/`ls -1 /tmp | grep 'liferay-portal'`/* /opt/liferay
mkdir -p /var/lib/liferay
mv /opt/liferay/data /var/lib/liferay/data
mv /opt/liferay/osgi /var/lib/liferay/osgi
echo "liferay.home=/var/lib/liferay" > /opt/liferay/portal-bundle.properties
echo "setup.wizard.enabled=false" >> /opt/liferay/portal-bundle.properties


# Make Liferay main executable
TOMCAT_DIR=`ls -1 /opt/liferay | grep tomcat-`
echo "#!/bin/ash" > /usr/bin/liferay
echo "/opt/liferay/${TOMCAT_DIR}/bin/catalina.sh run" >> /usr/bin/liferay
chmod +x /usr/bin/liferay


# Clean up OS
rm -rf /tmp/* \
		/var/cache/apk/*


# Clean up Java
rm -rf /opt/java/*src.zip \
    	/opt/java/lib/missioncontrol/ \
        /opt/java/lib/visualvm/ \
        /opt/java/lib/*javafx*  \
        /opt/java/jre/lib/plugin.jar  \
        /opt/java/jre/lib/ext/jfxrt.jar  \
        /opt/java/jre/bin/javaws/  \
        /opt/java/jre/lib/javaws.jar  \
        /opt/java/jre/lib/desktop/  \
        /opt/java/jre/plugin/  \
        /opt/java/jre/lib/deploy*  \
        /opt/java/jre/lib/*javafx*  \
        /opt/java/jre/lib/*jfx*  \
        /opt/java/jre/lib/amd64/libdecora_sse.so \
        /opt/java/jre/lib/amd64/libprism_*.so  \
        /opt/java/jre/lib/amd64/libfxplugins.so  \
        /opt/java/jre/lib/amd64/libglass.so  \
        /opt/java/jre/lib/amd64/libgstreamer-lite.so  \
        /opt/java/jre/lib/amd64/libjavafx*.so  \
        /opt/java/jre/lib/amd64/libjfx*.so \
        /opt/java/man \
        /opt/java/db \


# Clean up Liferay
rm -rf /opt/liferay/${TOMCAT_DIR}/temp/* \
		/opt/liferay/${TOMCAT_DIR}/work/* \
		/var/lib/liferay/osgi/apps/*.test.jar
