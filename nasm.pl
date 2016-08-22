
use strict;
use warnings;

use Win32::Console::ANSI;
use Term::ANSIColor;

sub runNasm {
    print color 'white';
    my $source = $_[0];

    if ($source =~ /([A-Za-z\d_]+)\.asm$/gi) {
        my $program = $1;

        if (-e "$program.exe") {
            unlink("$program.exe");
        }
        print("NASM: ");
        print color 'bold yellow';
        print("$source\n");
        print color 'white';
        system("nasm -fwin32 $source");
        system("gcc -O2 $program.obj -o $program.exe");
        print("\n");

        if (-e "$program.obj") {
            unlink("$program.obj");
        }
        if (-e "$program.exe") {
            print color 'bold green';
            system("$program.exe");
        }
    }
    else { 
        print("ERROR: No ASM file found!\n");
    }
}

return 1;
exit;
