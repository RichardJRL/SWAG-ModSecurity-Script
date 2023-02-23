# Useful Links
## Tutorials
* https://www.linode.com/docs/guides/securing-nginx-with-modsecurity/
* https://www.nginx.com/blog/compiling-and-installing-modsecurity-for-open-source-nginx/

## ModSecurity
* ModSecurity Reference Manual v2 and v3 https://github.com/SpiderLabs/ModSecurity/wiki/Reference-Manual-(v3.x)

## ModSecurity-nginx Connector
* Github: https://github.com/SpiderLabs/ModSecurity-nginx
* Configuration directives for ModSecurity in the nginx.conf file https://github.com/SpiderLabs/ModSecurity-nginx#usage
  ## OWASP Core Rule Set (CRS)
* https://github.com/coreruleset
* https://coreruleset.org/doc
* https://coreruleset.org/20211222/talking-about-modsecurity-and-the-new-coraza-waf/

# apk Package Cache Information

Create a persistant local cache of apk packages to speed-up testing of
ModSecurity compilation inside the LinuxServer.io SWAG secure reverse proxy
docker container.
For docker compose, the persistent volume `- ./apk-cache:/etc/apk/cache` 
created in docker-compose.yml is automatically used for cached packages.

Other information regarding apk package caching:

https://wiki.alpinelinux.org/wiki/Local_APK_cache

Alpine has a script `setup-apkcache` that can be used to enable the cache but
a) it's not included in the SWAG container
b) I'm not sure if it's anything more than an ln command (I need to read it)

Manually create a link to a persistent local package cache dir:
`ln -s /apk-cache /etc/apk/cache`
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

## Runtime Errors
```
nginx: [emerg] module "/var/lib/nginx/modules/ngx_http_modsecurity_module.so" is not binary compatible in /etc/nginx/modules/10_http_modsecurity.conf:1
```
Oh...
This refers to the nginx connector module for ModSecurity - not ModSecurity itself.

## TODO:
- IMPORTANT: Enact checks for config files stored in the persistent storage volume that may have already been edited on the container's first run. 
## DONE:
- Find `libinjection` and install it. It appears to have libInjection v3.9.2-46-gbfba51f installed already. I have no idea what package provides this. Update; it is a git submodule of the ModSecurity git repo.