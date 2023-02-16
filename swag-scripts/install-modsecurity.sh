#!/bin/bash

# Install dpendencies
# Dependency list from https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/
# Dependencies originally for Ubuntu 18.04
apk add \
    bison \ # ok
    build-base \ # build-essential: build-base
    ca-certificates \ # ok
    curl \ # ok
    autoconf \ # dh-autoreconf: autoconf
    doxygen \ # ok
    flex \ # ok
    gawk \ # ok
    iputils \ # iputils-ping: iputils
    curl-dev \ # libcurl4-gnutls-dev: curl-dev AND MAYBE gnutls-dev
    expat-dev \ # libexpat1-dev: expat-dev
    geoip-dev \ # libgeoip-dev: geoip-dev
    lmdb-dev \ # liblmdb-dev: lmdb-dev
    pcre2-dev \ # libpcre3-dev (8.44): pcre-dev (8.45) OR pcre2-dev (10.42) (first try with pcre2-dev as the 8.X versions are EOL) (in Debian/Ubuntu, libpcre2... is newer than libpcre3...)
    \ # libpcre++-dev \ # libpcre++-dev: UNKNOWN
    openssl-dev \ # libssl-dev (OpenSSL project): 
    libtool \ # ok
    libxml2 \ # ok
    libxml2-dev \ # ok
    yajl-dev \ # libyajl-dev: yajl-dev
    locales \ # locales: musl-locales
    lua5.3-dev \ # ok
    pkgconf \ # pkg-config: pkgconf
    wget \ # ok
    zlib-dev \ # zlib1g-dev: zlib-dev (NB: see also zlib-ng (new gen) vs zlib1g (first gen))
    zlib \ # zlibc: zlib NB: unsure of the relationship between zlib and zlibc
    libxslt \ # ok
    libgd-dev # ok

# Install tools
apk add \
    git # ok

# Get the ModSecurity git repository
cd /opt
git clone https://github.com/SpiderLabs/ModSecurity
cd ./ModSecurity

# Inititalise the ModSecurity git submodule
git submodule init
git submodule update
#./build.sh


