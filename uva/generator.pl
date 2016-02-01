################################################################################
## Creates a VS project for ACM/UVA problems
## It tries to open Notepad for pasting the poblem, close Notepad after that
## Author: Laurens Rodriguez
##==============================================================================

use strict;			# install all three strictures
use warnings;		# print warnings

use Text::Wrap qw( $columns &wrap );

## Number of columns used by source code.
my $COLUMNS = 80;

my $VS_DIR = 'vs14';
my $SOURCES_DIR = 'cpp';
my $PROBLEMS_DIR = 'prb';
my $TEST_DIR = 'test';
my $VS_TEMPLATE_DIR = '_template_';
my $INPUT_TEST_FILE = 'input.txt';
my $OUTPUT_TEST_FILE = 'output.txt';

my $type = gets( 'Type of problem', 'UVA' );
my $number = gets( 'Number of problem', '0' );

exit if ( $number <= 0 );

# Name of solution
my $name = $type . '_' . $number;

# Check if solution dir exists
my $createSolution = 1;

if ( -e "$VS_DIR/$name" )
{
    my $cmd = gets( "Solution exists. Do you want to regenerate it? (Y/N)", 'NO' );
    if ( $cmd eq 'Y' )
    {
        unlink( "$VS_DIR/$name/main.cpp" ) if ( -e "$VS_DIR/$name/main.cpp" );
        unlink( "$VS_DIR/$name/$name.sln" ) if ( -e "$VS_DIR/$name/$name.sln" );
        unlink( "$VS_DIR/$name/$name.vcxproj" ) if ( -e "$VS_DIR/$name/$name.vcxproj" );
    }
    else { $createSolution = 0; }
}
else
{
	print( "Creating solution\n" );
    mkdir( "$VS_DIR/$name", 0777 ) or die( "Cannot create project directoy: $!" );
}

if ( $createSolution )
{
    makeFile( "$VS_DIR/$VS_TEMPLATE_DIR/_cpp", "$VS_DIR/$name/main.cpp" );
    makeFile( "$VS_DIR/$VS_TEMPLATE_DIR/_sln", "$VS_DIR/$name/$name.sln" );
    makeFile( "$VS_DIR/$VS_TEMPLATE_DIR/_vcxproj", "$VS_DIR/$name/$name.vcxproj" );
    if ( $VS_DIR eq 'vs14' )
    {
        makeFile( "$VS_DIR/$VS_TEMPLATE_DIR/_filters", "$VS_DIR/$name/$name.filters" );
    }
}

# Create problems sources and tests
my $problem = getFileName( $PROBLEMS_DIR, $number, "txt" );
my $createProblemFile = 1;
if ( -e $problem )
{
    my $cmd = gets( "$problem exists. Do you want to overwrite it? (Y/N)", 'NO' );
    if ( $cmd eq 'Y' )
    {
        unlink( $problem );
    }
    else { print( "Using existing problem text\n" ); }
}

if ( createNewFile( $problem ) )
{
    system( "notepad $problem" )
};
createSolution( $number, $problem );

##------------------------------------------------------------------------------
sub createSolution
{
    my $num = $_[0];
	my $fileProblem = $_[1];

	if ( -e $fileProblem )
    {
		my $cppFileName = getFileName( $SOURCES_DIR, $num, "h" );
        my $overwrite = 1;

		if ( -e $cppFileName )
        {
			my $cmd = gets( "$cppFileName exists. Do you want overwrite it? (Y/N)", 'NO' );
			if ( $cmd ne 'Y' )
            {
                print( "Using existing source code.\n" );
                $cppFileName .= "_TEMP_";
                $overwrite = 0;
            }
		}

		# Problem declaration
		if ( open( my $probFile, '<', $fileProblem) )
		{
			if ( open( my $cppFile, '>', $cppFileName ) )
			{
				# Print problem and parse problem...
				my $testInput = "";
				my $testOutput = "";
				my $oldLine = "";
				my $state = 0;

				print( $cppFile '/*'.('#' x ($COLUMNS - 4))."*\\\n" );

				while( <$probFile> )
				{
					s/\xA0/\x20/g; # Replacing this character by space (problem was copyed of applet)

					if ( ( /\S/ ) || ( $oldLine =~ /\S/ ) )
					{
						if ( $state == 0 )
						{
							s/Background$/=========================== BACKGROUND ==================================/i;
							s/The Problem$/=========================== THE PROBLEM =================================/i;
							s/Description$/========================== DESCRIPTION ==================================/i;
							s/^Input|^The Input$/============================= INPUT =====================================/i;
							s/^Output|^The Output$/============================= OUTPUT ====================================/i;
							s/^Sample Input$/SAMPLE INPUT/i;
							$state = 1 if ( /Sample Input/i );
						}
						elsif ( $state == 1 )
						{
							s/Sample Output$/SAMPLE OUTPUT/i;
                            s/Output for the sample input$/SAMPLE OUTPUT/i;
							if ( /Sample output/i )
                            {
                                $state = 2;
                            }
							else
							{
								if ( /\S/ ) { $testInput .= $_; }
							}
						}
						elsif ( $state == 2 )
						{
							if ( /\S/ ) { $testOutput .= $_; }
						}

						$oldLine = $_;
						printWrappedLine( $cppFile, $COLUMNS, " *  ", " * ", $_ );
					}
				}

				if ( open( my $inputTestFile, '>', "$TEST_DIR/$type"."_$number"."_$INPUT_TEST_FILE" ) )
				{
					print( $inputTestFile $testInput );
				}
				else { print( "Can't create input test file: $!\n" ); }

				if ( open( my $outputTestFile, '>', "$TEST_DIR/$type"."_$number"."_$OUTPUT_TEST_FILE" ) )
				{
					print( $outputTestFile $testOutput );
				}
				else {  print( "Can't create output test file: $!\n" ); }

				print( $cppFile "\\*".('#' x ($COLUMNS - 4))."*/\n\n" );

				# Class definition
				print( $cppFile "#include <cstdio>\n" );
				print( $cppFile "#include <cstdlib>\n" );
				print( $cppFile "#include <cstring>\n" );
				print( $cppFile "#include <algorithm>\n" );
				print( $cppFile "#define _CRT_SECURE_NO_DEPRECATE\n" );
				print( $cppFile "#define _CRT_SECURE_NO_WARNINGS\n" );
				print( $cppFile "\n" );
				print( $cppFile "using namespace std;\n" );
				print( $cppFile "\n" );
				print( $cppFile "class Solver\n" );
				print( $cppFile "{\n" );
				print( $cppFile "public:\n" );
				print( $cppFile "    void run()\n" );
				print( $cppFile "    {\n" );
				print( $cppFile "    }\n" );
				print( $cppFile "};\n" );
			}
			else { print( "Can't create $cppFileName: $!\n" ); }
		}
		else { print( "Can't open problem $fileProblem: $!\n" ); }

        unlink( $cppFileName ) if ( !$overwrite );

        ## Open folder.
        system( "start $VS_DIR\\$name\\" );
	}
	else { print(" No problem found for PROB: $num\n" ); }
}

##------------------------------------------------------------------------------
# makeFile( templateFile, outputFile )
# Creates copy of template file after replacing [TYPE] and [NUMBER] tags
sub makeFile
{
	my $templateFile = $_[0];
	my $outputFile = $_[1];

    open( my $input, '<', $templateFile ) or die( "Can't open $templateFile: $!" );
	open( my $output, '>', $outputFile ) or die( "Can't create $outputFile: $!" );

	while( <$input> )
	{
		s/\[TYPE\]/$type/g;
		s/\[NUM\]/$number/g;
		print( $output $_ );

    }
	close( $input );
	close( $output );
}

##------------------------------------------------------------------------------
sub getFileName
{
	my $dir = $_[0];
	my $ext = $_[2];
	return "$dir\\$name.$ext";
}

##------------------------------------------------------------------------------
## Prints a wrapped line in a file
sub printWrappedLine
{
	my $file = $_[0];
	my $len = $_[1];
	my $prefix = $_[2];
	my $postfix = $_[3];
	my $line = $_[4];
    $line =~ s/\t/    /g;
	my $lenLine = length( $line );
	my $lenPrefix = length( $prefix );
	my $lenPostfix = length( $postfix );

	if ( ( $lenLine + $lenPrefix + $lenPostfix ) <= $len + 1 )
    {
    	chomp( $line );
		print( $file $prefix.$line.(' 'x($len - $lenLine - $lenPrefix - $lenPostfix + 1)).$postfix."\n" );
	}
	else
    {
		$columns = $len - $lenPrefix - $lenPostfix;
        my $wrapped = wrap( $prefix, $prefix, $line );
        my @lines = split( /\n/, $wrapped );
        my $numLines = @lines;
        for ( my $k = 0; $k < $numLines; ++$k )
        {
            $lenLine = length( $lines[$k] );
            print( $file $lines[$k].(' 'x($len - $lenLine - $lenPostfix)).$postfix."\n" );
        }
	}
}

##------------------------------------------------------------------------------
## Creates a new file only if it doesn't exists (RETURNS 1 if file was created)
sub createNewFile
{
	my $fileName = $_[0];
	if ( ! -e $fileName )
    {
		if( open( my $file, '>', $fileName ) )
		{
			close( $file );
			return 1;
		}
		else
        {
            print( "Can't create $fileName: $!\n");
        }
	}
	return 0;
}

##------------------------------------------------------------------------------
sub gets
{
    if ( defined $_[0] )
    {
        print( ( defined $_[1] ) ? "$_[0] ($_[1]): " : "$_[0]: ");
    }
	my $ret = <STDIN>;
	chomp( $ret );
	if ( ( $ret eq "" ) && ( defined $_[1] ) )
    {
        $ret = $_[1];
    }
    return $ret;
}
