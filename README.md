# Gibbon in Docker 
## What this setup does
The Dockerfiles in php and webserver create minimal images with apache, configured for php-fpm, and php-fpm to enable gibbon to run.

docker-compose.yml assumes there is an additional reverse proxy - in this case [jwilder/nginx-proxy](https://hub.docker.com/r/jwilder/nginx-proxy), either running in one container or running nginx and docker-gen separated, on the network "webfront".
It further assumes there is an external network "backup" for accessing the database to create backups i.e. with [Bareos in Docker](https://github.com/barcus/bareos).

If you migrate your database put your databasedump in ./db/initdb/ before the first time you run docker-compose up -d. Adjustments to the database, like migration to another URL have to be done by you either in advance in the dump or via SQL using the mysql client.


## What you have to do
### Basic Setup
If you want to run gibbon without a separate reverse proxy you can use
docker-compose.simple.yml:

1. Clone the repo
2. rename docker-compose.simple.yml to docker-compose.yml
3. copy example.env to .env
4. change the values in .env to match your domain, and LOCALE and passwords
5. run `bash ./crontab\_create.sh`
6. run `docker-compose pull`
7. run `docker-compose build`
8. run `docker-compose up -d`
9. visit your server the way you set it up either via a domain name or via ip:80 and start the Gibbon setup


### Setup with reverse Proxy and TLS
1. Clone the repo
2. run `docker network create webfront`
3. run `docker network create backup`
4. setup jwilder/nginx-proxy in a separate docker-compose project. If you plan on using it in production add [letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) to your nginx-proxy setup
5. add the network webfront to nginx-proxy
6. copy example.env to .env
7. change the values in .env to match your domain, and LOCALE and passwords
8. run `bash ./crontab\_create.sh`
9. run `docker-compose pull`
10. run `docker-compose build`
11. run `docker-compose up -d`
12. visit your server the way you set it up either via its domain name

## Backupstrategy
As mentioned above a separate backup network is created for using backup software like Bareos to backup the database.
The volume where your gibbon data resides should also be backed up. Since I use a docker volume I tend to mount it in a bareos filedaemon container and use bareos.

Another option would be to use a directory on your host to mount into $GIBBON\_BASEDIR and any backup mechanism for your docker host system.
Backupscripts, and scripts for backup rotation are also added to the database container and executed by the crontab container. So you find your databasebackups under ./db/backup.

Therefore you should be fine using tar, rsync, borg or any other tool on those two directories.

