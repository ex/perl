
use strict;
use warnings;
use diagnostics;

################################################################################
=ENCRYPT
#===============================================================================
my $brownCorpusFrequency = "ETAOINSRHLDCUMFPGWYBVKXJQZ";

my $input = "Low-level programming is good for the programmer's soul.\n" .
            "The game designer shouldn't be making a world in which the player\n" .
            "is just a small part. The player IS THE BOSS; it's your duty to\n" .
            "entertain him or her.\n" .
            "Focus is a matter of deciding what things you are not going to do.\n" .
            "The cost of adding a feature isn't just the time it takes to code\n" .
            "it. The cost also includes the addition of an obstacle to future\n" .
            "expansion. The trick is to pick the features that don't fight each\n" .
            "other. - John Carmack.\n" .
            "(www.gamasutra.com/view/news/234346?vpyumdluc)\n" .
            "(www.brainyquote.com/quotes/authors/j/john_carmack.html) ";

my $len = length( $input );
print "LEN: $len\n";
my %frequency;

for ( my $k = 0; $k < $len; $k++ )
{
    my $char = uc( substr( $input, $k, 1 ) );
    if ( $char =~ /[A-Z]/ )
    {
        if ( exists( $frequency{$char} ) )
        {
            $frequency{$char} = $frequency{$char} + 1;
        }
        else
        {
            $frequency{$char} = 1;
        }
    }
}

# Sort in descending order
my $freqText;
my $t = 0;
my $k = 0;

foreach ( sort( { $frequency{$b}<=>$frequency{$a} } keys( %frequency ) ) )
{
    print( $_, " - ", $frequency{ $_ }, "\n" );
    $t += $frequency{ $_ }; $k++;
    $freqText .= uc( $_ );
}
print( "$freqText $t\n" );                 # TEOIARNSHLMYUCWDGPFBVKJ + ZQX
print( "$brownCorpusFrequency\n\n" );   # ETAOINSRHLDCUMFPGWYBVKXJQZ

# Encrypt
my @alphabet;

for ( my $k = 0; $k < 26; $k++ )
{
    $alphabet[$k] = chr( $k + ord( 'A' ) );
}
print( "@alphabet\n" );

my @crypt;

srand();

while ( @alphabet > 0 )
{
    my $k = int( rand( @alphabet ) );
    push( @crypt, $alphabet[ $k ] );
    splice( @alphabet, $k, 1 );
}
print( "@crypt\n" );

my $cryptedMsg;
$len = length( $input );

for ( my $k = 0; $k < $len; $k++ )
{
    my $char = substr( $input, $k, 1 );
    if ( $char =~ /[A-Za-z]/ )
    {
        my $uper = 0;
        if ( $char =~ /[A-Z]/ )
        {
            $uper = 1;
        }
        my $pos = ord( uc( $char ) ) - ord( 'A' );
        $cryptedMsg .= ( $uper ? $crypt[$pos] : lc( $crypt[$pos] ) );
    }
    else
    {
        $cryptedMsg .= $char;
    }
}
print( "$cryptedMsg\n" );
=cut


################################################################################
#=DECRIPT
#===============================================================================
my $text = "Bgc-bfufb tegaedppqna ql aggv zge xof tegaedppfe'l lgjb.\n" .
           "Xof adpf vflqanfe logjbvn'x hf pdwqna d cgebv qn coqro xof tbdkfe\n" .
           "ql mjlx d lpdbb tdex. Xof tbdkfe QL XOF HGLL; qx'l kgje vjxk xg\n" .
           "fnxfexdqn oqp ge ofe.\n" .
           "Zgrjl ql d pdxxfe gz vfrqvqna codx xoqnal kgj def ngx agqna xg vg.\n" .
           "Xof rglx gz dvvqna d zfdxjef qln'x mjlx xof xqpf qx xdwfl xg rgvf\n" .
           "qx. Xof rglx dblg qnrbjvfl xof dvvqxqgn gz dn ghlxdrbf xg zjxjef\n" .
           "fstdnlqgn. Xof xeqrw ql xg tqrw xof zfdxjefl xodx vgn'x zqaox fdro\n" .
           "gxofe. - Mgon Rdepdrw.\n" .
           "(ccc.adpdljxed.rgp/uqfc/nfcl/234346?utkjpvbjr)\n" .
           "(ccc.hedqnkijgxf.rgp/ijgxfl/djxogel/m/mgon_rdepdrw.oxpb)";
##my $text = $cryptedMsg;

my $freqLang = "TEOAISRHNUCMDLGWFPYKJBVQX";
##my $freqLang = $freqText;

my $len = length( $text );
print "LEN: $len\n";
my %frequency;

for ( my $k = 0; $k < $len; $k++ )
{
    my $c = uc( substr( $text, $k, 1 ) );
    if ( $c =~ /[A-Z]/ )
    {
        $frequency{$c} = exists( $frequency{$c} ) ? $frequency{$c} + 1 : 1;
    }
}

my %dic;
my $freqText;
my $index = 0;
my $t = 0;

# Sort in descending order
foreach ( sort( {$frequency{$b}<=>$frequency{$a}} keys( %frequency ) ) )
{
    print( $_, " - ", $frequency{ $_ }, "\n" );
    $t += $frequency{ $_ };
    $freqText .= $_;
    $dic{uc( $_ )} = substr( $freqLang, $index++, 1);
}
print( "$freqText $t\n" );
print( "$freqLang\n" );

my $decrypted;
$len = length( $text );

for ( my $k = 0; $k < $len; $k++ )
{
    my $uper = 0;
    my $c = substr( $text, $k, 1 );

    ( $c =~ /[A-Z]/ ) ? $uper = 1 : $c = uc( $c );

    if ( exists( $dic{ $c } ) )
    {
        $decrypted .= $uper ? $dic{$c} : lc( $dic{$c} );
    }
    else
    {
        $decrypted .= $c;
    }
}

print( "$decrypted\n" );
=cut

