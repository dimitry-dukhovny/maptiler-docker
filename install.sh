#!/bin/bash
mydir=`dirname ${0}`
source /etc/os-release

nope() {
  echo -n "Nope:  "
  echo ${@}
  exit 255
}

DOCKER=`which docker 2> /dev/null`
DOCKER=${DOCKER:-NONE}
DOCKERCOMPOSE=`which docker-compose 2> /dev/null`
DOCKERCOMPOSE=${DOCKERCOMPOSE:-NONE}
STUNNEL=`which stunnel 2> /dev/null`
STUNNEL=${STUNNEL:-NONE}
[ "${DOCKER}" = "NONE" -o "${DOCKERCOMPOSE}" = "NONE" ] && nope "Install docker and docker-compose before resuming."
[ "${STUNNEL}" = "NONE" ] && nope "Install stunnel before resuming."

groupadd docker 2> /dev/null
getent group docker > /dev/null 2>&1 || nope "Could not create the docker group.  Are you root?"
useradd -d /home/svc.map -m -s /bin/bash -G docker svc.map 2> /dev/null
getent passwd svc.map > /dev/null 2>&1 || nope "Could not create the svc.map user.  Are you root?"

# Where our stuff goes
mkdir -m 775 -p /data/map/bin

# Docker prep
cp -f ${mydir}/docker-compose.yml /data/map/bin/
cp -f ${mydir}/docker-maptiler.service /usr/lib/systemd/system/

# Stunnel prep; stupidly assumes your first cert entry is your default
assumedcert=`/bin/ls /etc/letsencrypt/live | head -1`
[ ! -d /etc/letsencrypt/live/default ] && ln -s ${assumedcert} /etc/letsencrypt/live/default
cp -f ${mydir}/stunnel.service /usr/lib/systemd/system/
[ -f /etc/stunnel/stunnel.conf ] && mv /etc/stunnel/stunnel.conf /etc/stunnel/stunnel.conf.`date +%s`
cp -f ${mydir}/stunnel.conf /etc/stunnel/

# Selinux context
chcon -u system_u -r object_r -t system_unit_file_t /usr/lib/systemd/system/docker-maptiler.service /usr/lib/systemd/system/stunnel.service 2> /dev/null
# Ownership
chown -R svc.map:docker /data/map || nope "Failed to change ownership of /data/map!  Not continuing!"

# Startup
systemctl daemon-reload
systemctl enable stunnel docker-maptiler
systemctl start stunnel docker-maptiler

echo "Download maps to /data/map and adjust /data/map/bin/docker-compose.yml accordingly"
