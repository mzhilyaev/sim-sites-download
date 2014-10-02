#!/bin/bash

while read site; do
 echo "loading $site"
 curl -L "http://$site" > $site
done
