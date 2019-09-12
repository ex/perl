##==============================================================================
## Traverse file paths
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------
use strict;
use warnings;
use diagnostics;

my $outputFile;
my $workingPath = gets( ' Enter path' );

print( " Recurse: $workingPath\n" );
open( $outputFile, '>', "output.txt" ) or dieError( "Can't create output: $!" );
    recurse( $workingPath, \&printFile, \&printFolder );
close( $outputFile );

##------------------------------------------------------------------------------
sub printFile
{
    my $file = $_[0];
    print "\t$file\n";
    print $outputFile "$file\n";
}

##------------------------------------------------------------------------------
sub printFolder
{
    my $folder = $_[0];
    print "[$folder]\n";
    print $outputFile "$folder\n";
}

##------------------------------------------------------------------------------
sub recurse
{
    my $path = shift;
    my $onFileCallback = shift;
    my $onFolderCallback = shift; ## This can return 1 to cancel recursive scan
    my $scaped = $path =~ /".+"/;

    die( "Path too short: $path" ) if ( length( $path ) < 4 );
    if ( ( -e $path ) && ( ! -d $path ) )
    {
        $onFileCallback->( $path ) if ( defined $onFileCallback );
        return;
    }

    ## Append a trailing / if it's not there.
    $path .= '/' if ( $path !~ /\/$/ );

    ## Loop through the files contained in the directory.
    for my $eachFile ( glob( $path . '*' ) )
    {
        if ( -d $eachFile )
        {
            $eachFile = "\"$eachFile\"" if ( $scaped );
            if ( defined $onFolderCallback )
            {
                if ( !$onFolderCallback->( $eachFile ) )
                {
                    ## If is a directory and can continue recursive scan.
                    recurse( $eachFile, $onFileCallback, $onFolderCallback );
                }
            }
        }
        elsif ( defined $onFileCallback )
        {
            $onFileCallback->( $eachFile );
        }
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
