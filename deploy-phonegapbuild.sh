#!/bin/bash

# 8p8@Mobimentum 2014-10-08 Build a PhoneGap app and publish to PhoneGap Build


### Config ###

# PhoneGap Build basic auth (include ":" at the end with no password)
PGB_AUTH_USER="example@mobimentum.it:"

# PhoneGap Build auth token 
PGB_AUTH_TOKEN="YOUR-TOKEN-HERE"

# Jshon, cfr. http://kmkeen.com/jshon/
# Requires libjansson4 and libjansson-dev
JSHON=$(which jshon)

# cURL
CURL="$(which curl)"

# XMLLint is in package libxml2-utils (Debian)
XMLLINT="$(which xmllint)"

### Script ###

status=0

# Zip content
app="www"
test -d "www" && cd "www"
zip -r "${app}.zip" * >/dev/null
echo "*** ZIP FILE SIZE: $(ls -lh ${app}.zip) ***"

# Check config.xml
if [ ! -f config.xml ]
then
        echo "*** Missing config.xml ***";
        exit 1
fi

# Check if app is already uploaded to PG:B
# cfr. https://build.phonegap.com/docs/read_api
app_pkg="$($XMLLINT --xpath "/*[local-name()='widget']/@id" config.xml | sed 's/\(^ id=\"\|\"$\)//g')"
app_id=""
tmp_json="/tmp/pgb-$$.json"
$CURL -s -S -u "$PGB_AUTH_USER" "https://build.phonegap.com/api/v1/apps?auth_token=$PGB_AUTH_TOKEN" >"$tmp_json"
num_apps="$($JSHON -e apps -l <"$tmp_json")"
for i in $(seq 0 $num_apps); do
        pkg="$($JSHON -e apps -e $i -e package <"$tmp_json" | tr -d '"')"
        if [[ "$pkg" == "$app_pkg" ]]; then
                app_id="$($JSHON -e apps -e $i -e id <"$tmp_json" | tr -d '"')"
                break
        fi
done

echo "*** APP ID: $app_id ***"

# Upload app
# cfr. https://build.phonegap.com/docs/write_api
if [[ ! -z "$app_id" ]]
then
        # App already uploaded
        echo "*** APP FOUND, UPDATING... ***"
        $CURL -s -S -u "$PGB_AUTH_USER" -X PUT -F "file=@${app}.zip" \
                "https://build.phonegap.com/api/v1/apps/$app_id?auth_token=$PGB_AUTH_TOKEN"
else
        # New app
        # Upload to PG:B
        echo "*** APP NOT FOUND, CREATING... ***"
        $CURL -s -S -u "$PGB_AUTH_USER" -F "file=@${app}.zip" -F "data={\"title\":\"$app\",\"create_method\":\"file\"}" \
                "https://build.phonegap.com/api/v1/apps?auth_token=$PGB_AUTH_TOKEN"
fi
if [[ $status -eq 0 ]]; then status=$?; fi

exit $status

