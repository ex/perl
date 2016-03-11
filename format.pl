##==============================================================================
## Applies basic code standard format to path
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;

my $files = 0;
my $updated = 0;
my $totalLines = 0;
my $commentLines = 0;
my $emptyLines = 0;
my $fixedLines = 0;

my $workingPath = gets( ' Enter source path' );
#my $workingPath = '';

print( " FORMAT: $workingPath\n" );
recurse( $workingPath );
print( " ----------------------\n" );
print( " Finished:\n" );
print( " TOTAL FILES: $files\n" );
print( "     UPDATED: $updated\n" );
print( " ----------------------\n" );
print( " TOTAL LINES: $totalLines\n" );
print( " FIXED LINES: $fixedLines\n" );
print( " EMPTY LINES: $emptyLines\n" );
print( "    COMMENTS: $commentLines\n" );
<STDIN>;

##------------------------------------------------------------------------------
sub formatFile
{
    ##--------------------------------------------------------------------------
    local *fixOperators = sub
    {
        my $line = $_[0];
        my $cpp = $_[1];

        if ( $cpp && ( $line =~ /^\s*#/ ) )
        {
            ## TODO: Handle better C++: #include <path/file>
            return $line;
        }

        while ( $line =~ /[^\s]\?/ )
        {
            $line =~ s/([^\s])\?/$1 \?/;
        }
        while ( $line =~ /[^\s],[^\s]/ )
        {
            $line =~ s/([^\s]),([^\s])/$1, $2/;
        }
        while ( $line =~ /[\)_]:[\(_]/ )
        {
            $line =~ s/([\)_]):([\(_])/$1 : $2/;
        }
        while ( $line =~ /[^\s]%[^=\s]/ )
        {
            $line =~ s/([^\s])%([^=\s])/$1 % $2/;
        }
        while ( $line =~ /[^-+*\/!=<>\|\s]=[^=\s]/ )
        {
            $line =~ s/([^-+*\/!=<>\|\s])=([^=\s])/$1 = $2/;
        }
        while ( $line =~ /[^=\s]==[^=\s]/ )
        {
            $line =~ s/([^=\s])==([^=\s])/$1 == $2/;
        }
        while ( $line =~ /[^\s]!=[^=\s]/ )
        {
            $line =~ s/([^\s])!=([^=\s])/$1 != $2/;
        }
        while ( $line =~ /[^\*\+eE\s]\+\s+/ )
        {
            $line =~ s/([^\*\+eE\s])\+(\s)+/$1 \+$2/;
        }
        while ( $line =~ /\s+\+[^=\+\s]/ )
        {
            $line =~ s/\s+\+([^=\+\s])/ \+ $1/;
        }
        while ( $line =~ /[^-eE,:\[\s]-[^-=>\s]/ )
        {
            $line =~ s/([^-eE,:\[\s])-([^-=>\s])/$1 - $2/;
        }
        while ( $line =~ /[^\/\*\s]\/[^=\*\s]/ )
        {
            $line =~ s/([^\/\*\s])\/([^=\*\s])/$1 \/ $2/;
        }
        while ( $line =~ /[^\/\*\[\s]\*[^=\/\*,>\]\s]/ )
        {
            $line =~ s/([^\/\*\[\s])\*([^=\/\*,>\]\s])/$1 \* $2/;
        }
        return $line;
    };
    ##--------------------------------------------------------------------------
    local *fixParens = sub
    {
        my $line = $_[0];
        while ( $line =~ /\([^)\s]/ )
        {
            $line =~ s/\(([^)\s])/\( $1/g;
        }
        while ( $line =~ /[^(\s]\)/ )
        {
            $line =~ s/([^(\s])\)/$1 \)/g;
        }
        $line =~ s/\(\s+\)/\(\)/g;
        return $line;
    };
    ##--------------------------------------------------------------------------
    local *replaceTabs = sub
    {
        my $line = $_[0];
        $line =~ s/\t/    /g;
        return $line;
    };
    ##--------------------------------------------------------------------------
    local *rightTrim = sub
    {
        my $line = $_[0];
        $line =~ s/[ \t]+$//;
        return $line;
    };
    ##--------------------------------------------------------------------------
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
    my $js = ( $file =~ /.+\.js$/i );
    my $cpp = ( $file =~ /.+\.(cpp|h)$/i );

    ## Read file
    open( my $FILE, '<', $file ) or die( "Can't open $file: $!" );
        my @lines = <$FILE>;
    close( $FILE );

    $files++;
    $totalLines += @lines;

    my $line;
    my $lineChanged;
    my $wasEmpty = 0;
    my $changed = 0;
    my %changes = ();
    my $wasOpenBrace = 0;

    for ( my $k = 0; $k < @lines; $k++ )
    {
        $lineChanged = 0;
        $line = replaceTabs( $lines[$k] );
        if ( $line ne $lines[$k] )
        {
            $changed = $lineChanged = 1;
            $changes{'TABS'} = 1;
            $lines[$k] = $line;
        }
        $line = rightTrim( $lines[$k] );
        if ( $line ne $lines[$k] )
        {
            $changed = $lineChanged = 1;
            $changes{'TRIM'} = 1;
            $lines[$k] = $line;
        }

        if ( ( $line !~ /^\s*\/\// ) && ( $line !~ /^\s*\/?\*\**/ )
                                     ## TODO: Improve JS regex detection
                                     && ( !$js || ( $js && ( $line !~ /\/[^\*].*[^\*]\// ) ) ) )
        {
            ## Ignore final comments
            my $newLine = $line;
            my $comment = '';
            my $index = index( $newLine, '//' );
            if ( $index >= 0 )
            {
                $comment = substr( $newLine, $index );
                $newLine = substr( $newLine, 0, $index );
            }

            ## Extract strings
            my $stripped = $newLine;
            my %strs = ();
            my $counter = 0;
            while ( $stripped =~ /(""|"\\{2,}"|".*?[^\\]")/ )
            {
                $strs{"__s__$counter" . '_'} = $1;
                $stripped =~ s/\Q$1\E/__s__\Q$counter\E_/;
                $counter++;
            }
            while ( $stripped =~ /(''|'\\{2,}'|'.*?[^\\]')/ )
            {
                $strs{"__s__$counter" . '_'} = $1;
                $stripped =~ s/\Q$1\E/__s__\Q$counter\E_/;
                $counter++;
            }

            $line = fixParens( $stripped );
            if ( $line ne $stripped )
            {
                $changed = $lineChanged = 1;
                $changes{'PARENS'} = 1;
                $stripped = $line;
            }
            $line = fixOperators( $stripped, $cpp );
            if ( $line ne $stripped )
            {
                $changed = $lineChanged = 1;
                $changes{'OPS'} = 1;
                $stripped = $line;
            }

            ## Restore strings
            foreach my $key ( keys( %strs ) )
            {
                $stripped =~ s/\Q$key\E/$strs{$key}/;
            }

            ## Restore final comments
            if ( $index >= 0 )
            {
                $stripped .= $comment;
            }
            $lines[$k] = $stripped if ( $stripped ne $lines[$k] );
        }

        $commentLines++ if ( $lines[$k] =~ /^\s*\/\// );

        if ( $lines[$k] =~ /^\s*\n$/ )
        {
            if ( $wasEmpty || $wasOpenBrace )
            {
                $changed = $lineChanged = 1;
                $changes{'LINES'} = 1;
                $lines[$k] = '';
            }
            else
            {
                $emptyLines++;
                $wasEmpty = 1;
            }
        }
        else
        {
            $wasEmpty = 0;
        }

        $fixedLines++ if $lineChanged;

        $wasOpenBrace = ( $lines[$k] =~ /^\s*{\s*$/ );
        if ( ( $lines[$k] =~ /^\s*}\s*$/ ) && ( $lines[$k - 1] =~ /^\s*$/ ) )
        {
            $changed = $lineChanged = 1;
            $changes{'LINES'} = 1;
            $lines[$k - 1] = '';
        }
    }

    if ( $changed )
    {
        my $mods = '';
        for my $mod ( keys %changes )
        {
            $mods .= " $mod";
        }
        my $fileChanged = $file;
        $fileChanged =~ s/\Q$workingPath\E\///i;
        print " @{[shrink($fileChanged, 68)]}$mods\n";
        open( my $OUT, ">$file" ) or die ( "Error opening $file for writing.\n" );
            print $OUT @lines;
        close( $OUT );
        $updated++;
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
	if ( ( $ret eq "" ) && ( defined $_[1] ) )
    {
        $ret = $_[1];
    }
    return $ret;
}

##------------------------------------------------------------------------------
sub recurse
{
    my $path = $_[0];

    ## Append a trailing / if it's not there.
    $path .= '/' if ( $path !~ /\/$/ );

    ## Loop through the files contained in the directory.
    for my $eachFile ( glob( $path.'*' ) )
    {
        if ( -d $eachFile )
        {
            ## If the file is a directory, continue recursive scan.
            recurse( $eachFile );
        }
        else
        {
            ## Check if the file is a source file.
            if ( $eachFile =~ /.+\.(hx|cpp|h|js)$/i )
            {
                formatFile( $eachFile );
            }
        }
    }
}
