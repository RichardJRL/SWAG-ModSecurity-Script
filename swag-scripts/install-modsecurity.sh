#!/bin/bash

################################################################################
# apk package cache information
################################################################################

# Create a persistant local cache of apk packages to speed-up testing of
# ModSecurity compilation inside the LinuxServer.io SWAG secure reverse proxy
# docker container.
# For docker compose, the persistent volume `- ./apk-cache:/etc/apk/cache` 
# created in docker-compose.yml is automatically used for cached packages.

# Other information regarding apk package caching:

# https://wiki.alpinelinux.org/wiki/Local_APK_cache

# Alpine has a script `setup-apkcache` that can be used to enable the cache but
# a) it's not included in the SWAG container
# b) I'm not sure if it's anything more than an ln command (I need to read it)

# Manually create a link to a persistent local package cache dir:
# ln -s /apk-cache /etc/apk/cache

################################################################################
# Build ModSecurity inside LinuxServer.io's SWAG HTTPS Reverse Proxy container
################################################################################

# Install tooling required to build ModSecurity
apk add autoconf automake build-base ca-certificates gcc git libtool linux-headers pkgconf valgrind wget
# Install dependencies of ModSecurity
apk add afl++ bison curl curl-dev flex gawk geoip-dev libfuzzy2 libfuzzy2-dev libpcrecpp libxml2 libxml2-dev libxslt libxslt-dev lmdb lmdb-dev lua5.3-dev openssl-dev pcre-dev yajl yajl-dev zlib zlib-dev
# OPTIONAL: Install tooling required for generating documentation for ModSecurity
# apk add doxygen 

# Gleaned from the Linode instructions for compiling ModSecurity for Ubuntu 18.04 but AFAIK not needed here (no errors in ./build.sh  nor ./configure) 
# iputils   : apk comment: IP Configuration Utilities (and Ping)
#           : URL: https://github.com/iputils/iputils/
#           : Official description: The iputils package is set of small useful utilities for Linux networking.
#           : TODO: Check if this is installed by default on alpine.
#           : ANSWER: No, it is not
# expat-dev : apk comment: XML Parser library written in C
#           : URL: https://libexpat.github.io
#           : Official description:  A stream-oriented XML parser library written in C.
#           : Expat excels with files too large to fit RAM, and where performance and flexibility are crucial.
#           : TODO: Test whether expat, expat-dev can be used INSTEAD of libxml2, libxml2-dev
# libpcrecpp    : apk comment: C++ bindings for PCRE
#               : URL: https://www.pcre.org/
#               : TODO: Check if installed by default before running this script, because it is now.
# musl-locales  : apk comment: Locales support for musl
# libxslt   : apk comment: XML stylesheet transformation library
#           : URL: http://xmlsoft.org/XSLT/
#           : NOTES: Only the CentOS and AWS Linux build recipies in the ModSecurity Wiki include this as a named dependency.
#           : TODO: Check if installed by default before running this script
#           : ANSWER: libxslt is installed now, libxslt-dev is not.
#                   : nginx is compiled with xslt support (ref: nginx -V)
# libgd     : apk comment: Library for the dynamic creation of images by programmers (libraries)
#           : URL: https://libgd.github.io/
#           : NOTES: Only the CentOS and AWS Linux build recipies in the ModSecurity Wiki include this as a named dependency.
#           : TODO: Check if installed by default before running this script
            # ANSWER: Installed now but...

# Dependency list from https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/
# Dependencies originally for Ubuntu 18.04
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
# libpcre++-dev \ # libpcre++-dev: libpcrecpp
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

# Get the ModSecurity git repository
cd /opt
git clone https://github.com/SpiderLabs/ModSecurity
cd ./ModSecurity

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

# afl fuzzer: apk comment: Fuzzer relying on genetic algorithms instead of brute force
#           : No mention of this in alipine's nginx -V configure options.
#           : No mention of this in the compilation recipes page on the ModSecurity Wiki
#           : I don't know what it is or why or where it is disabled.
# lmdb      : apk comment: Lightning Memory-Mapped Database
#           : Centos, Amazon & Ubuntu compilation recipies on the ModSecurity wiki all use this.
#           : It isn't mentioned in the nginx -V configure options
#           : Appears disabled by default despite lmdb and lmdb-dev being installed
# pcre2     : pcre2 support is specifically disabled in alpine's nginx configure options, uses pcre instead
# SSDEEP    : Not found despite ssdeep and ssdeep-static being installed.
#           : It requires libfuzzy2-dev instead - which appears to be an alternative & preferred implementation.

# Inititalise the ModSecurity git submodule
git submodule init
git submodule update
./configure
make -j $(grep -m 1 siblings /proc/cpuinfo | awk -F ':' '{print $2}')

################################################################################
# ModSecurity Connector Build
################################################################################

cd /opt
git clone https://github.com/SpiderLabs/ModSecurity-nginx

# NB: nginx version number is output to STDERR not STDOUT
cd /opt
NGINX_VERSION=nginx-$(nginx -v 2> >(awk -F '/' '{ print $2 }'))
wget "http://nginx.org/download/$NGINX_VERSION.tar.gz"
tar -xvzmf "$NGINX_VERSION.tar.gz"
cd "$NGINX_VERSION"

NGINX_CONFIGURATION_ARGS=$(nginx -V 2> >(sed -n 's/configure arguments: //p'))
./configure --add-dynamic-module=../ModSecurity-nginx "$NGINX_CONFIGURATION_ARGS"
make modules
mkdir /etc/nginx/modules