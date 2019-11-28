# Refer to https://github.com/open5gs/open5gs/blob/master/docker/webui/Dockerfile
FROM node:carbon

MAINTAINER steven30801@gmail.com

ARG REPO=free5gc-stage-1

RUN cd /usr/src; \
    git clone https://bitbucket.org/nctu_5g/$REPO.git;

WORKDIR /usr/src/$REPO/webui
RUN npm install

CMD npm run dev

EXPOSE 3000
