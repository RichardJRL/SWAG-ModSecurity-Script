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

## ModSecurity Documentation Generation
Nothing is working regarding documentation generation or installation in the `configure`/`make`/`make install` pipeline. 
Enter the subdirectory `doc` and run the command `doxygen doxygen.cfg`. HTML documentation will then be generated in an `html` subdirectory.

## TODO:
- IMPORTANT: Enact checks for config files stored in the persistent storage volume that may have already been edited on the container's first run. 
## DONE:
- Find `libinjection` and install it. It appears to have libInjection v3.9.2-46-gbfba51f installed already. I have no idea what package provides this. Update; it is a git submodule of the ModSecurity git repo.