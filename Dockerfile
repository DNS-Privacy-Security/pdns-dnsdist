FROM debian:stretch-slim

LABEL maintainer='M4t7e'

SHELL ["/bin/bash", "-c"]

ARG VERSION_TAG

RUN apt-get update \
 && apt-get install -y gnupg \
 && apt-get install -y dnsutils

COPY config/. /etc/

ADD https://repo.powerdns.com/FD380FBB-pub.asc /tmp/pdns-pub.asc
RUN apt-key add /tmp/pdns-pub.asc \
 && rm /tmp/pdns-pub.asc

RUN DNSDIST_VERSION=$([[ "${SOURCE_BRANCH//.}" =~ ^[0-9]+$ ]] && echo "${SOURCE_BRANCH}" || echo "${VERSION_TAG}") \
 && RELEASE_VERSION=$(expr match "${DNSDIST_VERSION}" '\([0-9]\+\.[0-9]\+\)') \
 && echo -n "deb [arch=amd64] http://repo.powerdns.com/debian stretch-dnsdist-${RELEASE_VERSION//.} main" > /etc/apt/sources.list.d/pdns.list \
 && apt-get update \
 && apt-get install -y dnsdist=${DNSDIST_VERSION}\*

RUN rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash pdns

COPY entrypoint/. /entrypoint/
WORKDIR /entrypoint

EXPOSE 53

ENTRYPOINT [ "./entrypoint-cmd.sh" ]