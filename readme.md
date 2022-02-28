# Plumber/Docker demo

This repo is a demo of building a simple API in R, using Plumber, and 
Dockerising it to facilitate deployment. Some accompanying slides are 
here https://mawds.github.io/r-plumber-demo/

These are built from `doc/index.Rmd` - following the instructions at https://github.com/tgerke/rmd-with-ci

## API deployment notes:

Written using plumber

## Building

Run the modellling.R script - this will build a simple model, and save the
objects required for the API in `./diamondpredict`

To dockerise assuming you don't need a proxy for http access:

Installed docker using: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04

Change into `diamondpredict` directory

Build docker container with:

```
docker build -t diamondpredict .
```

## Deployment

To move to another machine:

`docker save diamondpredict:latest |bzip2 > diamondpredict.tar.bz2`

Move tar.bz2 file, docker-compose.yml and nginx.conf to target machine


(Ideally you'd use a Docker Hub or a private Docker Registry, but this is easier)

Load with:

`docker load -i diamondpredict.tar.bz2`

Deploy using docker-compose:

Create a `.htpasswd` file; in same directory as `docker-compose.yml`:

```
htpasswd -c .htpasswd username
```

(On Ubuntu systems `htpasswd` is in apache2-utils package - `apt install apache2-utils`)    

(default is user/forever)

`docker-compose up -d` 

(omit -d to keep attached to console for, e.g. debug)

(Note if you forget to make the .htpasswd file, Docker will create a .htpassword _directory_, which 
you'll need to remove before retrying.  Also, if using WSL2, see this bug report:
https://github.com/docker/for-win/issues/9823 since you may need to remove an additional directory
)

Endpoint is: http://hostname/diamondpredict/predict
Swagger docs at: http://hostname/diamondpredict/__docs__/

(the trailing `/` for `__docs__/` is required)

Note - will need to set up https once hosting options decided on.
See, e.g. https://pentacent.medium.com/nginx-and-lets-encrypt-with-docker-in-less-than-5-minutes-b4b8a60d3a71

