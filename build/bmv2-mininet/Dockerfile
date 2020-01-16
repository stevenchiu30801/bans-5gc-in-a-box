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
        lsb-release \
        net-tools

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py --force-reinstall

RUN git clone -b 2.3.0d3 https://github.com/mininet/mininet.git

RUN ./mininet/util/install.sh -n

COPY install-p4-tools.sh .

RUN pip install --upgrade pip

RUN chmod 777 ./install-p4-tools.sh && \
    ./install-p4-tools.sh

COPY bmv2.py .

RUN sed -i "s/@alias(\"intrinsic_metadata.egress_rid\")    bit<16> egress_rid;/@alias(\"intrinsic_metadata.egress_rid\")    bit<16> egress_rid;\n    @alias(\"intrinsic_metadata.priority\")      bit<3> priority;/g" /usr/local/share/p4c/p4include/v1model.p4

EXPOSE 50001-50999

CMD ["ONOS_WEB_USER=onos" "ONOS_WEB_PASS=rocks" "mn" "--custom" "bmv2.py" "--switch" "onosbmv2" "--controller" "remote"]
