#!/bin/bash

# Create link that apk needs to find the persistent local package cache dir
# https://wiki.alpinelinux.org/wiki/Local_APK_cache
# Not sure if this is needed or whether the persistent volume /etc/apk/cache created in docker compose will automatically be used
# Also Alpine has a script `setup-apkcache` that can be used to enable the cache but I'm not sure if it's anything more than an ln command
# TODO: read it!
# docker exec alpine-freepbx ln -s /apk-cache /etc/apk/cache

# Install dpendencies
# Dependency list from https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/
# Dependencies originally for Ubuntu 18.04
apk add autoconf automake build-base ca-certificates gcc git libtool linux-headers lua5.3-dev pkgconf valgrind 
apk add afl++ bison curl curl-dev flex gawk geoip-dev lmdb-dev libxml2 libxml2-dev openssl-dev pcre-dev yajl yajl-dev zlib zlib-dev
# apk add bison iputils expat-dev
# # missing libpcrec++-dev
# apk add musl-locales wget libxslt libgd
# OPTIONAL (for generating documentation only)
# apk add doxygen


# list of Alpine dependencies and their Ubuntu 18.04 equivalents 
    # bison \ # ok
    # build-base \ # build-essential: build-base
    # ca-certificates \ # ok
    # curl \ # ok
    # autoconf \ # dh-autoreconf: autoconf
    # doxygen \ # ok
    # flex \ # ok
    # gawk \ # ok
    # iputils \ # iputils-ping: iputils
    # curl-dev \ # libcurl4-gnutls-dev: curl-dev AND MAYBE gnutls-dev
    # expat-dev \ # libexpat1-dev: expat-dev
    # geoip-dev \ # libgeoip-dev: geoip-dev
    # lmdb-dev \ # liblmdb-dev: lmdb-dev
    # pcre2-dev \ # libpcre3-dev (8.44): pcre-dev (8.45) OR pcre2-dev (10.42) (first try with pcre2-dev as the 8.X versions are EOL. NO it wants **pcre-dev**, tested.) (in Debian/Ubuntu, libpcre2... is newer than libpcre3...)
    # \ # libpcre++-dev \ # libpcre++-dev: UNKNOWN
    # openssl-dev \ # libssl-dev (OpenSSL project): 
    # libtool \ # ok
    # libxml2 \ # ok
    # libxml2-dev \ # ok
    # yajl-dev \ # libyajl-dev: yajl-dev
    # musl-locales \ # locales: musl-locales
    # lua5.3-dev \ # ok
    # pkgconf \ # pkg-config: pkgconf
    # wget \ # ok
    # zlib-dev \ # zlib1g-dev: zlib-dev (NB: see also zlib-ng (new gen) vs zlib1g (first gen))
    # zlib \ # zlibc: zlib NB: unsure of the relationship between zlib and zlibc
    # libxslt \ # ok
    # libgd-dev # libgd-dev: libgd

# Install tools
# apk add \
#     git # ok

# Get the ModSecurity git repository
cd /opt
git clone https://github.com/SpiderLabs/ModSecurity
cd ./ModSecurity

# Inititalise the ModSecurity git submodule


./build.sh
./configure
# Configure messages of note:
# configure: LMDB is disabled by default.
# configure: SSDEEP library was not found
# checking if libcurl is linked with gnutls... no
# configure: Nothing about PCRE2 was informed during the configure phase. Trying to detect it on the platform...
# configure: PCRE2 is disabled by default.
# checking for string... no
# checking for iostream... no
# checking for dlltool... no
# checking for sysroot... no
# checking for mt... no
# checking if : is a manifest tool... no
# checking if gcc supports -fno-rtti -fno-exceptions... no
# checking whether -lc should be explicitly linked in... no
# checking for shl_load... no
# checking for shl_load in -ldld... no
# checking whether a statically linked program can dlopen itself... no
# checking for doxygen... no
# configure: WARNING: doxygen not found - will not generate any doxygen documentation
# checking for valgrind... no
#    + LMDB                                          ....disabled
#    + SSDEEP                                        ....not found
#    + PCRE2                                          ....disabled
#    + afl fuzzer                                    ....disabled
#    + Building parser                               ....disabled
#    + Treating pm operations as critical section    ....disabled

# Notes on configure output
# - SSDEEP not found despite ssdeep and ssdeep-static being installed
git submodule init
git submodule update
./configure
make -j $(grep -m 1 siblings /proc/cpuinfo | awk -F ':' '{print $2}')
