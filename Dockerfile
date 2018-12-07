# Nanopype Dockerfile
# BUILD STAGE
FROM ubuntu:16.04 as build_stage

MAINTAINER Pay Giesselmann <giesselmann@molgen.mpg.de>

## system packages
RUN apt-get --yes update && apt-get install -y --no-install-recommends wget \
    git gcc g++ ca-certificates \
    binutils autoconf make cmake zlib1g-dev bzip2 libbz2-dev \
    liblzma-dev libncurses5-dev \
    python python3.5 python3.5-dev

RUN update-ca-certificates
## set up python 3
RUN ln -s /usr/bin/python3.5 /usr/bin/python3
RUN mkdir -p /src
WORKDIR /src
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py

# copy and configure nanopype
RUN mkdir -p /app
WORKDIR /app
COPY . /app/
RUN pip3 install . --upgrade

# run setup rules
RUN snakemake --snakefile rules/install.smk all

# PACKAGE STAGE
FROM ubuntu:16.04
RUN apt-get --yes update && \
apt-get install -y --no-install-recommends wget git gcc g++ \
	zlib1g-dev bzip2 libbz2-dev \
	liblzma-dev libncurses5-dev \
	ca-certificates \
	python python3.5 python3.5-dev

RUN update-ca-certificates
## set up python 3
RUN ln -s /usr/bin/python3.5 /usr/bin/python3
RUN mkdir -p /src
WORKDIR /src
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py

## copy binaries from build stage
RUN mkdir -p /app/bin
WORKDIR /app
COPY --from=build_stage /app/bin/* /app/bin/

## set up nanopye
# copy and configure nanopype
COPY . /app/

RUN pip3 install . --upgrade
RUN snakemake --snakefile rules/install.smk deepbinner
RUN pip3 install . --upgrade --install-option="--tools=$(pwd)/bin"

# create working directories
RUN mkdir -p /data/raw
RUN mkdir -p /data/import
RUN mkdir -p /data/processing
WORKDIR /data/processing
