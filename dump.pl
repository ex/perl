##==============================================================================
## Dumps whole folder source code into single file
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;
use File::Basename;

my $STRIP_SPACES = 1;

my $files = 0;
my $totalLines = 0;

my $workingPath = gets( ' Enter source path' );
die( "Path too short: $workingPath" ) if ( length( $workingPath ) < 4 );
die( "Not a directory: $workingPath" ) if (! -d $workingPath );

open( my $output, '>', $workingPath . '_dump.txt' ) or die( "$!" );
print( " DUMP: $workingPath\n" );
recurse( $workingPath, \&dumpFile );
close( $output );

print( " ----------------------\n" );
print( " Finished:\n" );
print( " TOTAL FILES: $files\n" );
print( " TOTAL LINES: $totalLines\n" );
print( " ----------------------\n" );

##------------------------------------------------------------------------------
sub dumpFile
{
    my $file = shift;

    ## Check if the file is a source file.
    my $js = ( $file =~ /.+\.js$/i );
    my $cpp = ( $file =~ /.+\.(cpp|h)$/i );
    my $cs = ( $file =~ /.+\.cs$/i );
    return if ( ( $file !~ /.+\.hx$/i ) && !$js && !$cpp && !$cs );

    ## Read file
    open( my $handle, '<', $file ) or die( "Can't open $file: $!" );
        my @lines = <$handle>;
    close( $handle );

    $files++;
    $totalLines += @lines;

    print $output "\n//" . basename( $file ) . "\n";
    for ( my $k = 0; $k < @lines; $k++ )
    {
        my $line = $lines[$k];
        $line =~ s/[^\S\n]//g if $STRIP_SPACES;
        print $output $line;
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

##------------------------------------------------------------------------------
sub recurse
{
    my $path = shift;
    my $onFileCallback = shift;

    ## Append a trailing / if it's not there.
    $path .= '/' if ( $path !~ /\/$/ );

    ## Loop through the files contained in the directory.
    for my $eachFile ( glob( $path . '*' ) )
    {
        if ( -d $eachFile )
        {
            ## If the file is a directory, continue recursive scan.
            recurse( $eachFile, $onFileCallback );
        }
        else
        {
            $onFileCallback->( $eachFile );
        }
    }
}
