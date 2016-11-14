
use strict;
use warnings;

my $path = gets( ' Enter path' );
##my $path = '';

foreach my $file ( glob( "$path/*.png" ) )
{
    my $newFile = $file;
    if ( $newFile =~ s/string_to_delete// )
    {
        print `mv \"$file\" \"$newFile\"`;
    }
}

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
