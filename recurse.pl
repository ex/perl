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
    my $file = shift;
    print "\t$file\n";
    print $outputFile "$file\n";
}

##------------------------------------------------------------------------------
sub printFolder
{
    my $folder = shift;
    print "[$folder]\n";
    print $outputFile "$folder\n";
    return; ## it needs tho return undef or 0 because print returns 1
}

##------------------------------------------------------------------------------
sub recurse
{
    my $path = shift;
    my $onFileCallback = shift;
    ## This can return 1 to cancel recursive scan or be undefined to process all files
    my $onFolderCallback = shift;
    my $scaped = $path =~ /".+"/;

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
            else
            {
                recurse( $eachFile, $onFileCallback, $onFolderCallback );
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
