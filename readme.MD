# Documentation for Compiling ModSecurity for Nginx on Alpine Linux
## Tutorials
- https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/
- https://www.nginx.com/blog/compiling-and-installing-modsecurity-for-open-source-nginx/

## Containers
- https://github.com/linuxserver/docker-baseimage-alpine-nginx
- https://github.com/linuxserver/docker-nginx
- https://github.com/linuxserver/docker-swag
- https://github.com/just-containers/s6-overlay
## ModSecurity
- https://github.com/SpiderLabs/ModSecurity
- ModSecurity compilation recipes for v3 https://github.com/SpiderLabs/ModSecurity/wiki/Compilation-recipes-for-v3.x
- ModSecurity Reference Manual v2 and v3 https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-(v3.x)
- Install and configure the paid-for "plus" version https://docs.nginx.com/nginx-waf/admin-guide/nginx-plus-modsecurity-waf-installation-logging/

## ModSecurity-nginx Connector
- Github: https://github.com/SpiderLabs/ModSecurity-nginx
- Configuration directives for ModSecurity in the nginx.conf file https://github.com/SpiderLabs/ModSecurity-nginx#usage
## OWASP Core Rule Set (CRS)
- https://github.com/coreruleset
- https://coreruleset.org/doc
- https://coreruleset.org/20211222/talking-about-modsecurity-and-the-new-coraza-waf/

## GeoIP
- https://www.netnea.com/cms/2022/10/12/using-geoip-information-together-with-modsecurity/

## apk Package Cache Information
Create a persistent local cache of apk packages to speed-up testing of ModSecurity compilation inside the LinuxServer.io SWAG secure reverse proxy docker container.
For docker compose, the persistent volume `- ./apk-cache:/etc/apk/cache` created in docker-compose.yml is automatically used for cached packages.

Other information regarding apk package caching:

https://wiki.alpinelinux.org/wiki/Local_APK_cache

Alpine has a script `setup-apkcache` that can be used to enable the cache but
a) it's not included in the SWAG container
b) I'm not sure if it's anything more than an ln command (I need to read it)

Manually create a link to a persistent local package cache dir:
`ln -s /apk-cache /etc/apk/cache`
## ModSecurity Ubuntu > Alpine Dependency Equivalence
- Dependency list sourced from https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/
- Dependencies originally for Ubuntu 18.04
- Draft list of Alpine dependencies and their Ubuntu 18.04 equivalents 
  
- **Alpine package \ Ubuntu-original: Alpine equivalent**
- bison \ # ok
- build-base \ # build-essential: build-base
- ca-certificates \ # ok
- curl \ # ok
- autoconf \ # dh-autoreconf: autoconf
- doxygen \ # ok
- flex \ # ok
- gawk \ # ok
- iputils \ # iputils-ping: iputils
- curl-dev \ # libcurl4-gnutls-dev: curl-dev AND MAYBE gnutls-dev
- expat-dev \ # libexpat1-dev: expat-dev
- geoip-dev \ # libgeoip-dev: geoip-dev
- lmdb-dev \ # liblmdb-dev: lmdb-dev
- pcre2-dev \ # libpcre3-dev (8.44): pcre-dev (8.45) OR pcre2-dev (10.42) (first try with pcre2-dev as the 8.X versions are EOL. NO it wants **pcre-dev**, tested.) (in Debian/Ubuntu, libpcre2... is newer than libpcre3...)
- libpcre++-dev \ # libpcre++-dev: libpcrecpp
- openssl-dev \ # libssl-dev (OpenSSL project): 
- libtool \ # ok
- libxml2 \ # ok
- libxml2-dev \ # ok
- yajl-dev \ # libyajl-dev: yajl-dev
- musl-locales \ # locales: musl-locales
- lua5.3-dev \ # ok
- pkgconf \ # pkg-config: pkgconf
- wget \ # ok
- zlib-dev \ # zlib1g-dev: zlib-dev (NB: see also zlib-ng (new gen) vs zlib1g (first gen))
- zlib \ # zlibc: zlib NB: unsure of the relationship between zlib and zlibc
- libxslt \ # ok
- libgd-dev # libgd-dev: libgd
## ModSecurity Unneeded Dependencies on Alpine
Gleaned from the Linode instructions for compiling ModSecurity for Ubuntu 18.04 but AFAIK not needed here (no errors in ./build.sh  nor ./configure) 
### iputils
- apk comment: IP Configuration Utilities (and Ping)
- URL: https://github.com/iputils/iputils/
- Official description: The iputils package is set of small useful utilities for Linux networking.
- TODO: Check if this is installed by default on alpine.
- ANSWER: No, it is not
### expat-dev
- apk comment: XML Parser library written in C
- URL: https://libexpat.github.io
- Official description:  A stream-oriented XML parser library written in C.
- Expat excels with files too large to fit RAM, and where performance and flexibility are crucial.
- TODO: Test whether expat, expat-dev can be used INSTEAD of libxml2, libxml2-dev
### libpcrecpp
- apk comment: C++ bindings for PCRE
- URL: https://www.pcre.org/
- TODO: Check if installed by default before running this script, because it is now.
### musl-locales
- apk comment: Locales support for musl
### libxslt
- apk comment: XML stylesheet transformation library
- URL: http://xmlsoft.org/XSLT/
- NOTES: Only the CentOS and AWS Linux build recipies in the ModSecurity Wiki include this as a named dependency.
- TODO: Check if installed by default before running this script
- ANSWER: libxslt is installed now, libxslt-dev is not.
        - nginx is compiled with xslt support (ref: nginx -V)
### libgd
- apk comment: Library for the dynamic creation of images by programmers (libraries)
- URL: https://libgd.github.io/
- NOTES: Only the CentOS and AWS Linux build recipies in the ModSecurity Wiki include this as a named dependency.
- TODO: Check if installed by default before running this script
            ANSWER: Installed now but...
## ModSecurity Configuration & Build
### `build.sh` Errors
`fatal: No names found, cannot describe anything.` can be safely ignored according to nginx's own ModSecurity setup blog post. It is a `git describe` error 
### afl fuzzer
What is it?
- `apk info` comment: Fuzzer relying on genetic algorithms instead of brute force.
- No mention of this in alipine's nginx -V configure options.
- No mention of this in the compilation recipes page on the ModSecurity Wiki
- It is enabled with a configure option `--enable-afl-fuzz`, after doing so, the following warning appears at the end of the ./configure output:
```
WARNING: afl fuzzer was enabled. Make sure you are using the 'afl-clang-fast' as the compiler, therwise the compilation will fail.
You can set the compiler using:
$ export CXX=afl-clang-fast++ 
$ export CC=afl-clang-fast 
```
- It also needs the package compiler-rt installed otherwise compilation fails as it cannot find the file /usr/lib/clang/15.0.7/lib/linux/libclang_rt.asan_static-x86_64.a . Found it thanks to:
https://bugzilla.redhat.com/show_bug.cgi?id=949489 describes the missing `libclang_rt.asan_static-x86_64.a` as a bug in Red Hat, suggests installing `compiler-rt` package. IT WORKED!
- Also see https://github.com/AFLplusplus/AFLplusplus/blob/stable/instrumentation/README.llvm.md

## ModSecurity Documentation Generation
Nothing is working regarding documentation generation or installation in the `configure`/`make`/`make install` pipeline, regardless of the options `./configure` is run with.
Enter the subdirectory `doc` and run the command `doxygen doxygen.cfg`. HTML & LaTeX documentation will then be generated in an `html` subdirectory.

## ModSecurity Connector for nginx Configuration & Build
### Choice lines from ./configure output
```
dirname: unrecognized option '--sbin-path=/usr/sbin/nginx'
Try 'dirname --help' for more information.
dirname: unrecognized option '--sbin-path=/usr/sbin/nginx'
Try 'dirname --help' for more information.
Configuration summary
  + using system PCRE library
  + OpenSSL library is not used
  + using system zlib library
```
## Runtime Errors
```
nginx: [emerg] module "/var/lib/nginx/modules/ngx_http_modsecurity_module.so" is not binary compatible in /etc/nginx/modules/10_http_modsecurity.conf:1
```
Oh...
This refers to the nginx connector module for ModSecurity - not ModSecurity itself.
### Clues
```
root@e09d50388b62:/usr/lib/nginx/modules# file ngx_http_modsecurity_module.so
ngx_http_modsecurity_module.so: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, with debug_info, not stripped
root@e09d50388b62:/usr/lib/nginx/modules# file ngx_http_perl_module.so 
ngx_http_perl_module.so: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, stripped
```
- TODO: Read `/opt/nginx-1.22.1/objs# less autoconf.err`; there are missing header files. Use apk-file to search for them.


### Possible Solutions
- Try: https://github.com/SpiderLabs/ModSecurity-nginx/issues/117#issuecomment-495350465 - Did not work, but removing the additional dynamic modules may be a good tip.
- TODO: Find out what "not binary compatible" means exactly. https://tuxcare.com/what-is-binary-compatibility-and-what-does-it-mean-for-linux-distributions/
- TODO: Remove debug_info and strip the module (see `file` output above)
  - DONE: `strip [module_name]` will strip symbols, debugging info and other data from object files. Have done this for the compiled module and there is no difference.
- TODO: Some of the ModSecurity v3 compilation recipes use a `--with-compat` option supplied to `./configure`, try this...
  - DONE: Did not work.
- TODO: Try  `--with-cc-opt='-DNGX_HTTP_HEADERS'` as per https://github.com/apache/incubator-pagespeed-ngx/issues/1440
  - DONE: Did not work.
- TODO: Read the bottom comment here (from 2020!). Claims the connector is NOT required any more! https://github.com/SpiderLabs/ModSecurity-nginx/issues/159 The link referenced is now 404 but the Internet Archive has a version: https://web.archive.org/web/20201116083604/https://alfaexploit.com/readArticle/345 (Spanish?). The gist is that since June 2020, the connector has been built-in to nginx and as long as nginx itself is compiled with support for ModSecurity, then only the ModSecurity module is required along with the few lines to include it in `nginx.conf`. Article claims you can use use `make config` for a graphical assistant for what modules to include in an nginx build. ModSecurity should appear there amongst all the other modules listed if this is still the case. This is not the case on alpine now. `make: *** No rule to make target 'config'.  Stop.`, trying `./configure --help`. Not in there either, as suspected. This article appears to be a dead-end and refers to a change to nginx that has since been reversed. I.e. the connector is no longer incorporated into nginx now.
- TODO: Try compiling the connector module with the alpine version of nginx instead of the official nginx version. It may be patched?

## TODO:
- IMPORTANT: Enact checks for config files stored in the persistent storage volume that may have already been edited on the container's first run. 
## DONE:
- Find `libinjection` and install it. It appears to have libInjection v3.9.2-46-gbfba51f installed already. I have no idea what package provides this. Update; it is a git submodule of the ModSecurity git repo.