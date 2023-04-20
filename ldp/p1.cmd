edit
delete protocols isis source-packet-routing
set protocols ldp deaggregate
set protocols ldp interface lo0.0
set protocols ldp transport-address router-id
set protocols ldp track-igp-metric

set protocols ldp interface ge-0/0/1.0
set protocols ldp interface ge-0/0/2.0
set protocols ldp interface ge-0/0/3.0
set protocols ldp interface ge-0/0/4.0
set protocols ldp interface ge-0/0/5.0
commit and-quit
quit
