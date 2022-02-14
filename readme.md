# API deployment notes:


Written using plumber

## Building

To dockerise assuming you don't need a proxy for http access:

Installed docker using: https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04

Change into `callpredict` directory

Build docker container with:

```
docker build -t diamondpredict .
```

Go to the "deployment" section of this document


## University of Manchester virtual machines

UoM virtual machine doesn't have direct web access, so we need to set up 
the proxy environment variables - did this using method 2, here:
https://www.thegeekdiary.com/how-to-configure-docker-to-use-proxy/

So `/etc/systemd/system/docker.service.d/http-proxy.conf` contains:

```
[Service]
Environment="HTTP_PROXY=http://webproxy.its.manchester.ac.uk:3128/"
Environment="HTTPS_PROXY=http://webproxy.its.manchester.ac.uk:3128/
```

(Note - HTTPS_PROXY is http:// too - *not* https://)

Build docker container with:

```
docker build --build-arg http_proxy=http://webproxy.its.manchester.ac.uk:3128/ --build-arg https_proxy=http://webproxy.its.manchester.ac.uk:3128/  -t diamondpredict .
```


## Deployment

To move to another machine:

`docker save diamondpredict:latest |bzip2 > diamondpredict.tar.bz2`

Move tar.bz2 file, docker-compose.yml and nginx.conf to target machine

Load with:

`docker load -i diamondpredict.tar.bz2`

Deploy using docker-compose:

Create a `.htpasswd` file; in same directory as `docker-compose.yml`:

```
htpasswd -c .htpasswd username
```
(On Ubuntu systems `htppasswd` is in apache2-utils package - `apt install apache2-utils`)    

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

