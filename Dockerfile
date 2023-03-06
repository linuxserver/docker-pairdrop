# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.17

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PAIRDROP_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

# environment settings
ENV HOME="/app"
ENV NODE_ENV="production"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    nodejs \
    npm && \
  echo "**** install pairdrop ****" && \
  mkdir -p /app/pairdrop && \
  if [ -z ${PAIRDROP_RELEASE} ]; then \
    PAIRDROP_RELEASE=$(curl -sL "https://api.github.com/repos/schlagmichdoch/pairdrop/tags" \
    | jq -r '.[0].name'); \
  fi && \
  curl -o \
    /tmp/pairdrop.tar.gz -L \
    "https://github.com/schlagmichdoch/PairDrop/archive/refs/tags/${PAIRDROP_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/pairdrop.tar.gz -C \
    /app/pairdrop/ --strip-components=1 && \
  cd /app/pairdrop && \
  adduser -D node && \
  chown -R node:node ./ && \
  su node -c 'npm ci' && \
  echo "**** cleanup ****" && \
  rm -rf \
    $HOME/.cache \
    /tmp/* \
    /home/node/.npm \
    /app/.npm

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000
