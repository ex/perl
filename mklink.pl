##==============================================================================
## Creates a virtual link to path on clipboard
## It needs Administrator rights
##------------------------------------------------------------------------------
use strict;
use warnings;
use diagnostics;
use Win32::RunAsAdmin qw(force);
use Win32::Clipboard;

my $path = trim( Win32::Clipboard()->Get() );

die( "Can't find path [$path]" ) if ( ! -e $path );

print "Creating symbolic link to $path\n";

system( "mklink /D newSite $path" );

##------------------------------------------------------------------------------
sub trim
{
    my $string = $_[0];
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}
