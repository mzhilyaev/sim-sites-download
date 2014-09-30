#!/bin/bash

while read site; do
 echo "loading $site"
 curl "http://api.similarweb.com/Site/$site/v2/categoryrank?Format=JSON&UserKey=$1" >> $site
 echo "" >> $site
 curl "http://api.similarweb.com/Site/$site/v2/similarsites?Format=JSON&UserKey=$1" >> $site
done
