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
./configure

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
# "Not Binary Compatibile" error suggestions:
# - Try removing other dynamic modules from the configuration args (no effect)
# - Try with/without the `--with-compat` option (no effect)
NGINX_CONFIGURATION_ARGS=$(echo $NGINX_CONFIGURATION_ARGS | sed -E 's/--add-dynamic-module=\/.*\/ ?//g')
./configure --with-compat "$NGINX_CONFIGURATION_ARGS" --add-dynamic-module=../ModSecurity-nginx

make modules
mkdir -p /etc/nginx/modules
# In the swag container, the path to existing nginx modules is /usr/lib/nginx/modules/
# In the swag container /etc/nginx/modules contains only numbered .conf files which
# are one-liners that serve to load the nginx module from the /usr/lib/nginx/modules/ directory
# e.g. load_module "modules/ngx_http_perl_module.so";
# NB: This module has also been `make install`ed to `/var/lib/nginx/modules/`
strip objs/ngx_http_modsecurity_module.so
cp objs/ngx_http_modsecurity_module.so /usr/lib/nginx/modules/
echo 'load_module "modules/ngx_http_modsecurity_module.so";' > /etc/nginx/modules/10_http_modsecurity.conf

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
# TODO: Find out which database (country, city etc) is needed
# TODO: Find out if the LinuxServer.io container addons for GeoIP or MaxMind
# satisfy ModSecurity's geolocation database requirements.