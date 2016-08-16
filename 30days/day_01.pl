use strict;
use warnings;

my $i = 4;
my $d = 4.0;
my $s = 'HackerRank ';

# Declare second integer, double, and String variables.
# Read and save an integer, double, and String to your variables.
my $ni = <STDIN>;
my $nd = <STDIN>;
my $ns = <STDIN>;

# Print the sum of both integer variables on a new line.
print( $i + $ni, "\n" );

# Print the sum of the double variables on a new line.
print( sprintf( "%.1f", $d + $nd ), "\n" );

# Concatenate and print the String variables on a new line
# The 's' variable above should be printed first.
print( $s . $ns, "\n" );