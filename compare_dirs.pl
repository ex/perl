##==============================================================================
## Compare two source trees.
## Install perl modules:
##      cmd> cpan install Win32::Console::ANSI
##      cmd> cpan install Term::ANSIColor
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;
use Win32::Console::ANSI;
use Term::ANSIColor;
use File::Basename;

my $IGNORE_HEADER_UPDATE = 1;

my $workingPath = gets( ' Enter source path: ', '' );
my $comparePath = gets( ' Enter path to compare: ', '' );

print color 'bold white';
print "$workingPath\n";

my $missing = 0;
my $different = 0;

recurse( $workingPath, \&compareDirs, 0 );

print color 'bold yellow';
print "   FINISHED:\n";

##------------------------------------------------------------------------------
sub compareDirs
{
    my $fileA = $_[0];
    my $depth = $_[1];
    my $fileB = $comparePath . '/' . substr( $fileA, length( $workingPath ) + 1 );
    if (!  -e $fileB )
    {
        printLeaf( $fileA, $depth, 0, 1 );
        print color 'bold white';
        print " MISSING\n";
        $missing++;
    }
    if ( $fileA =~ /.+\.(cpp|h|hx|js|cs)$/i )
    {
        my $lines = 0;
        my $chars = 0;
        my $charA = '';
        my $charB = '';
        my $line = 0;

        open( my $handleA, '<', $fileA ) or die( "Can't open $fileA: $!" );
        open( my $handleB, '<', $fileB ) or die( "Can't open $fileB: $!" );

        while ( my $lineA = <$handleA> )
        {
            $line++;

            my $lineB;
            while ( $lineB = <$handleB> )
            {
                last if ( $lineA eq $lineB );
                $lines++;
                last if ( length( $lineB ) > 2 );
            }
            next if ( !defined $lineB );

            if ( $lineA ne $lineB )
            {
                for my $i ( 0 .. length( $lineA ) - 1 )
                {
                    my $cA = substr( $lineA, $i, 1 );
                    if ( $i < length( $lineB ) )
                    {
                        my $cB = substr( $lineB, $i, 1 );
                        if ( $cA ne $cB )
                        {
                            $charA = $cA;
                            $charB = $cB;
                            $chars++;
                        }
                    }
                    else
                    {
                        $chars++;
                    }
                }
            }
        }
        while ( my $lineB = <$handleB> )
        {
            $lines++;
        }
        close($handleA );
        close($handleB );

        if ( $lines != 0 )
        {
            if ( !$IGNORE_HEADER_UPDATE || ( $IGNORE_HEADER_UPDATE
                            && ( ( $lines !=  1 ) || ( $chars !=  1 ) || ( $charA ne '6' ) || ( $charB ne '7' ) ) ) )
             {
                printLeaf( $fileA, $depth, 0, 1 );
                print color 'bold white';
                print " [$lines] $chars\n";
            }
        }
    }
##    else
##    {
##        printLeaf( $file, $depth, 0, 0 );
##        print "\n";
##    }
}

##------------------------------------------------------------------------------
sub printLeaf
{
    my $file = basename( $_[0] );
    my $depth = $_[1];
    my $isDir = $_[2];
    my $error = $_[3];
    print color 'clear green';
    foreach my $k ( 0 .. $depth - 1 )
    {
        print ' |  ';
    }
    if ( $isDir )
    {
        print color 'clear yellow';
        print '[+] ';
        print color ( $error ? 'bold red' : 'bold yellow' );
        print "$file";
    }
    else
    {
        print ' |- ';
        print color ( $error ? 'bold red' : 'bold green' );
        print "$file";
    }
}

##------------------------------------------------------------------------------
sub recurse
{
    my $path = $_[0];
    my $onFileCallback = $_[1];
    my $depth = $_[2];

    ## Append a trailing / if it's not there.
    $path .= '/' if ( $path !~ /\/$/ );

    ## Loop through the files contained in the directory.
    for my $eachFile ( glob( $path . '*' ) )
    {
        if ( -d $eachFile )
        {
            ## If the file is a directory, continue recursive scan.
            printLeaf( $eachFile, $depth, 1 );
            print "\n";
            recurse( $eachFile, $onFileCallback, $depth + 1 );
        }
        else
        {
            $onFileCallback->( $eachFile, $depth );
        }
    }
}

##------------------------------------------------------------------------------
sub gets
{
    if ( defined $_[0] )
    {
        print( ( defined $_[1] ) ? " $_[0] ($_[1]) " : " $_[0] " );
    }
	my $ret = <STDIN>;
	chomp( $ret );
	$ret = $_[1] if ( ( $ret eq "" ) && ( defined $_[1] ) );
    return $ret;
}
