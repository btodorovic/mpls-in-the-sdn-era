#!/usr/bin/perl
#
# Update fxp0 addresses for vMX'es in full configs after a new "vmm bind".
# Useful if we save the full router configurations and later want to
# restore them again.
#

# use Net::CIDR;

sub addrandmask2cidr {
    my ($addr, $mask) = @_;

    $mask_packed = unpack ('N', ~pack ('C4', split(/\./, $mask)));
    for ($plen=32; $mask_packed>0; $plen--) {
        $mask_packed >>= 1;
    }
    return "$addr/$plen";
}

# - MAIN

open (BRCONF, "</vmm/data/server_data/bridge.conf") ||
    die "Could not open file /vmm/data/server_data/bridge.conf for reading\n";
while (<BRCONF>) {
    chomp;
    next if (!/^default/);
    @data = split(/\s+/);
    $gateway = $data[4];
    $netmask = $data[5];
    last;
}
close (BRCONF);

die "Could not determine subnet mask\n" if (!defined($netmask));

my $fxp = 0;
open (VMMIP, "/usr/bin/vmm ip | grep -vi MPC |") || die "Coud not execute \"vmm ip\".\n";
while (<VMMIP>) {
   chomp;
   ($rtr, $address) = split(/\s+/);
   $hostname{$rtr} = $rtr;
   $ip{$rtr} = $address;
}
close (VMMIP);

foreach $rtr (sort keys %hostname) {
    open (CONFIG, "<$rtr.full.conf") || next;
    open (NEWCONF, ">$rtr.full.new") || die;
    $old_gw = '';
    $fxp = 0;
    while (<CONFIG>) {
	chomp;
#	if (/fxp0\ \{/ || /em0\ \{/ || /ge-0\/0\/0\ / || /MgmtEth0/) {
	if (/fxp0\ \{/ || /em0\ \{/ || /MgmtEth0/) {
	    $fxp=1;
	    $trailer = (/MgmtEth0/ ? '' : ';');
	}
	if ($fxp && /address\ 10\./) {
	    $line = $_;
	    $line =~ s/address.*$/address\ /g;
            ($dummy, $preflen) = split(/\//, ($netaddr=addrandmask2cidr($ip{$rtr},$netmask)));
	    $line .= "$ip{$rtr}/$preflen$trailer";
	    print NEWCONF "$line\n";
	    $fxp=0;
	    next;
	} elsif (/backup-router/) {
	    $line = $old_gw = $_;
	    $line =~ s/backup-router.*/backup-router\ /g;
	    $old_gw =~ s/.*backup-router\ //g;
	    $old_gw =~ s/\;//g;
	    $line .= "$gateway;";
	    print NEWCONF "$line\n";
	    next;
	} elsif ($old_gw && index($_, $old_gw)>=0) {
	    s/$old_gw/$gateway/g;
	    print NEWCONF "$_\n";
	    next;
	} else {
	    print NEWCONF "$_\n";
	}
    }
    close (CONFIG);
    close (NEWCONF);
    system ("mv $rtr.full.new $rtr.full.conf");
}
