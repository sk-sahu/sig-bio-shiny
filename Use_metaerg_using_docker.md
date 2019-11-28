# Use metaerg using docker

I have set up everything you can directly do from [here]()

## Check Docker
In the first step check is a docker is installed in your system 
```
dokcer -v
```

if not install docker using this doc - https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04

## Get metaegr docker imager
Then as mentioned in the metaerg documentaiton [Running with docker](https://github.com/xiaoli-dong/metaerg#running-with-docker)
```
docker pull xiaolidong/docker-metaerg
```

## Set-up the required database
```
docker run --shm-size 2g --rm -u $(id -u):$(id -g) -it -v local_data:/data/ xiaolidong/docker-metaerg setup_db.pl -o /data -v 132
```
**Command Exaplanation:** The basic command `docker run --shm-size 2g --rm -u $(id -u):$(id -g) -it` used to run the tool using docker. `-v local_data:/data/` used to mount local_data dir to data dir in docker container.

## Run metaerg
```
docker run --shm-size 2g --rm -u $(id -u):$(id -g) -it -v my_local_dir:/data/ xiaolidong/docker-metaerg metaerg.pl --dbdir /data/db --outdir /data/my_metaerg_output /data/contig.fasta
```