FROM ubuntu:16.04

MAINTAINER steven30801@gmail.com

USER root
WORKDIR /root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        python \
        curl \
        sudo \
        python-setuptools \
        lsb-release

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py --force-reinstall

RUN git clone -b 2.3.0d3 https://github.com/mininet/mininet.git

RUN ./mininet/util/install.sh -n

COPY install-p4-tools.sh .

RUN pip install --upgrade pip

RUN chmod 777 ./install-p4-tools.sh && \
    ./install-p4-tools.sh
