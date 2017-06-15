##==============================================================================
## Creates a labels track for Audacity using a lyrics text file
## Input ask for the start of lyrics and the time when lyrics end.
## The lyrics file must end with the last song lyrics line.
## Add empty lines for long parts with no lyrics in the song.
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------
use strict;
use warnings;

my $NEW_LINE_SPACE = 5;
my $EMPTY_LINE_SPACE = 10;

my $namefile = gets( "File with lyrics" );
##my $namefile = 'C:\Users\ex\Documents\Cendrillon.txt';
my $start = gets( "lyrics start in seconds", 13.2 );
die( "invaid start!" ) if ( $start < 0 );
my $end = gets( "lyrics end in seconds", 231.1 );
die( "invaid end!" ) if ( $end <= 0 || $start > $end - 5 );

my @lyrics = ();
my $spaces = 0;

open( my $file, "<", $namefile ) or die( "Can't open [$namefile]: $!" );
while ( my $line = <$file> )
{
    $line = trim( $line );
    my $len = length( $line );
    $spaces += ( $len > 0 ) ? $len + $NEW_LINE_SPACE : $EMPTY_LINE_SPACE;
    push( @lyrics, $line );
}
close( $file );

## Discard added space for last line new line
$spaces -= $NEW_LINE_SPACE;

## Discard empty line new line
for ( my $index = scalar @lyrics - 1; $index >= 0; --$index )
{
    last if ( length $lyrics[$index] > 0 );
    splice( @lyrics, $index, 1 );
    $spaces -= $EMPTY_LINE_SPACE;
}

my $delta = ( $end - $start ) / $spaces;
print( "delta: $delta\n\n" );

open( my $track, ">", $namefile . '.labels.txt' ) or die( "Can't create track file: $!" );
for my $line ( @lyrics )
{
    my $len = length $line;
    if ( $len > 0 )
    {
        $end = $start + $delta * $len;
        print( $track sprintf( "%.3f", $start )."\t".sprintf( "%0.3f", $end )."\t$line\n" );
        print( sprintf( "%.3f", $start )."\t".sprintf( "%.3f", $end )."\t$len\t$line\n" );
        $start = $end + $NEW_LINE_SPACE * $delta;
    }
    else
    {
        $end = $start + $EMPTY_LINE_SPACE * $delta;
        print( sprintf( "%.3f", $start )."\n" );
        $start += $EMPTY_LINE_SPACE * $delta;
    }
}
close( $track );

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

##------------------------------------------------------------------------------
sub trim
{
    my $string = $_[0];
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
    return $string;
}

