
use strict;
use warnings;

use Win32::Console::ANSI;
use Term::ANSIColor;
use Data::Dumper;
use Cwd;

my $FIX_AVI = 'F:\bck\dev\c\fixAVI\Release\fixAVI.exe';

my $currentDir = cwd();

sub recurse
{
    my $path = $_[0];

    ## Append a trailing / if it's not there.
    $path .= '/' if ($path !~ /\/$/);

    ## Loop through the files contained in the directory.
    my @files = ();
    for my $eachFile (glob(".* *"))
    {
        if (!(-d $eachFile))
        {
            if (!($eachFile =~ /.+\.pl$/i))
            {
                print($eachFile." s:".(-s $eachFile)."\n");
                push(@files, {size =>-s $eachFile, name => $eachFile});
            }
        }
    }
    if (scalar(@files) != 2)
    {
        print color 'bold red';
        print("ERROR:\n" );
        die("Only two files must be found in the working folder\n");
    }
    else
    {
        my $small = $files[0];
        my $big = $files[1];
        if ($small->{size} > $big->{size})
        {
            $small = $files[1];
            $big = $files[0];
        }
        ##print(Dumper($small)."\n");
        ##print(Dumper($big)."\n");
        my $target = $small->{name};
        $target = substr($target, 0, rindex($target, ".nv!"));
        print color 'bold cyan';
        print("TARGET: $target\n");
        print color 'bold green';
        system($FIX_AVI . ' "'.$path.$small->{name}.'" "'.$path.$big->{name}.'" "'.$target.'"');
        print color 'red';
        print("\nPLAYING: $target\n");
        system($target);
        print color 'bold green';
        print("Do you want to delete the incomplete files? [y]/n ");
        my $resp = <STDIN>;
        chomp($resp);
        if (($resp eq 'n') || ($resp eq 'N')) {
            exit;
        }
        unlink($path.$small->{name});
        unlink($path.$big->{name});
    }
}

print color 'bold yellow';
print("Fixing download: $currentDir\n" );
print color 'bold green';
recurse($currentDir, 0);
