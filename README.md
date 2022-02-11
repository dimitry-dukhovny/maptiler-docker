# maptiler-docker
Docker-compose YML and systemd unit file for tileserver-gl instance

The tilesever-gl code is in https://github.com/maptiler/tileserver-gl/ and is worth understanding.

* Get a certificate from Letsencrypt
* Into */usr/lib/systemd/system* put...
  * *docker-maptiler.service*
  * *stunnel.service*
* Into */etc/stunnel* put *stunnel.conf*
* Uninstall...
  * Any non-CE docker
* Install...
  * stunnel
  * docker-ce
  * docker-compose
* Make a */data/map/bin* directory and put *docker-compose.yml* in it.
* Into */data/map* download data, such as *maptiler-osm-2017-07-03-v3.6.1-planet.mbtiles*
* Enable your unit files
`systemd enable stunnel docker-maptiler`
* Start your unit files
`systemd start stunnel docker-maptiler`
