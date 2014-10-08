deploy-phonegapbuild
====================

Zip PhoneGap app and deploy to PhoneGap Build.

This is a build script originally written for Gitlab CI but should be fine for whatever CI server you're using.

The script does the following:

HOWTO
-----

- (one-time) configure the script editing it and filling in the "### Config ###' section
- chdir to www folder
- execute the script

Dependancies
------------

- Jshon from http://kmkeen.com/jshon/
- XMLLint from http://xmlsoft.org/xmllint.html (or libxml2-utils on Debian-based distros)

License
-------

This script is licensed under MIT Expat, i.e. you can do anything including commercial purposes, just don't blame it on me if anything goes wrong! :)

