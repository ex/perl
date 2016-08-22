## This script searches the HYG-Database for locating the nearest stars.
## Download database from: https://github.com/astronexus/HYG-Database

use strict;
use warnings;

my $RANGE = 10;
my $k = 0;

open( my $filehandle, '<', 'hygdata_v3.csv' );
open( my $json, '>', 'stars.json' );

print( $json "var stars = [\n" );

while ( <$filehandle> )
{
    $k++;
    next if ( $k == 1 );

    # Strip the linebreak character at the end.
    chomp;

    ## Fields in the database:
    ## 0   id: The database primary key.
    ## 1   hip: The star's ID in the Hipparcos catalog, if known.
    ## 2   hd: The star's ID in the Henry Draper catalog, if known.
    ## 3   hr: The star's ID in the Harvard Revised catalog, which is the same as its number in the Yale Bright Star Catalog.
    ## 4   gl: The star's ID in the third edition of the Gliese Catalog of Nearby Stars.
    ## 5   bf: The Bayer / Flamsteed designation, primarily from the Fifth Edition of the Yale Bright Star Catalog. This is a combination of the two designations. The Flamsteed number, if present, is given first; then a three-letter abbreviation for the Bayer Greek letter; the Bayer superscript number, if present; and finally, the three-letter constellation abbreviation. Thus Alpha Andromedae has the field value "21Alp And", and Kappa1 Sculptoris (no Flamsteed number) has "Kap1Scl".
    ## 6   proper: A common name for the star, such as "Barnard's Star" or "Sirius". I have taken these names primarily from the Hipparcos project's web site, which lists representative names for the 150 brightest stars and many of the 150 closest stars. I have added a few names to this list. Most of the additions are designations from catalogs mostly now forgotten (e.g., Lalande, Groombridge, and Gould ["G."]) except for certain nearby stars which are still best known by these designations.
    ## 7   ra, dec: The star's right ascension and declination, for epoch and equinox 2000.0.
    ## 9   dist: The star's distance in parsecs, the most common unit in astrometry. To convert parsecs to light years, multiply by 3.262. A value >= 10000000 indicates missing or dubious (e.g., negative) parallax data in Hipparcos.
    ## 10  pmra, pmdec: The star's proper motion in right ascension and declination, in milliarcseconds per year.
    ## 12  rv: The star's radial velocity in km/sec, where known.
    ## 13  mag: The star's apparent visual magnitude.
    ## 14  absmag: The star's absolute visual magnitude (its apparent magnitude from a distance of 10 parsecs).
    ## 15  spect: The star's spectral type, if known.
    ## 16  ci: The star's color index (blue magnitude - visual magnitude), where known.
    ## 17  x,y,z: The Cartesian coordinates of the star, in a system based on the equatorial coordinates as seen from Earth. +X is in the direction of the vernal equinox (at epoch 2000), +Z towards the north celestial pole, and +Y in the direction of R.A. 6 hours, declination 0 degrees.
    ## 20  vx,vy,vz: The Cartesian velocity components of the star, in the same coordinate system described immediately above. They are determined from the proper motion and the radial velocity (when known). The velocity unit is parsecs per year; these are small values (around 1 millionth of a parsec per year), but they enormously simplify calculations using parsecs as base units for celestial mapping.
    ## 23  rarad, decrad, pmrarad, prdecrad: The positions in radians, and proper motions in radians per year.
    ## 27  bayer: The Bayer designation as a distinct value
    ## 28  flam: The Flamsteed number as a distinct value
    ## 29  con: The standard constellation abbreviation
    ## 30  comp, comp_primary, base: Identifies a star in a multiple star system. comp = ID of companion star, comp_primary = ID of primary star for this component, and base = catalog ID or name for this multi-star system. Currently only used for Gliese stars.
    ## 31  lum: Star's luminosity as a multiple of Solar luminosity.
    ## 32  var: Star's standard variable star designation, when known.
    ## 33  var_min, var_max: Star's approximate magnitude range, for variables. This value is based on the Hp magnitudes for the range in the original Hipparcos catalog, adjusted to the V magnitude scale to match the "mag" field.
    my @fields = split( /,/ , $_ );

    ## To convert parsecs to light years, multiply by 3.262
    my $dist = $fields[9] * 3.262;

    if ( $dist < $RANGE )
    {
        my $line = $fields[0];
        $line .= " '$fields[4]'" if ( $fields[4] ne '' );
        $line .= " '$fields[5]'" if ( $fields[5] ne '' );
        $line .= " '$fields[6]'" if ( $fields[6] ne '' );

        my $x = $fields[17] * 3.262;
        my $y = $fields[18] * 3.262;
        my $z = $fields[19] * 3.262;

        my $d = sqrt( $x * $x + $y * $y + $z * $z );
        $line .= " $dist x[$fields[16]] y[$fields[17]] z[$fields[18]]";

        die "[ERROR] $d $dist\n" if ( abs( $dist - $d ) > 0.01 );

        print "$line\n";
        print( $json "\t{id: $fields[0], x:$x, y:$y, z:$z},\n" );
    }
}

print( $json "];" );

close( $filehandle );
close( $json );
