#!/bin/bash

sort $1 | sed -e 's/$/ X/' > j1
sort $2 | sed  -e 's/$/ Y/' > j2

join -a 1 -t " " -1 1 -2 1 j1 j2  | grep -v 'X Y' | sed -e 's/ X//'

