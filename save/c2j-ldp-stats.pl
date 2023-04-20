#!/usr/bin/perl

#....+....1....+....2....+....3....+....4....+....5....+....6....+....7....+.....8
# FEC(prefix)              Type                  Packets             Bytes Shared
# 192.168.111.111/32       Transit                 18963           1350783     No

$FEC='';
$ct_fec=0;
print " FEC(prefix)              Type                  Packets             Bytes Shared\n";
while (<STDIN>) {
    s/\r$//g;
    chomp;
    if (/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)/) {
        s/^(Mon|Tue|Wed|Thu|Fri|Sat|Sun)//g;
        s/\..*$//g;
        $date = $_;
        next;
    }
    if (/^[0-9]+/) {
        ($lbl, $lbl, $FEC, $iff, $nh, $octets) = split(/\s+/);
        if ($FEC !~ /\/32/) {
            $FEC='';
        }
        next;
    }
    if ($FEC && /Packets/) {
        s/.*witched:\s+//g;
        printf (" %-25sTransit %21s %17s     No\n", $FEC, $octets, $_);
        printf (" %-25sIngress %21s %17s     No\n", ' ', '0', '0');
        $FEC='';
        ++$ct_fec;
    }
}
print "$date, read statistics for $ct_fec FECs in 00:00:01 seconds (" . 2*$ct_fec . " queries)\n";
