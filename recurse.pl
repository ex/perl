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
    my $onFolderCallback = shift;
    my $scaped = $path =~ /".+"/;

    die( "Path too short: $path" ) if ( length( $path ) < 4 );
    if ( ( -e $path ) && ( ! -d $path ) )
    {
        $onFileCallback->( $path );
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
            $onFolderCallback->( $eachFile ) if defined $onFolderCallback;

            ## If the file is a directory, continue recursive scan.
            recurse( $eachFile, $onFileCallback, $onFolderCallback );
        }
        else
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
