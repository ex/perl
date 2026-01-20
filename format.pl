##==============================================================================
## Applies basic code standard format to path
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------
use strict;
use warnings;
use diagnostics;
use Cwd qw();

##------------------------------------------------------------------------------
## Set this to 1 to only trim final spaces, empty new lines and fix indentation.
## This SHOULD BE SAFE, but check anyways some random files.
## Similar to setting to 1 ONLY_TRIM + ONLY_EMPTY_LINES + ONLY_INDENTATION
my $ONLY_SAFE = 1;

##------------------------------------------------------------------------------
## Set this to 1 to only trim final spaces
my $ONLY_TRIM = 0;

## Set this to 1 to only clean empty new lines
my $ONLY_EMPTY_LINES = 0;

## Set this to 1 to just check correct indentation by tabs or spaces
my $ONLY_INDENTATION = 0;

##------------------------------------------------------------------------------
## Set these flags to enable additional control if all above flags are zero
my $FIX_ALL = 0;
my $FIX_BRACES = 0;
my $FIX_PARENS = 0;
my $FIX_EQUALS = 0;
my $FIX_COLONS = 0;
my $FIX_OPERATORS = 0;
my $FIX_OTHER = 0;

##------------------------------------------------------------------------------
## Set this to 1 to use TABS instead of SPACES for indentation.
## This doesn't change all the spaces to tabs, just the initial spaces.
my $USE_TABS = 1;

##------------------------------------------------------------------------------
## If set to 1, this puts one space between parens, ie.: ( x == 1 )
## If set to 0, this removes spaces between parens, ie.: (x == 1)
my $SPACE_IN_PARENS = 0;

##------------------------------------------------------------------------------
## Set this to 3 to DELETE bad commented out source code like: //this.code = garbage (USE WITH CAUTION)
## Set this to 2 to only print the commented out source code
## Set this to 1 to only count lines of commented out source code
##
## In order to maintain commented code use: ////this.code = example or better use #if 0
## valid comments must be like: // comment
my $CLEAN_CODE = 0;

##------------------------------------------------------------------------------
## This checks if the formatted file is the same as the original file if all the
## whitespace characters are ignored. This is not fail safe because the format script
## could still wrongly modify a string and change a command or a regex expression, ie:
##     call("two cmds") -> call("twocmds")
##     regex("\q \\s") -> regex("\q\\s")
## and broke something. Currently no such cases have been found but caution is required
## whenever an automatic tool can modify all your project source files at once.
## You should always check your changes before committing.
my $CHECK_FORMAT = 1;

##------------------------------------------------------------------------------
## This checks if the file name follows guidelines for Unreal C++
my $CHECK_CPP_NAMES = 0;

##------------------------------------------------------------------------------
## This checks how many lines pass the limit, disables all format
my $ONLY_CHECK_LINE_SIZES = 0;
my $LINE_SIZE_MAX = 170;
my $DELETE_OVERSIZED_LINES = 0; ## Use with caution

##------------------------------------------------------------------------------
my @IGNORE_PATHS = ();

my $files = 0;
my $updated = 0;
my $totalLines = 0;
my $deletedComments = 0;
my $commentLines = 0;
my $emptyLines = 0;
my $fixedLines = 0;
my $workingPath;

if ( @ARGV )
{
    $workingPath = $ARGV[0];
    if ( @ARGV > 1 )
    {
        my $arg = $ARGV[1];
        if ( $arg eq '-trim' )
        {
            print( " FORMAT TRIM: $workingPath\n" );
            $ONLY_TRIM = 1;
            $ONLY_SAFE = 0; $ONLY_EMPTY_LINES = 0; $ONLY_INDENTATION = 0;
        }
        elsif ( $arg eq '-safe' )
        {
            print( " FORMAT SAFE: $workingPath\n" );
            $ONLY_SAFE = 1;
        }
        elsif ( $arg eq '-full' )
        {
            print( " FORMAT FULL: $workingPath\n" );
            $FIX_ALL = 1;
            $ONLY_SAFE = 0; $ONLY_TRIM = 0; $ONLY_EMPTY_LINES = 0; $ONLY_INDENTATION = 0;
        }
    }
}
else
{
    $workingPath = Cwd::cwd();
    print( " FORMAT: $workingPath\n" );
    print( " ONLY_SAFE\n" ) if ( $ONLY_SAFE );
}

recurse( $workingPath, \&formatFile );
print( " ----------------------\n" );
print( " TOTAL FILES: $files\n" );
print( "     UPDATED: $updated\n" );
print( " ----------------------\n" );
print( " TOTAL LINES: $totalLines\n" );
print( " FIXED LINES: $fixedLines\n" );
print( " EMPTY LINES: $emptyLines\n" );
print( "    COMMENTS: $commentLines\n" );
if ( $CLEAN_CODE > 0 )
{
    print( ( ( $CLEAN_CODE == 3 ) ? " DELETED COMMENTS: " : " COMMENTS TO DELETE: " ) . "$deletedComments\n" );
}
print( " [FINISHED]\n" );

##------------------------------------------------------------------------------
sub formatFile
{
    my $file = shift;

    ##--------------------------------------------------------------------------
    sub fixEquals
    {
        my $line = shift;
        $line =~ s/([^\-+*%&\^\/!=<>|\s\[])(?:\s{0}| {2,})=/$1 =/g;
        $line =~ s/=(?:\s{0}| {2,})([^=>\s])/= $1/g;
        $line =~ s/([^!=\s])(?:\s{0}|\s{2,})==/$1 ==/g;
        return $line;
    }
    ##--------------------------------------------------------------------------
    sub fixColons
    {
        my ( $line, $js ) = @_;

        if ( $line !~ /^\s*(case\s|\w+:|\w+\s+\w+:)/ )
        {
            $line =~ s/([^\\:\s])(?:\s{0}|\s{2,}):([^:])/$1 :$2/g;
        }
        $line =~ s/\):/\) :/g;
        if ( $js && ( $line !~ /\?.+:/ ) && ( $line !~ /:\s*$/ ) )
        {
            $line =~ s/([^():\s])(\s)+:/$1:/g;
        }
        $line =~ s/([^:]):(?:\s{0}| {2,})([^:\\\/\s])/$1: $2/g;

        return $line;
    }
    ##--------------------------------------------------------------------------
    sub fixOther
    {
        my ( $line, $cs, $ref ) = @_;

        if ( !$cs )
        {
            ## Don't format _?_ in C# due to nullable types and null-coalescing operator
            $line =~ s/(\S)\?/$1 \?/g;
        }
        $line =~ s/\?(\S)/\? $1/g;
        while ( $line =~ s/([^\s\[]),(\S)/$1, $2/g ) { }
        $line =~ s/([^(;])\s+;/$1;/g;

        if ( $line =~ /;{2,}\n/ )
        {
            $line =~ s/;{2,}\n/;\n/;
            $$ref = 1;
        }
        $line =~ s/;([^])\s\*])/; $1/g;

        ## Fix brackets
        $line =~ s/\[\s+(\S+)/\[$1/g;
        $line =~ s/(\S+)\s+\]/$1\]/g;
        $line =~ s/\[\s+\]/\[\]/g;
        return $line;
    }
    ##--------------------------------------------------------------------------
    sub fixBraces
    {
        my $line = shift;

        $line =~ s/\)\{/\) \{/g;
        $line =~ s/([^\[\s\(])\{\s*$/$1 \{\n/;
        $line =~ s/{(\S)/\{ $1/g;
        $line =~ s/(\S)\}/$1 \}/g;
        if ( $line !~ /(override|const|return|else|void)\s+\{/ )
        {
            $line =~ s/([\w+])\s+\{/$1\{/;
        }
        $line =~ s/([=|,]) \{ \}/$1 \{\}/;

        return $line;
    }
    ##--------------------------------------------------------------------------
    sub fixOperators
    {
        my ( $line, $cpp ) = @_;

        return $line if ( $cpp && ( $line =~ /^\s*#/ ) ); ## Ignore C++ #include <path/file>

        $line =~ s/(\S)%/$1 %/g;
        $line =~ s/%([^=\s])/% $1/g;

        $line =~ s/([^=])==(?:\s{0}|\s{2,})([^=\s])/$1== $2/g;
        $line =~ s/([!*+\-\/])=(?:\s{0}|\s{2,})([^=\s])/$1= $2/g;

        $line =~ s/([^*+eE\s()])(?:\s{0}|\s{2,})\+([^+])/$1 \+$2/g;
        $line =~ s/([^+(])\+(?:\s{0}|\s{2,})([^=+\s])/$1\+ $2/g;

        $line =~ s/=-(\S)/= -$1/;

        $line =~ s/([^(\-eE,:\[{\s])-([^\-=>\s])/$1 - $2/g;
        $line =~ s/([^\/*\s])\/([^=*\s])/$1 \/ $2/g;
        if ( $line =~ /\s*class\s+(\S+)*([^>\s&*\/,])/ )
        {
            $line =~ s/class\s+(\S+)\*([^>\s&*\/,])/class $1\* $2/;
        }
        else
        {
            $line =~ s/([^\/*[()>,;\s])\*([^)&=\/*,>\]\s])/$1 \* $2/g;
        }
        return $line;
    }
    ##--------------------------------------------------------------------------
    sub fixParens
    {
        my $line = shift;
        $line =~ s/(\s+)if\(/$1if \(/g;
        $line =~ s/(\s+)while\(/$1while \(/g;
        $line =~ s/(\s+)switch\(/$1switch \(/g;
        $line =~ s/(\s+)for\(/$1for \(/g;
        $line =~ s/(\s+)function\s+\(/$1function\(/g;
        if ( $SPACE_IN_PARENS )
        {
            while ( $line =~ s/\(([^)\s])/\( $1/g ) { }
            while ( $line =~ s/([^(\s])\)/$1 \)/g ) { }
        }
        else
        {
            while ( $line =~ s/\(\s+([^)\s])/\($1/g ) { }
            while ( $line =~ s/([^(\s])\s+\)/$1\)/g ) { }
        }
        $line =~ s/\(\s+\)/\(\)/g;
        return $line;
    }
    ##--------------------------------------------------------------------------
    sub replaceTabs
    {
        my $line = shift;
        $line =~ s/\t/    /g;
        return $line;
    }
    ##--------------------------------------------------------------------------
    sub replaceSpaces
    {
        my $line = shift;
        ## Ignore lines already starting with a TAB because they can be already aligned
        return $line if ( $line =~ /^(\t+).*/ );
        while ( $line =~ s/^(\t*)    (.*)/$1\t$2/ ) { } ## This must be a loop not /g
        $line =~ s/^ {1,3}([^*\t])/\t$1/;
        $line =~ s/^ {1,3}\t/\t/;
        return $line;
    }
    ##--------------------------------------------------------------------------
    sub rightTrim
    {
        my $line = shift;
        $line =~ s/[ \t]+$//;
        return $line;
    }
    ##--------------------------------------------------------------------------
    sub shrink
    {
        my $string = shift;
        my $size = shift;
        if ( length( $string ) > $size )
        {
            my $len = ( $size % 2 == 0 ) ? ( $size / 2 - 2 ) : ( $size - 3 ) / 2;
            $string = substr( $string, 0, $len )."...".substr( $string, length( $string ) - $len );
        }
        return $string;
    }
    ##--------------------------------------------------------------------------

    ## Check if the file is a source file.
    my $js = ( $file =~ /.+\.js$/i );
    my $cpp = ( $file =~ /.+\.(cpp|h|hpp|c|inl)$/i );
    my $cs = ( $file =~ /.+\.cs$/i );
    return if ( !$js && !$cpp && !$cs );

    ## Check if we must ignore the file
    for ( my $k = 0; $k < @IGNORE_PATHS; $k++ )
    {
        return if ( $file =~ /\Q$IGNORE_PATHS[$k]/ );
    }

    ## Check name of the file
    if ( $cpp && $CHECK_CPP_NAMES )
    {
        $file =~ /([^\/]+)$/;
        print "[ERROR NAME]: $file\n" if ( $1 !~ /^(Gui|Dt).+$/ );
    }

    return if ( $ONLY_SAFE + $ONLY_TRIM + $ONLY_EMPTY_LINES + $ONLY_INDENTATION + $FIX_ALL + $FIX_PARENS
              + $FIX_EQUALS + $FIX_OPERATORS + $FIX_OTHER + $FIX_BRACES + $FIX_COLONS + $ONLY_CHECK_LINE_SIZES == 0 );

    ## Read file
    open( my $handle, '<', $file ) or die( "Can't open $file: $!" );
        my @lines = <$handle>;
    close( $handle );


    my $trimmedFile;
    if ( $CHECK_FORMAT )
    {
        $trimmedFile = join( "", @lines );
        $trimmedFile =~ s/\s+//g;
    }

    $files++;
    $totalLines += @lines;

    my $line;
    my $lineChanged;
    my $wasEmpty = 0;
    my $changed = 0;
    my %changes = ();
    my $wasOpenBrace = 0;
    my $multipleSemiColon = 0;
    my $wasCopyright = 0;
    my $wasClass = 0;
    my $wasSeparator = 0;
    my $badCommentLines = 0;
    my $sizeOverflow = 0;

    for ( my $k = 0; $k < @lines; $k++ )
    {
        ####print "[$k] $lines[$k]";
        $lineChanged = 0;
        my $isComment = ( $lines[$k] =~ /^\s*\/\/.*/ );

        if ( $ONLY_CHECK_LINE_SIZES && !$isComment )
        {
            my $len = length( $lines[$k] );
            if ( ( $len > $LINE_SIZE_MAX ) && ( $lines[$k] !~ /^\s*(UE_LOG)\(/ ) )
            {
                $sizeOverflow += $len - $LINE_SIZE_MAX;
                print "[ERROR LINE SIZE]: $len\n$lines[$k]";
                if ( $DELETE_OVERSIZED_LINES )
                {
                    $changed = $lineChanged = 1;
                    $changes{'SIZE'} = 1;
                    $lines[$k] = '';
                }
            }
        }
        next if ( $ONLY_CHECK_LINE_SIZES);

        goto JUMP_CHECK_NEWLINES if ( $ONLY_EMPTY_LINES && !$ONLY_SAFE );
        goto JUMP_CHECK_INDENTATION if ( $ONLY_INDENTATION && !$ONLY_SAFE );

        $line = rightTrim( $lines[$k] );
        if ( $line ne $lines[$k] )
        {
            $changed = $lineChanged = 1;
            $changes{'TRIM'} = 1;
            $lines[$k] = $line;
        }

        next if ( $ONLY_TRIM && !$ONLY_SAFE );

JUMP_CHECK_INDENTATION:
        $line = $USE_TABS ? replaceSpaces( $lines[$k] ) : replaceTabs( $lines[$k] );
        if ( $line ne $lines[$k] )
        {
            $changed = $lineChanged = 1;
            $changes{$USE_TABS ? 'SPACES' : 'TABS'} = 1;
            $lines[$k] = $line;
        }
        next if ( $ONLY_INDENTATION && !$ONLY_SAFE );
        goto JUMP_CHECK_NEWLINES if ( $ONLY_SAFE );

        ## Process comments
        if ( ( $CLEAN_CODE > 0 ) && $isComment )
        {
            my $validComment = 0;
            if ( $lines[$k] =~ /^\s*\/\/[ !]*[*=-]+$/ ) ## Separators: //==== or // --- or //!----
            {
                $validComment = 1;
                $wasSeparator = !$wasSeparator;
                $wasCopyright = 0 if ( $wasCopyright );
                $wasClass = 0 if ( $wasClass );

                # print "$lines[$k]" if ($lines[$k] ne "//*****************************************************************************\n");

            }
            $validComment = ( $lines[$k] =~ /^\/\/$/ ) if ( !$validComment ); ## Header space: //
            $validComment = ( $lines[$k] =~ /^\s*\/\/\/\/[^\/]/ ) if ( !$validComment ); ## ////
            $validComment = ( $lines[$k] =~ /^\s*\/\/! +[^\s]/ ) if ( !$validComment );   ## //!
            $validComment = ( $lines[$k] =~ /^\s*\/\/ [\[<\d]/ ) if ( !$validComment );  ## // [ or // < or // 1.
            $validComment = ( $lines[$k] =~ /^\s*\/\/\$/ ) if ( $js && !$validComment ); ## //$
            $validComment = ( $lines[$k] =~ /^\s*\/\/#[A-Za-z]+/ ) if ( !$validComment ); ## //#if //#TODO //#define

            if ( !$validComment && ( $lines[$k] =~ /^\/\/\s+Copyright / ) )
            {
                $validComment = 1;
                $wasCopyright = 1;
            }
            if ( !$validComment && $wasCopyright )
            {
                $validComment = 1;
            }
            if ( !$validComment && ( $lines[$k] =~ /^\/\/\s+\S+\s+class\s+$/ ) )
            {
                $validComment = 1;
                $wasClass = 1;
            }
            if ( !$validComment && ( $wasClass || $wasSeparator ) )
            {
                $validComment = 1;
            }
            if ( !$validComment )
            {
                if ( $lines[$k] !~ /^\s*\/\/\s+(if|else|switch|while)\s+/ )
                {
                    $validComment = ( $lines[$k] =~ /^\s*\/\/ [A-Za-z"'\*\(\-]+.*/ );
                }

                ## Delete suspicious line comments
                if ( !$validComment )
                {
                    $badCommentLines++;
                    $deletedComments++;

                    if ( $CLEAN_CODE >= 2 )
                    {
                        print "$lines[$k]";
                        if ( $CLEAN_CODE == 3 )
                        {
                            $changed = $lineChanged = 1;
                            $changes{'CLEAN'} = 1;
                            $lines[$k] = $line = '';
                        }
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
        while ( ( $stripped =~ /('(?:[^\\']+|\\.)*')/ ) || ( $stripped =~ /(`(?:[^`]+)*`)/ ) )
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
            if ( $FIX_OPERATORS )
            {
                $line = fixOperators( $stripped, $cpp );
                if ( $line ne $stripped )
                {
                    ## print "OPS1: $stripped";
                    $changed = $lineChanged = 1;
                    $changes{'OPS'} = 1;
                    $stripped = $line;
                    ## print "OPS2: $line";
                }
            }
            if ( $FIX_ALL || $FIX_PARENS )
            {
                $line = fixParens( $stripped );
                if ( $line ne $stripped )
                {
                    $changed = $lineChanged = 1;
                    $changes{'PARENS'} = 1;
                    $stripped = $line;
                }
            }
            if ( $FIX_ALL || $FIX_BRACES )
            {
                $line = fixBraces( $stripped );
                if ( $line ne $stripped )
                {
                    $changed = $lineChanged = 1;
                    $changes{'BRACES'} = 1;
                    $stripped = $line;
                }
            }
            if ( $FIX_ALL || $FIX_EQUALS )
            {
                $line = fixEquals( $stripped );
                if ( $line ne $stripped )
                {
                    $changed = $lineChanged = 1;
                    $changes{'EQUALS'} = 1;
                    $stripped = $line;
                }
            }
            if ( $FIX_ALL || $FIX_OTHER )
            {
                $line = fixOther( $stripped, $cs, \$multipleSemiColon );
                if ( $line ne $stripped )
                {
                    $changed = $lineChanged = 1;
                    $changes{'OTHER'} = 1;
                    $stripped = $line;
                }
            }
            if ( $FIX_ALL || $FIX_COLONS )
            {
                $line = fixColons( $stripped, $js );
                if ( $line ne $stripped )
                {
                    $changed = $lineChanged = 1;
                    $changes{'COLONS'} = 1;
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
            print "\n[FATAL ERROR PARSING $file]:\n$newLine";
            exit 1;
        }
        $lines[$k] = $stripped if ( $stripped ne $lines[$k] );

        ## Check for empty lines
JUMP_CHECK_NEWLINES:
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
            }
            $wasEmpty = 1;
        }
        else
        {
            $wasEmpty = 0;
        }

        $fixedLines++ if ( $lineChanged );
        $wasOpenBrace = ( $lines[$k] =~ /^\s*{\s*$/ );

        if ( ( $lines[$k] =~ /^\s*}\s*$/ ) )
        {
            my $p = 1;
            while ( $lines[$k - $p] =~ /^\s*$/ )
            {
                $changed = $lineChanged = 1;
                $changes{'LINES'} = 1;
                $lines[$k - $p] = '';
                $p++;
            }
        }
    }

    if ( $changed )
    {
        if ( $CHECK_FORMAT && ( $CLEAN_CODE == 0 ))
        {
            my $fileChanged = join( "", @lines );
            $fileChanged =~ s/\s+//g;
            if ( $fileChanged ne $trimmedFile )
            {
                if ( !$FIX_OTHER || !$multipleSemiColon )
                {
                    print "[FATAL ERROR]\n$file changed file contents\n";
                    return;
                }
            }
        }

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
    if ( ( $CLEAN_CODE > 0 ) && ( $badCommentLines > 0 ) )
    {
        my $fileLines = @lines;
        print "$file\t$badCommentLines\t$fileLines\n";
    }
    if ( $ONLY_CHECK_LINE_SIZES && $sizeOverflow > 0 )
    {
        print "\tOVERSISE: $file\t$sizeOverflow\n";
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
