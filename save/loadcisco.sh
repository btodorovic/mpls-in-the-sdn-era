#!/bin/sh

for rtr in pe2 pe4 p2 rr2 h2; do
    scp $rtr.full.conf x@$rtr:disk0:/var/tmp/conf.txt
    ssh x@$rtr copy disk0:/var/tmp/conf.txt running
done
