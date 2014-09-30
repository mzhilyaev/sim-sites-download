#!/bin/bash

while read site; do
 echo "loading $site"
 curl "http://xml.alexa.com/data?cli=10&dat=nsa&ver=quirk-searchstatus&uid=19700101000000&userip=127.0.0.1&url=$site" > $site
done
