use strict;
use warnings;
use diagnostics;
use Win32::RunAsAdmin qw( force );

system( "netsh interface set interface name=Ethernet admin=disabled" );

