FROM lsiobase/python:3.11

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs"
ENV PYTHONUNBUFFERED=1
ENV USER=abc

RUN \
 echo "**** install system packages ****" && \
 apk add --no-cache \
	git=2.24.1-r0 \
	nodejs=12.15.0-r1 \
    build-base=0.5-r1 \
    libffi-dev=3.2.1-r6 \
    zlib-dev=1.2.11-r3 \
    python3-dev \
    jpeg-dev=8-r6 && \
 echo "**** install Python ****" && \
 apk add --no-cache python3 && \
 if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
 echo "**** install app ****" && \
 if [ -z ${MYLAR_COMMIT+x} ]; then \
	MYLAR_COMMIT=$(curl -sX GET https://api.github.com/repos/mylar3/mylar3/commits/python3-dev \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 git clone https://github.com/mylar3/mylar3.git /app/mylar && \
 cd /app/mylar && \
 git checkout ${MYLAR_COMMIT} && \
 echo "**** cleanup ****" && \
 rm -rf \
	/root/.cache \
	/tmp/* && \
 echo "**** install pip ****" && \
 python3 -m ensurepip && \
 rm -r /usr/lib/python*/ensurepip && \
 pip3 install --no-cache --upgrade pip setuptools wheel && \
 if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
 echo "**** install pip packages ****" && \
 pip3 install --no-cache-dir -U -r /app/mylar/requirements.txt && \
  rm -rf ~/.cache/pip/*

# add local files
COPY root/ /

# ports and volumes
VOLUME /config /comics /downloads
EXPOSE 8090
