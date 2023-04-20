#!/bin/sh

for rtr in pe2 pe4 p2 rr2 h2; do
    scp $rtr.full.conf x@$rtr:disk0:/conf.txt
    ssh x@$rtr copy disk0:/conf.txt running
done
