
use strict;
use warnings;

use Win32::Console::ANSI;
use Term::ANSIColor;

my $GCC_DIR = "";
my $JDK_DIR = 'C:/Program Files/Java/jdk1.6.0_21/bin';
my $LUA_PATH = "F:/dvx/lua/luadev/bin/lua.exe";
##my $KILLA_PATH = "F:/dvx/killa/bin/windows/killa.exe";
##my $KILLA_PATH = "F:/dvx/killa/bin/windows/killaext.exe";
my $KILLA_PATH = "F:/dvx/love/bin/windows/killa.exe";
my $CLOJURE_PATH = "E:/progs/clojure-1.6.0/clojure-1.6.0.jar";

my $FLEX_DIR = 'C:/flex3/bin';
my $FLASH_PLAYER = 'F:/stp/_prog_/flash/flashplayer_10_sa_debug.exe';

my $file = $ARGV[0];

if ($file =~ /([A-Za-z\d_-]+)\.cpp$/gi) {
	my $program = $1;
    unlink("$program.exe") if (-e "$program.exe");
    print("C++: " );
    print color 'bold yellow';
    print("$file\n");
    print color 'white';
    system($GCC_DIR."g++.exe -std=c++11 -O2 \"$file\" -o \"$program.exe\"");
    print("\n");
    if (-e "$program.exe") {
        print color 'bold green';
        system("$program.exe");
    }
}
elsif ($file =~ /([A-Za-z\d_-]+)\.c$/gi) {
	my $program = $1;
    unlink("$program.exe") if (-e "$program.exe");
    print("ANSI C: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'white';
    system( "$GCC_DIR\\gcc.exe -std=c99 -pedantic -O2 \"$file\" -o  \"$program.exe\"" );
    print("\n");
    if (-e "$program.exe") {
        print color 'bold green';
        system("$program.exe");
    }
}
elsif ($file =~ /([A-Za-z\d_-]+)\.pl$/gi) {
    print color 'white';
    print("Perl: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
    system("perl \"$file\"");
    print("\n");
}
elsif ($file =~ /([A-Za-z\d_]+)\.kia$/gi) {
    print color 'white';
    print("Killa: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
    system("$KILLA_PATH \"$file\"");
    print("\n");
}
elsif ($file =~ /([A-Za-z\d_]+)\.js$/gi) {
    print color 'white';
    print("JavaScript: " );
    print color 'bold yellow';
    print("$file\n\n");
    print color 'bold green';
    system("node \"$file\"");
    print("\n");
}
elsif ($file =~ /([A-Za-z\d_]+)\.clj$/gi) {
    print color 'white';
    print("Clojure: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
	system("java -cp $CLOJURE_PATH clojure.main $file" );
}
elsif ($file =~ /([A-Za-z\d_]+)\.d$/gi) {
	my $program = $1;
    unlink("$program.exe") if (-e "$program.exe");
    print("D: " );
    print color 'bold yellow';
    print("$file\n");
    print color 'white';
    system("dmd -wi \"$file\" -offilename \"$program.exe\"");
    print("\n");
    if (-e "$program.exe") {
        print color 'bold green';
        system("$program.exe");
    }
}
elsif ($file =~ /([A-Za-z\d_-]+)\.py$/gi) {
    print color 'white';
    print("Python: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
    system("python -tt \"$file\"");
    print("\n");
}
elsif ($file =~ /([A-Za-z\d_-]+)\.rb$/gi) {
    print color 'white';
    print("Ruby: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
    system("ruby -w \"$file\"");
    print("\n");
}
elsif ($file =~ /([A-Za-z\d_]+)\.lua$/gi) {
    print color 'white';
    print("Lua: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
    system("$LUA_PATH \"$file\"");
    print("\n");
}
elsif (($file =~ /([A-Za-z\d_-]+)\.mxm$]/gi)
            || ($file =~ /([A-Za-z\d_-]+)\.as$]/gi)) {
	my $class = $1;
    unlink("$class.swf") if (-e "$class.swf");
    print color 'white';
    print("FLEX : ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
	system('"'.$FLEX_DIR.'\\mxmlc.exe'."\" $file" );
	if (-e "$class.swf") {
        ##system('"firefox.exe" '."$class.swf");
        system("$FLASH_PLAYER $class.swf");
    }
}
elsif ($file =~ /([A-Za-z\d_]+)\.java$/gi) {
	my $class = $1;
	unlink("$class.class") if (-e "$class.class");
    print color 'white';
    print("JAVA : ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
	system('"'.$JDK_DIR."/javac.exe\" $file" );
	system("java $class") if (-e "$class.class");
}
elsif ($file =~ /([A-Za-z\d_-]+)\.hs$/gi) {
	my $program = $1;
    unlink("$program.exe") if (-e "$program.exe");
    print color 'white';
    print("Haskell: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
    system("ghc -o $1 \"$file\"");
    print("\n");
    if (-e "$1.exe") {
        print color 'bold green';
        system("$1.exe");
    }
}
elsif ($file =~ /([A-Za-z\d_-]+)\.rs$/gi) {
	my $program = $1;
    unlink("$program.exe") if (-e "$program.exe");
    print color 'white';
    print("Rust: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
    system("rustc $file");
    print("\n");
    if (-e "$1.exe") {
        print color 'bold green';
        system("$1.exe");
    }
}
elsif ($file =~ /([A-Za-z\d_-]+)\.ml$/gi) {
	my $program = $1;
    unlink("$program.exe") if (-e "$program.exe");
    print color 'white';
    print("Ocaml: ");
    print color 'bold yellow';
    print("$file\n");
    print color 'bold green';
    system("ocamlc -o $1.exe $file");
    print("\n");
    if (-e "$1.exe") {
        print color 'bold green';
        system("$1.exe");
    }
}
elsif ($file =~ /([A-Za-z\d_-]+)\.asm$/gi) {
    runNasm($file);
}
else {
    print color 'bold red';
    print("[ERROR] No recognized file: $file\n");
}
