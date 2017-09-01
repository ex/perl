##==============================================================================
## Search for annotations of type: "* @annotation"
##------------------------------------------------------------------------------
use strict;
use warnings;
use Data::Dumper;

my $namefile = gets( "File" );
my %types;

open( my $file, "<", $namefile ) or die( "Can't open [$namefile]: $!" );
while ( my $line = <$file> )
{
    if ( $line =~ /\* @(\S+) / )
    {
        $types{$1} = ( !defined $types{$1} ) ? 1 : $types{$1} + 1;
    }
}
close( $file );
print Dumper( %types );

##------------------------------------------------------------------------------
sub gets
{
    if ( defined $_[0] )
    {
        print( ( defined $_[1] ) ? "$_[0] ($_[1]): " : "$_[0]: " );
    }
	my $ret = <STDIN>;
	chomp( $ret );
	$ret = $_[1] if ( ( $ret eq "" ) && ( defined $_[1] ) );
    return $ret;
}
