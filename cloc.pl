##==============================================================================
## Count lines of code
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;

my $files = 0;
my $filesCpp = 0;
my $filesJS = 0;
my $filesCS = 0;
my $filesOther = 0;
my $totalLines = 0;
my $commentLines = 0;
my $emptyLines = 0;
my %fileTypes;

my $workingPath = gets( ' Enter source path' );

print( " SCAN: $workingPath\n" );
recurse( $workingPath, \&countLines );
printf( "\n Finished\n\n" );
printf( " ======================\n" );
printf( "     C++ files: %7d\n", $filesCpp ) if ( $filesCpp > 0 );
printf( "      JS files: %7d\n", $filesJS ) if ( $filesJS > 0 );
printf( "      C# files: %7d\n", $filesCS ) if ( $filesCS > 0 );
printf( "   Other files: %7d\n", $filesOther ) if ( $filesOther > 0 );
if ( 0 )
{
    my @types = sort { $fileTypes{$b} <=> $fileTypes{$a} } keys %fileTypes;
    foreach my $type ( @types )
    {
        print "\t\t$type\t$fileTypes{$type}\n";
    }
}
printf( " ----------------------\n" );
printf( "   TOTAL FILES: %7d\n\n", $files );
printf( " ======================\n" );
printf( "   Empty lines: %7d\n", $emptyLines );
printf( " Comment lines: %7d\n", $commentLines );
printf( "    Code lines: %7d\n", $totalLines - $emptyLines - $commentLines );
printf( " ----------------------\n" );
printf( "   TOTAL LINES: %7d\n", $totalLines );
<STDIN>;

##------------------------------------------------------------------------------
sub countLines
{
    my $file = $_[0];
    $files++;
    print " $files files found...\r" if ($files % 50 == 0);


    ## Check if the file is a source file.
    my $js = ( $file =~ /.+\.js$/i );
    my $cpp = ( $file =~ /.+\.(cpp|h|hpp|c|inl)$/i );
    my $cs = ( $file =~ /.+\.cs$/i );

    if ( !$js && !$cpp && !$cs )
    {
        $filesOther++;
        if ( 0 )
        {
            my ( $type ) = $file =~ /\.([^.\/]+)$/;
            if ( defined $type )
            {
                if ( exists($fileTypes{$type}) )
                {
                    $fileTypes{$type} += 1;
                }
                else
                {
                    $fileTypes{$type} = 1;
                }
            }
            else
            {
                if ( exists($fileTypes{'...'}) )
                {
                    $fileTypes{'...'} += 1;
                }
                else
                {
                    $fileTypes{'...'} = 1;
                }
            }
        }
        return;
    }

    ## Read file
    open( my $FILE, '<', $file ) or die( "Can't open $file: $!" );
        my @lines = <$FILE>;
    close( $FILE );

    $filesCpp++ if $cpp;
    $filesJS++ if $js;
    $filesCS++ if $cs;
    $totalLines += @lines;

    my $line;

    for ( my $k = 0; $k < @lines; $k++ )
    {
        ## Process comments
        my $isComment = ( $lines[$k] =~ /^\s*\/\/.*/ );
        $commentLines++ if ( $isComment );

        ## Check for empty lines
        $emptyLines++ if ( $lines[$k] =~ /^\s*\n$/ );
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
    my $scaped = $path =~ /".+"/;

    ## Append a trailing / if it's not there.
    $path .= '/' if ( $path !~ /\/$/ );

    ## Loop through the files contained in the directory.
    for my $eachFile ( glob( $path.'*' ) )
    {
        if ( -d $eachFile )
        {
            $eachFile = "\"$eachFile\"" if ( $scaped );
            ## If the file is a directory, continue recursive scan.
            recurse( $eachFile, $onFileCallback );
        }
        else
        {
            $onFileCallback->( $eachFile );
        }
    }
}
