##==============================================================================
## Formats JavaScript files.
## Install perl modules: cmd>cpan install JavaScript::Beautifier
## Author: Laurens Rodriguez.
##------------------------------------------------------------------------------
use strict;
use warnings;
use File::Slurp;
use JavaScript::Beautifier qw(js_beautify);

my $file = $ARGV[0];
my $text = read_file($file);
$text = js_beautify($text, { indent_size => 1, indent_character => "\t" });
print($text);
