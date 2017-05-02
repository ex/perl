
use strict;
use warnings;
use Win32::Console::ANSI;
use Term::ANSIColor;
use File::Basename;
use File::Find;

my $lastDir = '';
my $lastDrive = '';
my $found = 0;
my $search = '';

while ( 1 )
{
	print( "Search for: " );
	$search = uc( <STDIN> );
	chomp( $search );
	last if ( $search eq '' );
    $found = 0;

	for ( my $k = ord( 'A' ); $k <= ord( 'Z' ); $k++ )
	{
		my $path = chr( $k ) . ':\anim';
		if ( -d $path )
		{
			$lastDrive = $path;
			find( \&scan, $path );
		}
	}
	print color 'bold green';
	print( "FOUND: $found\n" );
}

sub scan
{
    return if ( -d $_ );
    my $file = $_;
	my $name = $file;
	$name =~ s/_/ /g;
	if ( index( uc( $name ), $search ) >= 0 )
	{
		$found++;
		if ( $lastDrive ne '' )
		{
			print color 'bold magenta';
			print( "$lastDrive\n" );
			$lastDrive = '';
		}
		if ( $File::Find::dir ne $lastDir )
		{
			print color 'bold green';
			print( "  $File::Find::dir\n" );
			$lastDir = $File::Find::dir;
		}
		print color 'bold yellow';
		print( "    $file\n" );
	}
}
