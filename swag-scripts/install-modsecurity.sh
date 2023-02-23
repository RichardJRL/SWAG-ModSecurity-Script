#!/bin/bash

################################################################################
# Build ModSecurity inside LinuxServer.io's SWAG HTTPS Reverse Proxy container
################################################################################

# Install tooling required to build ModSecurity
apk add autoconf automake build-base ca-certificates gcc git libtool linux-headers pkgconf wget

# Install dependencies of ModSecurity
apk add bison curl curl-dev flex gawk geoip-dev libfuzzy2 libfuzzy2-dev libpcrecpp libxml2 libxml2-dev libxslt libxslt-dev lmdb lmdb-dev lua5.3-dev lua5.3-lzlib openssl-dev pcre-dev yajl yajl-dev zlib zlib-dev

# OPTIONAL: Install dependencies of ModSecurity with American Fuzzy Lop plus plus (afl++) support
#         : NB: also MUST subsequently ./configure with the --enable-afl-fuzz option
# apk add afl++ compiler-rt
# export CXX=afl-clang-fast++ 
# export CC=afl-clang-fast 

# OPTIONAL: Compile with valgrind support
#         : NB: also MUST subsequently ./configure with the --enable-valgrind option
# apk add valgrind

# OPTIONAL: Install tooling required for generating documentation for ModSecurity
# The 'mandoc' and 'man-db' packages are in conflict. Alpine FAQ recommends mandoc.
# NB: `make` does not appear to generate ANY documentation. Enter `/opt/ModSecurity/doc` and  
# run `doxygen doxygen.cfg` to generate HTML & LaTeX documentation in a subdirectory there.
# NB: also MUST subsequently run ./configure with various documentation options specified.
# apk add doxygen mandoc mandoc-apropos man-pages sqlite texlive
# docdir='/docs'
# mkdir -p "$docdir"

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
git clone --depth=1 https://github.com/SpiderLabs/ModSecurity
cd ./ModSecurity

# Inititalise the ModSecurity git submodule
git submodule init
git submodule update

# Pre-build checks etc.
./build.sh
# Run configure without any specific options. Run `./configure --help` for a full list of options.
# ./configure

#/ Run configure with the GNU linker
./configure --with-gnu-ld

# TODO: Find out what --enable-parser-generation does.
# ./configure --enable-parser-generation 

# Configure wiht support for testing ModSecurity with American Fuzzy Lop plus plus (afl++) support
# ./configure --enable-afl-fuzz

# Configure with support for Valgrind
# ./configure --enable-valgrind

# Configure with support for documentation generation (NB: doesn't actually generate any documentation!)
# ./configure --docdir="$docdir" \
#     --enable-doxygen-dot \
#     --enable-doxygen-man \
#     --enable-doxygen-rtf \
#     --enable-doxygen-xml \
#     --enable-doxygen-ps \
#     --enable-doxygen-pdf \
#     --docdir="$docdir" \
#     --infodir="$docdir"/info \
#     --mandir="$docdir"/man \
#     --htmldir="$docdir"/html \
#     --dvidir="$docdir"/dvi \
#     --pdfdir="$docdir"/pdf \
#     --psdir="$docdir"/ps


# ##Configure output of note:
# configure: LMDB is disabled by default.
# checking if libcurl is linked with gnutls... no
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

#    + LMDB                                          ....disabled
#    + PCRE2                                          ....disabled
#    + Treating pm operations as critical section    ....disabled

# Notes on configure output

# lmdb      : apk comment: Lightning Memory-Mapped Database
#           : Centos, Amazon & Ubuntu compilation recipes on the ModSecurity wiki all use this.
#           : It isn't mentioned in the nginx -V configure options
#           : Appears disabled by default despite lmdb and lmdb-dev being installed

# pcre2     : pcre2 support is specifically disabled in alpine's nginx configure options, uses pcre instead

# SSDEEP    : Not found despite ssdeep and ssdeep-static being installed.
#           : It requires libfuzzy2-dev instead - which appears to be an alternative & preferred implementation.

# Build on all CPU threads
make -j $(grep -m 1 siblings /proc/cpuinfo | awk -F ':' '{print $2}')
make install

################################################################################
# Nginx Connector for ModSecurity - Dynamic Module Build
################################################################################

cd /opt
git clone --depth=1 https://github.com/SpiderLabs/ModSecurity-nginx

# NB: nginx version number is output to STDERR not STDOUT
NGINX_VERSION=nginx-$(nginx -v 2> >(awk -F '/' '{ print $2 }'))
wget "http://nginx.org/download/$NGINX_VERSION.tar.gz"
tar -xvzmf "$NGINX_VERSION.tar.gz"
cd "$NGINX_VERSION"

NGINX_CONFIGURATION_ARGS=$(nginx -V 2> >(sed -n 's/configure arguments: //p'))
./configure --add-dynamic-module=../ModSecurity-nginx "$NGINX_CONFIGURATION_ARGS"

## Choice lines from ./configure output
# dirname: unrecognized option '--sbin-path=/usr/sbin/nginx'
# Try 'dirname --help' for more information.
# dirname: unrecognized option '--sbin-path=/usr/sbin/nginx'
# Try 'dirname --help' for more information.
# Configuration summary
#   + using system PCRE library
#   + OpenSSL library is not used
#   + using system zlib library

make modules
mkdir -p /etc/nginx/modules
# In the swag container, the path to existing nginx modules is /usr/lib/nginx/modules/
# In the swag container /etc/nginx/modules contains only numbered .conf files which
# are one-liners that serve to load the nginx module from the /usr/lib/nginx/modules/ directory
# e.g. load_module "modules/ngx_http_perl_module.so";
# NB: This module has also been `make install`ed to `/var/lib/nginx/modules/`
cp objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/
echo 'load_module "modules/ngx_http_modsecurity_module.so";' > /etc/nginx/modules/10_http_modsecurity.conf
# TODO: Check for a modules-enabled directory...

################################################################################
# Install the OWASP Core Rule Set for ModSecurity
################################################################################

cd /usr/local
git clone --depth=1 https://github.com/coreruleset/coreruleset /usr/local/modsecurity-crs
cd /usr/local/modsecurity-crs/

mkdir -p /config/nginx/modsecurity-crs

# Copy default ModSecurity Rule-Set configuration file
# TODO: Does this need to be included in the SWAG persistant storage somehow?
cp /usr/local/modsecurity-crs/crs-setup.conf.example /config/nginx/modsecurity-crs/crs-setup.conf.example
if [[ ! -f /config/nginx/modsecurity-crs/crs-setup.conf ]]; then
    cp /usr/local/modsecurity-crs/crs-setup.conf.example /config/nginx/modsecurity-crs/crs-setup.conf
fi

mkdir -p /config/nginx/modsecurity-crs/rules
cd /usr/local/modsecurity-crs/rules

# Copy ALL rule conf and data files
cp /usr/local/modsecurity-crs/rules/*.conf /config/nginx/modsecurity-crs/rules/
cp /usr/local/modsecurity-crs/rules/*.data /config/nginx/modsecurity-crs/rules/

# Create a "default exclusion rules before CRS" file if it doesn't already exist
cp REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /config/nginx/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example
if [[ ! -f /config/nginx/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf ]]; then
    cp REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /config/nginx/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
fi

# Create a "default exclusion rules after CRS file" if it doesn't already exist
cp REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /config/nginx/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example
if [[ ! -f /config/nginx/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf ]]; then
    cp REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /config/nginx/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
fi

# Copy all plugins files (no plugins are available by default)

mkdir -p /config/nginx/modsecurity-crs/plugins
cd /usr/local/modsecurity-crs/plugins
cp README.md /config/nginx/modsecurity-crs/plugins/
# This trio of empty plugin conf files are required to ensure an include *.conf directive does not fail on an empty plugin directory
touch /config/nginx/modsecurity-crs/plugins/empty-config.conf
touch /config/nginx/modsecurity-crs/plugins/empty-before.conf
touch /config/nginx/modsecurity-crs/plugins/empty-after.conf

# NB: Rules for common applications such as Wordpress and Nextcloud are now contained 
# in their own dedicated plugins. Install them separately when their dedicated containers 
# are installed, or install them all now?
# Arguments for and against.
# Against: By no means needed now. 
# For: SWAG's entire set of reverse proxy conf files are all installed now.
# Suggestion: Add them all disabled with .example extensions, to mirror the .sample extensions of SWAG's proxy confs

# Install the 8 rule exclusions plugins from the official Core Rule Set Project github
RULE_EXCLUSION_PLUGINS=('wordpress' 'phpmyadmin' 'nextcloud' 'xenforo' 'phpbb' 'cpanel' 'dokuwiki' 'drupal')
for plugin in "${RULE_EXCLUSION_PLUGINS[@]}"
do
    plugin=$plugin-rule-exclusions
    mkdir -p "/usr/local/modsecurity-crs-plugins/$plugin-plugin"
    git clone --depth=1 "https://github.com/coreruleset/$plugin-plugin.git" "/usr/local/modsecurity-crs-plugins/$plugin-plugin"
    cd "/usr/local/modsecurity-crs-plugins/$plugin-plugin/plugins"
    for file in ./*
    do
        cp "$file" "/config/nginx/modsecurity-crs/plugins/$file.sample"
    done
    # TODO: Remove git repository directory after copying to nginx?
done
cd /usr/local/modsecurity-crs-plugins

# Install other plugins fom the official Core Rule Set Project github#
# NB: body-decompress-plugin requires 'lua5.3-lzlib' package
# NB: fake-bot-plugin requires 'lua5.3-socket' library
# NB: auto-decoding-plugin has a performance impact
# NB: antivirus-plugin requires 'lua5.3-socket' library
GENERAL_PLUGINS=('body-decompress' 'fake-bot' 'auto-decoding' 'antivirus' 'google-oauth2')
for plugin in "${GENERAL_PLUGINS[@]}"
do
    mkdir -p "/usr/local/modsecurity-crs-plugins/$plugin-plugin"
    git clone --depth=1 "https://github.com/coreruleset/$plugin-plugin.git" "/usr/local/modsecurity-crs-plugins/$plugin-plugin"
    cd "/usr/local/modsecurity-crs-plugins/$plugin-plugin/plugins"
    for file in ./*
    do
        cp "$file" "/config/nginx/modsecurity-crs/plugins/$file.sample"
    done
    # TODO: Remove git repository directory after copying to nginx?
done
cd /usr/local/modsecurity-crs-plugins

################################################################################
# Configure ModSecurity & Integrate With nginx
################################################################################

mkdir -p /config/nginx/modsecurity

cp /opt/ModSecurity/unicode.mapping /config/nginx/modsecurity/

# Always copy the recommended conf file to the SWAG persistant storage directory
cp /opt/ModSecurity/modsecurity.conf-recommended /config/nginx/modsecurity/modsecurity.conf.sample

# Set the default behaviour for ModSecurity in the sample configuration file to On from DetectionOnly
# TODO: Decide whether to leave the default as 'DetectionOnly' or switch it to 'On'
sed -i -E 's/^#? *SecRuleEngine DetectionOnly/SecRuleEngine On/' /config/nginx/modsecurity/modsecurity.conf.sample

# Make the sample configuration file the active configuration file if one does not already exist
if [[ ! -f /config/nginx/modsecurity.conf ]]; then
    cp /config/nginx/modsecurity/modsecurity.conf.sample /config/nginx/modsecurity/modsecurity.conf
fi

# Add the ModSecurity and ModSecurity-CRS conf files to a new config file
touch /config/nginx/modsecurity/main.conf
{
    echo '# Include ModSecurity Web Application Firewall configuration file'
    echo 'include /config/nginx/modsecurity/modsecurity.conf'
    echo '# Include ModSecurity Core Rule Set configuration files'
    echo 'include /config/nginx/modsecurity-crs/crs-setup.conf'
    echo 'include /config/nginx/modsecurity-crs/rules/*.conf'
    echo 'include /config/nginx/modsecurity-crs/plugins/*.conf'
} >> /config/nginx/modsecurity/main.conf

# Include the relevant nginx configuration directives to turn ModSecurity on and provide a path to the rules files
# See: https://github.com/SpiderLabs/ModSecurity-nginx#usage
# Both the `modsecurity` and `modsecurity_rules_file` can have `http`, `server` or `location` context in nginx conf files.
# `server` level chosen here due to SWAG's breakdown of conf files into individual proxy-confs that operate at the server level.
# server {
#   ...
#   modsecurity on;
#   modsecurity_rules_file /config/nginx/modsecurity/main.conf;
#   ...
# }
# Update site-confs/default.conf
# Compare default.conf and default.conf.sample.
# If the same, update both;
# If different, assume user has customised default.conf and update only default.conf.sample
cd /config/nginx/site-confs/
default_files=('default.conf.sample')
if cmp -s default.conf default.conf.sample
then
    default_files+=( 'default.conf' )
fi

for file in "${default_files[@]}"
do
    # SWAG:
    # sed -E -i '/include \/config\/nginx\/authentik-server/a\
    # nginx:
    sed -E -i '/server_name /a\
    \
    # Comment the next two lines to disable the ModSecurity firewall for the default site\
    modsecurity on;\
    modsecurity_rules_file \/config\/nginx\/modsecurity\/main.conf;' "$file"
done

# # Update proxy-confs/*.conf.sample
# cd /config/nginx/proxy-confs/
# for file in *.conf.sample
# do
#     service_name=$(echo $file | sed "s/\.sub.*\.conf\.sample//")
#     echo "Working on service name: $service_name"
#     sed -E -i '/include \/config\/nginx\/authentik-server/a\
#     \
#     # Comment the next two lines to disable the ModSecurity firewall for this reverse proxied service\
#     modsecurity on;\
#     modsecurity_rules_file \/config\/nginx\/modsecurity\/main.conf;' "$file"
# done

# NB: This is the old syntax below. It changed to the above version, see https://github.com/SpiderLabs/ModSecurity/issues/1039
# but it still appears in various online sources such as the ModSecurity wiki Reference Manual v3, CRS docs...
# location / {
#     ...
#     ModSecurityEnabled on;
#     ModSecurityConfig modsecurity.conf;
#     ...
# }

################################################################################
# Download the GeoIP Location Database 
################################################################################
# TODO: Find out which database (country, city etc)