#!/bin/sh

EXCLUDES="space|mpc|fpc|ubuntu|centos|linux|server|oss|mpc"

vmm ip | egrep -vi $EXCLUDES | gawk '{ status = system("grep "$2" "$1".full.conf > /dev/null"); if (status) { print "Updating fxp0 addresses ..."; system ("./update-mgmt-ip.pl"); exit 0 } }'

echo "Checking if SSH public keys are in order ..."
for i in *.full.conf; do
    grep root-authen $i > /dev/null
    if [ "$?" == "0" ]; then
        ./addkey2conf $i
    else
	echo "Skippping $i - not a Juniper router"
    fi
done

echo "Uploading configurations to the routers ..."
vmm ip | egrep -vi $EXCLUDES | gawk '{ print "scp -o \"StrictHostKeyChecking no\" "$1".full.conf root@"$2":router.conf" }' | sh -v

echo "Overriding current configuration ..."
vmm ip | egrep -vi $EXCLUDES | gawk '{ print "( /bin/cat << EOF\nedit\nload override router.conf\ncommit and-quit\nquit\nexit\nEOF\n ) | ssh -l root -o \"StrictHostKeyChecking no\" "$2" cli" }' | sh -v

echo "DONE! :-)"
