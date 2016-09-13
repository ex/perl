
use strict;
use warnings;
use File::Fetch;
use File::Basename;
use File::Path qw( make_path );

my $BASE_DIR = 'http://www.url.com/';
my $LINKS = 'links.txt';
my $DESTINE = 'download/';

print "Downloading path base: $BASE_DIR\n";

open( my $input, '<', $LINKS );
while ( my $line = <$input> )
{
    if ( index( $line, $BASE_DIR ) == 0 )
    {
        chomp $line;
        my $len = rindex( $line, '/' ) - length( $BASE_DIR );
        if ( $len > 0 )
        {
            my $localPath = substr( $line, length( $BASE_DIR ), $len );

            if (! -e $localPath )
            {
                make_path( $DESTINE . $localPath );
            }
            my $fileName = basename( $line );
            print "$localPath -> $fileName\n";

            my $url = $line;
            my $ff = File::Fetch->new( uri => $url );
            my $file = $ff->fetch( to => $DESTINE . $localPath ) or die $ff->error;
        }
    }
    else
    {
        print "\nERROR: ignoring $line";
    }
}
close( $input );