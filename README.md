# mpeterson/php5_fpm
## Features
  * **Imports all docker links environmental variables to the php5-fpm main configuration. So they can be used from PHP scripts.**
  * Allow to override or add files to the image when building it.

## Usage
This example considers that you have a [data-only container](http://docs.docker.io/use/working_with_volumes/) and a DB container running and linked to an [ambassador](http://docs.docker.io/use/ambassador_pattern_linking/) however it's not needed for it to run correctly.

```bash
sudo docker run -d --volumes-from www_data --name php --link db_ambassador:db -p 127.0.0.1::22 mpeterson/php5_fpm
```

Since the idea is to use this linked with another container the PHP port (9000) is not exposed in the previous example.

*__Note:__ Notice that since the image is based on [phusion/baseimage-docker](https://github.com/phusion/baseimage-docker) it has a SSH service listening on 22 which in the example above is mapped so we can access the image in the case we wanted to.*

### Volumes
  * ```/data``` volume is where your sites should be contained. This path has a symlink as ```/var/www``` to respect standards. Can be overriden via environmental variables.

It is recommended to use the [data-only container](http://docs.docker.io/use/working_with_volumes/) pattern and if you choose to do so then the volumes that it needs to have is ```/data```.

### Override files
In the case that the user wants to add files or override them in the image it can be done stated on this section. This is particularly useful for example to add a cronjob or add certificates.

Since docker 0.10 removed the command ```docker insert``` the image needs to be built from source.

For this a folder ```overrides/``` inside the path ```image/``` can be created. All files from there will be copied to the root of the system. So, for example, putting the following file ```image/overrides/etc/ssl/certs/cloud.crt``` would result in that file being put on ```/etc/ssl/certs/cloud.crt``` on the final image.

After that just run ```sudo make``` and the image will be created.

### Docker links
The idea was to have a container that only contained php5-fpm and not a full stack to allow flexibility. Because of that there was a need to create a way to reference the links from within the php5-fpm configurations so that it was possible to reference the DB connections for example. A mechanism was put in place to expose all docker link environmental variables to the PHP scripts. They can later be accessed using for example, in the case of MySQL:

```php
getenv('MYSQL_PORT_3306_TCP_ADDR') . ':' . getenv('MYSQL_PORT_3306_TCP_PORT');
```

## Configuration
Configuration options are set by setting environment variables when running the image. This options should be passed to the container using docker
```-e <variable>```. What follows is a table of the supported variables:

Variable     | Function
------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------
DATA_DIR     | Allows to configure where the path that will hold the files. Bear in mind that since the Dockerfile has this hardcoded so it might be neccesary to build from source
