#! /bin/sh

# -------------------------
# copy confd executable
# -------------------------
mv /tmp/provision/confd/confd /usr/bin/confd
chmod +x /usr/bin/confd

# -------------------------
# copy confd configs and themplates
# -------------------------
mkdir -p /etc/confd/conf.d
mv /tmp/provision/confd/*.toml /etc/confd/conf.d/
mkdir -p /etc/confd/templates
mv /tmp/provision/confd/*.tmpl /etc/confd/templates/

# -------------------------
# copy main executable
# -------------------------
mv /tmp/provision/liferay /usr/bin/liferay
chmod +x /usr/bin/liferay

# -------------------------
# add some networking tools
# -------------------------
# apk add --update ngrep

# -------------------------
# clean up
# -------------------------
rm -rf 	\
	/tmp/* \
	/var/cache/apk/*
