# Refer to https://github.com/open5gs/open5gs/blob/master/docker/build/Dockerfile
FROM steven30801/free5gc-base:latest

MAINTAINER steven30801@gmail.com

COPY setup.sh /root
RUN chmod 777 /root/setup.sh

ARG REPO=free5gc-stage-1

RUN cd /usr/src; \
    git clone https://bitbucket.org/nctu_5g/$REPO.git

WORKDIR /usr/src/$REPO

RUN ./support/freeDiameter/make_certs.sh ./support/freeDiameter

RUN autoreconf -iv && \
    ./configure --prefix=`pwd`/install && \
    make -j `nproc` && \
    make install
