##==============================================================================
## Minify JavaScript files.
## Install perl modules: cmd>cpan install JavaScript::Minifier
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------
use strict;
use warnings;
use File::Slurp;
use JavaScript::Minifier qw(minify);

my $file = $ARGV[0];
my $text = read_file($file);
$text = minify(input => $text);
print($text);
