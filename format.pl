##==============================================================================
## Applies basic code standard format to path
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;

## Set this to 2 to clean source code commented out like: //this.code = garbage
## In order to maintain commented code use: ////this.code = example
## Set this to 1 to only print the comment lines that would be deleted
my $CLEAN_CODE = 0;

my $JS_FIX_STRINGS = 1;

## Set this to 1 to use TABS instead of SPACES for indentation.
## This doesn't change all the spaces to tabs, just the initial spaces.
my $USE_TABS = 1;

my $files = 0;
my $updated = 0;
my $totalLines = 0;
my $deletedComments = 0;
my $commentLines = 0;
my $emptyLines = 0;
my $fixedLines = 0;

my $workingPath = gets( ' Enter source path' );
##my $workingPath = '';

print( " FORMAT: $workingPath\n" );
recurse( $workingPath, \&formatFile );
print( " ----------------------\n" );
print( " Finished:\n" );
print( " TOTAL FILES: $files\n" );
print( "     UPDATED: $updated\n" );
print( " ----------------------\n" );
print( " TOTAL LINES: $totalLines\n" );
print( " FIXED LINES: $fixedLines\n" );
print( " EMPTY LINES: $emptyLines\n" );
print( "    COMMENTS: $commentLines\n" );
print( " DELETED COMMENTS: $deletedComments\n" ) if $CLEAN_CODE;
<STDIN>;

##------------------------------------------------------------------------------
sub formatFile
{
    ##--------------------------------------------------------------------------
    local *fixOperators = sub
    {
        my $line = shift;
        my $cpp = shift;
        my $cs = shift;
        my $js = shift;

        if ( $cpp && ( $line =~ /^\s*#/ ) )
        {
            ## Ignore C++: #include <path/file>
            return $line;
        }
        if ( !$cs )
        {
            ## Don't format _?_ in C# due to nullable types and null-coalescing operator
            while ( $line =~ s/(\S)\?/$1 \?/ ) { }
        }

        while ( $line =~ s/([^\s\[]),(\S)/$1, $2/ ) { }

        if ( $line !~ /^\s*(case\s|\w+:|\w+\s+\w+:)/ )
        {
            while ( $line =~ s/([^\\:\s])(?:\s{0}|\s{2,}):([^:])/$1 :$2/ ) { }
        }
        while ( $line =~ s/\):/\) :/ ) { }
        if ( $js && ( $line !~ /\?.+:/ ) && ( $line !~ /:\s*$/ ) )
        {
            while ( $line =~ s/([^():\s])(\s)+:/$1:/ ) { }
        }
        while ( $line =~ s/([^:]):(?:\s{0}|\s{2,})([^:\\\/\s])/$1: $2/ ) { }

        while ( $line =~ s/(\S)%([^=\s])/$1 % $2/ ) { }

        while ( $line =~ s/([^\-+*\/!=<>|\s\[])=([^=\s])/$1 = $2/ ) { }

        while ( $line =~ s/([^!=\s])(?:\s{0}|\s{2,})==/$1 ==/ ) { }
        while ( $line =~ s/([^=])==(?:\s{0}|\s{2,})([^=\s])/$1== $2/ ) { }

        while ( $line =~ s/([!*+\-\/])=(?:\s{0}|\s{2,})([^=\s])/$1= $2/ ) { }

        while ( $line =~ s/([^*+eE\s])(?:\s{0}|\s{2,})\+([^+])/$1 \+$2/ ) { }
        while ( $line =~ s/([^+])\+(?:\s{0}|\s{2,})([^=+\s])/$1\+ $2/ ) { }

        $line =~ s/=-(\S)/= -$1/;

        while ( $line =~ s/([^\-eE,:\[\s])-([^\-=>\s])/$1 - $2/ ) { }

        while ( $line =~ s/([^\/*\s])\/([^=*\s])/$1 \/ $2/ ) { }

        while ( $line =~ s/([^\/*\[\s])\*([^=\/*,>\]\s])/$1 \* $2/ ) { }

        while ( $line =~ s/([^(;])\s+;/$1;/ ) { }

        while ( $line =~ s/([^\[\s])\{/$1 \{/ ) { }
        while ( $line =~ s/{(\S)/\{ $1/ ) { }
        while ( $line =~ s/(\S)\}/$1 \}/ ) { }
        $line =~ s/([=|,]) \{ \}/$1 \{\}/;

        $line =~ s/;{2,}\n/;\n/;
        while ( $line =~ s/;(\S)/; $1/ ) { }

        return $line;
    };
    ##--------------------------------------------------------------------------
    local *fixParens = sub
    {
        my $line = shift;
        $line =~ s/ if\(/ if \(/g;
        $line =~ s/ while\(/ while \(/g;
        $line =~ s/ switch\(/ switch \(/g;
        $line =~ s/ for\(/ for \(/g;
        $line =~ s/ function\s+\(/ function\(/g;
        while ( $line =~ s/\(([^)\s])/\( $1/ ) { }
        while ( $line =~ s/([^(\s])\)/$1 \)/ ) { }
        $line =~ s/\(\s+\)/\(\)/g;
        return $line;
    };
    ##--------------------------------------------------------------------------
    local *fixBrackets = sub
    {
        my $line = shift;
        while ( $line =~ s/\[\s+(\S+)/\[$1/ ) { }
        while ( $line =~ s/(\S+)\s+\]/$1\]/ ) { }
        $line =~ s/\[\s+\]/\[\]/g;
        return $line;
    };
    ##--------------------------------------------------------------------------
    local *replaceTabs = sub
    {
        my $line = shift;
        $line =~ s/\t/    /g;
        return $line;
    };
    ##--------------------------------------------------------------------------
    local *replaceSpaces = sub
    {
        my $line = shift;
        ## Ignore lines already starting with a TAB because they can be already aligned
        return $line if ( $line =~ /^(\t+).*/ );
        while ( $line =~ s/^(\t*)    (.*)/$1\t$2/ ) { }
        return $line;
    };
    ##--------------------------------------------------------------------------
    local *rightTrim = sub
    {
        my $line = shift;
        $line =~ s/[ \t]+$//;
        return $line;
    };
    ##--------------------------------------------------------------------------
    local *shrink = sub
    {
        my $string = shift;
        my $size = shift;
        if ( length( $string ) > $size )
        {
            my $len = ( $size % 2 == 0 ) ? ( $size / 2 - 2 ) : ( $size - 3 ) / 2;
            $string = substr( $string, 0, $len )."...".substr( $string, length( $string ) - $len );
        }
        return $string;
    };

    my $file = $_[0];

    ## Check if the file is a source file.
    my $js = ( $file =~ /.+\.js$/i );
    my $cpp = ( $file =~ /.+\.(cpp|h|c|inl)$/i );
    my $cs = ( $file =~ /.+\.cs$/i );
    return if ( !$js && !$cpp && !$cs );

    ## Read file
    open( my $handle, '<', $file ) or die( "Can't open $file: $!" );
        my @lines = <$handle>;
    close( $handle );

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
        $line = rightTrim( $lines[$k] );
        if ( $line ne $lines[$k] )
        {
            $changed = $lineChanged = 1;
            $changes{'TRIM'} = 1;
            $lines[$k] = $line;
        }
        $line = $USE_TABS ? replaceSpaces( $lines[$k] ) : replaceTabs( $lines[$k] );
        if ( $line ne $lines[$k] )
        {
            $changed = $lineChanged = 1;
            $changes{$USE_TABS ? 'SPACES' : 'TABS'} = 1;
            $lines[$k] = $line;
        }

        ## Process comments
        my $isComment = ( $lines[$k] =~ /^\s*\/\/.*/ );
        if ( ( $CLEAN_CODE > 0 ) && $isComment )
        {
            my $validComment = ( $lines[$k] =~ /^\s*\/\/[=-]+$/ );  ## Separators: //========= or //----------
            $validComment = ( $lines[$k] =~ /^\/\/$/ ) if ( !$validComment ); ## Header space: //
            $validComment = ( $lines[$k] =~ /^\s*\/\/\/\/[^\/]/ ) if ( !$validComment ); ## ////
            $validComment = ( $lines[$k] =~ /^\s*\/\/! [^\s]/ ) if ( !$validComment );   ## //!
            $validComment = ( $lines[$k] =~ /^\s*\/\/ [\[<\d]/ ) if ( !$validComment );  ## // [ or // < or // 1.
            $validComment = ( $js && ( $lines[$k] =~ /^\s*\/\/\$/ ) ) if ( !$validComment ); ## //$

            if ( !$validComment )
            {
                $validComment = ( $lines[$k] =~ /^\s*\/\/ [A-Za-z]+.*/ );
                ## Delete suspicious line comments
                if ( !$validComment )
                {
                    $deletedComments++;
                    $changed = $lineChanged = 1;
                    $changes{'CLEAN'} = 1;
                    if ( $CLEAN_CODE == 1 )
                    {
                        print "$lines[$k]";
                    }
                    else
                    {
                        $lines[$k] = $line = '';
                    }
                }
            }
        }
        $commentLines++ if ( $isComment );

        ## Extract strings
        my %strs = ();
        my $counter = 0;
        my @keys = ();

        my $stripped = $line;
        while ( $stripped =~ /('(?:[^\\']+|\\.)*')/ )
        {
            my $s = $1;
            push( @keys, "___s___$counter" . '_' );
            $strs{"___s___$counter" . '_'} = $1;
            $stripped =~ s/\Q$1\E/___s___\Q$counter\E_/;
            $counter++;
        }

        while ( $stripped =~ /("(?:[^\\"]+|\\.)*")/ )
        {
            my $s = $1;
            push( @keys, "___s___$counter" . '_' );
            $strs{"___s___$counter" . '_'} = $s;
            $stripped =~ s/\Q$s\E/___s___\Q$counter\E_/;
            if ( $JS_FIX_STRINGS && $js && !$isComment && $s !~ /\\n|___s___|\\t|\\"|'/ )
            {
                $strs{"___s___$counter" . '_'} =~ s/"/'/g;
                $changed = $lineChanged = 1;
                $changes{'STRINGS'} = 1;
            }
            $counter++;
        }

        ## Ignore final comments
        my $newLine = $stripped;
        my $comment = '';
        my $index = index( $newLine, '//' );
        if ( $index >= 0 )
        {
            $comment = substr( $newLine, $index );
            $newLine = substr( $newLine, 0, $index );
        }
        $stripped = $newLine;

        if ( !$isComment && ( $newLine !~ /^\s*\/?\*\**/ )
                         ## TODO: Improve lame JS regex detection
                         && ( !$js || ( $js && ( ( $newLine !~ /\/[^\*].*[^\*]\// )
                                              && ( $newLine !~ /\/\S+\// ) ) ) ) )
        {

            ## Don't mess with JS oneliner casts
            if ( $js && ( $stripped =~ /(\/\*\* \@type \{.+\}\s*\*\/)/ ) )
            {
                push( @keys, "___s___$counter" . '_' );
                $strs{"___s___$counter" . '_'} = $1;
                $stripped =~ s/\Q$1\E/___s___\Q$counter\E_/;
                $counter++;
            }

            $line = fixParens( $stripped );
            if ( $line ne $stripped )
            {
                $changed = $lineChanged = 1;
                $changes{'PARENS'} = 1;
                $stripped = $line;
            }

            $line = fixOperators( $stripped, $cpp, $cs, $js );
            if ( $line ne $stripped )
            {
                $changed = $lineChanged = 1;
                $changes{'OPS'} = 1;
                $stripped = $line;
            }

            if ( $cpp || $cs )
            {
                $line = fixBrackets( $stripped );
                if ( $line ne $stripped )
                {
                    $changed = $lineChanged = 1;
                    $changes{'BRACKETS'} = 1;
                    $stripped = $line;
                }
            }

        }

        ## Restore final comments
        if ( $index >= 0 )
        {
            $stripped .= $comment;
        }

        ## Restore strings
        for( my $q = @keys - 1; $q >= 0; $q-- )
        {
            $stripped =~ s/\Q$keys[$q]\E/$strs{$keys[$q]}/;
        }

        ## Check if stripped line is OK
        if ( $stripped =~ /___s___/ )
        {
            print "\nERROR PARSING:\n$newLine";
            $stripped = $lines[$k];
        }

        $lines[$k] = $stripped if ( $stripped ne $lines[$k] );

        ## Check for empty lines
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

        $fixedLines++ if ( $lineChanged );

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
    $ret = $_[1] if ( ( $ret eq "" ) && ( defined $_[1] ) );
    return $ret;
}

##------------------------------------------------------------------------------
sub recurse
{
    my $path = shift;
    my $onFileCallback = shift;
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
            ## If the file is a directory, continue recursive scan.
            recurse( $eachFile, $onFileCallback );
        }
        else
        {
            $onFileCallback->( $eachFile );
        }
    }
}
