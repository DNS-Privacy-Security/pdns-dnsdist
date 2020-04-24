FROM debian:stretch-slim

LABEL maintainer='M4t7e'

SHELL ["/bin/bash", "-c"]

ARG VERSION_TAG

RUN apt-get update \
 && apt-get install -y gnupg

COPY config/. /etc/

RUN VERSION_NUMBER=$(expr match "${VERSION_TAG}" '\([0-9]\+\.[0-9]\+\)') \
 && echo -n "deb [arch=amd64] http://repo.powerdns.com/debian stretch-dnsdist-${VERSION_NUMBER//.} main" \
 > /etc/apt/sources.list.d/pdns.list

ADD https://repo.powerdns.com/FD380FBB-pub.asc /tmp/pdns-pub.asc
RUN apt-key add /tmp/pdns-pub.asc \
 && rm /tmp/pdns-pub.asc

RUN apt-get update \
 && apt-get install -y dnsdist=${VERSION_TAG}\* \
 && apt-get install -y dnsutils

RUN rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash pdns

COPY entrypoint/. /entrypoint/
WORKDIR /entrypoint

EXPOSE 53

ENTRYPOINT [ "./entrypoint-cmd.sh" ]