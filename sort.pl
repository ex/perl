##==============================================================================
## Sort lines for Editplus user tools: Run as Text Filter (Replace)
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------
use strict;
use warnings;
use File::Slurp;

my $file = $ARGV[0];

my @lines = read_file( $ARGV[0] );
my @sorted = sort @lines;

print @sorted;
