##==============================================================================
## Put headers in source files or update copyright dates.
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
use File::Copy;

my $workingPath = gets( ' Enter source path: ', '' );

my $MAX_HEADER_LINES = 40;
my $HEADER = "//".( '='x78 )."\n";
my $FOOTER = "//".( '-'x78 )."\n";
my $REMOVE_UTF8_BOM = 1;

print color 'bold white';
print "+ PATH:\n  $workingPath\n";

my @date = localtime( time );
my $year = $date[5] + 1900;

my @invalidFiles = ();
my $updatedFiles = 0;
my $insertedFiles = 0;
my $totalFiles = 0;
my @utf8Files = ();

recurse( $workingPath, \&insertHeader );

print color 'bold yellow';
print "   FINISHED:\n";
if ( scalar( @invalidFiles ) > 0 )
{
    print color 'bold red';
    print " - INVALID FILES (not modified, check manually)\n";
    for ( my $files = 0; $files < @invalidFiles; $files++ )
    {
        print '   ' . ( $files + 1 ) . " $invalidFiles[$files]\n";
    }
}
if ( $updatedFiles > 0 )
{
    print color 'bold magenta';
    print " - $updatedFiles updated\n";
}
if ( $insertedFiles > 0 )
{
    print color 'bold yellow';
    print " - $insertedFiles with inserted headers\n";
}
if ( scalar( @utf8Files ) > 0 )
{
    print color 'bold white';
    print " - files with UTF8 flag\n";
    for ( my $files = 0; $files < @utf8Files; $files++ )
    {
        print '   ' . ( $files + 1 ) . " $utf8Files[$files]\n";
    }
}
print color 'bold yellow';
print "   $totalFiles TOTAL\n";

##------------------------------------------------------------------------------
sub insertHeader
{
    local *addInvalidFile = sub
    {
        my $relativeFile = $_[0];
        my $utf8 = $_[1];

        print color 'bold red';
        print '  Invalid!: ' . $relativeFile;
        print color 'bold white';
        print $utf8 . "\n";
        push( @invalidFiles, $relativeFile );
    };

    local *shrink = sub
    {
        my $string = $_[0];
        my $size = $_[1];
        if ( length( $string ) > $size )
        {
            my $len = ( $size % 2 == 0 ) ? ( $size / 2 - 2 ) : ( $size - 3 ) / 2;
            $string = substr( $string, 0, $len )."...".substr( $string, length( $string ) - $len );
        }
        return $string;
    };

    my $file = $_[0];
    ## Check if the file is a source file.
    if ( $file !~ /.+\.(cpp|h|hx|js|cs)$/i )
    {
        return;
    }

    my $relativeFile = substr( $file, length( $workingPath ) + 1 );
    $totalFiles++;

    ## Create a valid header.
    my $sourceFile = substr( $file, rindex( $file, "/" ) + 1 );
    my $headerFile = "// $sourceFile\n";
    my $headerHolder = "// Copyright (c) $year, Bamtang Games. All Rights Reserved.\n";
    my $header = $HEADER . $headerFile . $headerHolder . $FOOTER;

    ## Read file
    open ( my $FILE, '<', $file ) or die( "Can't open $file: $!" );
        my @lines = <$FILE>;
    close( $FILE );

    my $lines = @lines;
    if ( $lines < 2 )
    {
        print color 'bold yellow';
        print "  Empty file: $relativeFile\n";
        push( @invalidFiles, $relativeFile );
        return;
    }

    my $changed = 0;

    ## Remove UTF8 BOM
    my $utf8 = '';
    if ( substr( $lines[0], 0, 2 ) eq "\xff\xfe" )
    {
        $utf8 = ' [UTF8]';
        push( @utf8Files, $relativeFile );
        addInvalidFile( $relativeFile, $utf8 );
        return;
    }
    if ( $REMOVE_UTF8_BOM && substr( $lines[0], 0, 3 ) eq "\xef\xbb\xbf" )
    {
        $lines[0] = substr( $lines[0], 3 );
        $utf8 = ' [UTF8]';
        push( @utf8Files, $relativeFile );
        $changed = 1;
    }

    ## Remove empty lines until comments or code
    my $bodyIndex = 0;
    my $countLines = @lines;
    for ( my $k = 0; $k < $countLines; $k++ )
    {
        if ( $lines[$k] !~ /^\s*\n$/ )
        {
            $bodyIndex = $k;
            last;
        }
    }
    if ( $bodyIndex > 0 )
    {
        splice( @lines, 0, $bodyIndex );
        $changed = 1;
    }

    ## Find header limits
    my $footer = 0;
    my $copyright = 0;
    $countLines = @lines;

    for ( my $k = 0; ( $k < $countLines ) && ( $k < $MAX_HEADER_LINES ); $k++ )
    {
        ## Replace incorrect length markers
        if ( ( $lines[$k] =~ /^\s*\/\/=+\s*\n$/ ) && ( $lines[$k] ne $HEADER ) )
        {
            $lines[$k] = $HEADER;
            $changed = 1;
        }
        if ( ( $lines[$k] =~ /^\s*\/\/-+\s*\n$/ ) && ( $lines[$k] ne $FOOTER ) )
        {
            $lines[$k] = $FOOTER;
            $changed = 1;
        }
        if ( $lines[$k] =~ /^\/\/  / )
        {
            $lines[$k] =~ s/^\/\/  /\/\/ /;
            $changed = 1;
        }
        if ( $lines[$k] !~ /^\/\/.*/ )
        {
            last;
        }

        $footer = $k if ( $lines[$k] eq $FOOTER );
        $copyright = $k if ( $lines[$k] =~ /Copyright \(c\)/ );
    }

    ## Check if file had a valid header.
    if ( ( $lines[0] eq $HEADER ) && ( $footer > 0 ) && ( $copyright > 0 ) )
    {
        if ( ( $lines[1] eq $headerFile ) && ( $lines[$copyright] eq $headerHolder )
                    && !$changed
                    && ( ( $lines[$footer + 1] =~ /^\s*\n$/ )
                            || ( $lines[$footer + 1] =~ /^\/\*/ ) ) )
        {
            ## Header is OK
            return;
        }
        elsif ( $lines[1] =~ /^\/\/\s\s*\S+\n$/ )
        {
            ## Update header
            print color 'bold magenta';
            print '  Updating: ' . shrink( $relativeFile, 68 );
            print color 'bold white';
            print $utf8 . "\n";
            $lines[1] = $headerFile;
            $lines[$copyright] = $headerHolder;
            if ( ( $lines[$footer + 1] !~ /^\s*\n$/ )
                    && ( $lines[$footer + 1] !~ /^\/\*/ ) )
            {
                splice( @lines, $footer + 1, 0, "\n" );
            }
            $updatedFiles++;
            open ( my $OUT, ">$file" ) || die ( "Error opening $file for writing.\n" );
                print $OUT @lines;
            close( $OUT );
            return;
        }
        ## It seems we have an invalid header.
        addInvalidFile( $relativeFile, $utf8 );
    }
    else
    {
        if ( $lines[0] ne $HEADER )
        {
            ## Inserting header.
            print color 'bold yellow';
            print '  Inserted: '.$relativeFile;
            print color 'bold white';
            print $utf8 . "\n";

            open ( my $OUT, ">$file" ) || die ( "Error opening $file for writing.\n" );
                print $OUT $header;
                if ( ( $lines[0] !~ /^\s*\n$/ ) && ( $lines[0] !~ /^\/\*/ ) )
                {
                    print $OUT "\n";
                }
                print $OUT @lines;
            close( $OUT );
            $insertedFiles++;
        }
        else
        {
            ## Invalid header.
            addInvalidFile( $relativeFile, $utf8 );
        }
    }
}

##------------------------------------------------------------------------------
sub recurse
{
    my $path = $_[0];
    my $onFileCallback = $_[1];

    ## Append a trailing / if it's not there.
    $path .= '/' if ( $path !~ /\/$/ );

    ## Loop through the files contained in the directory.
    for my $eachFile ( glob( $path.'*' ) )
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
