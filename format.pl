##==============================================================================
## Applies basic code standard format to path
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------

use strict;
use warnings;
use diagnostics;

my $CLEAN_CODE = 0;
my $JS_FIX_STRINGS = 1;
## Set this to any value greater than zero to use TABS for indentation.
## This doen't change all the spaces to tabs, just the initial spaces.
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

        if ( $cpp && ( $line =~ /^\s*#/ ) )
        {
            ## TODO: Handle better C++: #include <path/file>
            return $line;
        }

        while ( $line =~ s/([^\s])\?/$1 \?/ ) { }

        while ( $line =~ s/([^\s]),([^\s])/$1, $2/ ) { }

        while ( $line =~ s/([\)_]):([\(_])/$1 : $2/ ) { }

        while ( $line =~ s/([^\s])%([^=\s])/$1 % $2/ ) { }

        while ( $line =~ s/([^-+*\/!=<>\|\s\[])=([^=\s])/$1 = $2/ ) { }

        while ( $line =~ s/([^=\s])==([^=\s])/$1 == $2/ ) { }

        while ( $line =~ s/([^\s])!=([^=\s])/$1 != $2/ ) { }

        while ( $line =~ s/([^\*\+eE\s])\+([^=\+])/$1 \+ $2/ ) { }

        while ( $line =~ s/\s+\+([^=\+\s])/ \+ $1/ ) { }

        $line =~ s/=-(\S)/= -$1/;
        while ( $line =~ s/([^-eE,:\[\s])-([^-=>\s])/$1 - $2/ ) { }

        while ( $line =~ s/([^\/\*\s])\/([^=\*\s])/$1 \/ $2/ ) { }

        while ( $line =~ s/([^\/\*\[\s])\*([^=\/\*,>\]\s])/$1 \* $2/ ) { }

        while ( $line =~ s/([^\(;])\s+;/$1;/ ) { }

        while ( $line =~ s/([^\[\s])\{/$1 \{/ ) { }
        while ( $line =~ s/{(\S)/\{ $1/ ) { }
        while ( $line =~ s/(\S)\}/$1 \}/ ) { }
        $line =~ s/([=|,]) \{ \}/$1 \{\}/;

        $line =~ s/;;\n/;\n/;
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
    return if ( ( $file !~ /.+\.hx$/i ) && !$js && !$cpp && !$cs );

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
        if ( $CLEAN_CODE && $isComment )
        {
            my $validComment = ( $lines[$k] =~ /^\s*\/\/[=-]+/ );
            $validComment = ( $lines[$k] =~ /^\s*\/\/\/\/[^\/]/ ) if ( !$validComment );
            $validComment = ( $lines[$k] =~ /^\s*\/\/!/ ) if ( !$validComment );
            $validComment = ( $lines[$k] =~ /^\s*\/\/ \[/ ) if ( !$validComment );
            $validComment = ( $lines[$k] =~ /^\s*\/\/ \(/ ) if ( !$validComment );
            $validComment = ( $lines[$k] =~ /^\s*\/\/ \d/ ) if ( !$validComment );

            if ( !$validComment )
            {
                $validComment = ( $lines[$k] =~ /^\s*\/\/(\s*)[A-Za-z]+/ );
                ## Delete suspicious line comments
                if ( !$isComment || ( !defined $1 ) || ( length( $1 ) != 1 ) )
                {
                    $deletedComments++;
                    $changed = $lineChanged = 1;
                    $changes{'CLEAN'} = 1;
                    $lines[$k] = '';
                }
            }
        }
        $commentLines++ if ( $isComment );

        ## Ignore final comments
        my $newLine = $line;
        my $comment = '';
        my $index = index( $newLine, '//' );
        if ( $index >= 0 )
        {
            $comment = substr( $newLine, $index );
            $newLine = substr( $newLine, 0, $index );
        }
        my $stripped = $newLine;
        ##print "regex? $newLine\n" if ( ( $newLine =~ /\/[^\*].*[^\*]\// ) || ( $newLine =~ /\/\S+\// ) );

        if ( !$isComment && ( $newLine !~ /^\s*\/?\*\**/ )
                         ## TODO: Improve lame JS regex detection
                         && ( !$js || ( $js && ( ( $newLine !~ /\/[^\*].*[^\*]\// ) && ( $newLine !~ /\/\S+\// ) )
                                            ## Ignore encoded images in JS
                                            && ( $newLine !~ /"data:image\// ) ) ) )
        {
            ## Extract strings
            my %strs = ();
            my $counter = 0;
            my @keys = ();

            while ( $stripped =~ /(''|'\\{2,}'|'.*?[^\\]')/ )
            {
                push( @keys, "___s___$counter" . '_' );
                $strs{"___s___$counter" . '_'} = $1;
                $stripped =~ s/\Q$1\E/___s___\Q$counter\E_/;
                $counter++;
            }

            while ( $stripped =~ /(""|"\\{2,}"|".*?[^\\]")/ )
            {
                my $s = $1;
                push( @keys, "___s___$counter" . '_' );
                $strs{"___s___$counter" . '_'} = $s;
                $stripped =~ s/\Q$s\E/___s___\Q$counter\E_/;
                if ( $js && $JS_FIX_STRINGS && $s !~ /\\n|___s___|\\t|\\"|'/ )
                {
                    $strs{"___s___$counter" . '_'} =~ s/"/'/g;
                    $changed = $lineChanged = 1;
                    $changes{'STRINGS'} = 1;
                }
                $counter++;
            }

            ## Don't mess with JS oneliner casts
            if ( $js && ( $stripped =~ /(\/\*\* \@type \{.+\} \*\/)/ ) )
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

            $line = fixOperators( $stripped, $cpp );
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
        }

        ## Restore final comments
        if ( $index >= 0 )
        {
            $stripped .= $comment;
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
