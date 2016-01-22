
use strict;
use warnings;
use diagnostics;

################################################################################
#=DECRIPT
#===============================================================================
my $text = "Uid nx, aex jcdjipx iu wzux zp, ta wxtpa jtdaws, ai etkx vis.\n" .
		   "Dcos zyexdzaxr aex Jxdw jezwipijes iu etkzyg nidx aety iyx hts\n" .
		   "ai ri aex ptnx aezyg. Z zyexdzaxr aeta jezwipijes udin Wtdds Htww,\n" .
		   "hei zp ns exdi tqactwws. Z htya ai ntfx Dcos cpxdp udxx. Z htya ai\n" .
		   "gzkx aexn aex udxxrin ai qeiipx. Jxijwx tdx rzuuxdxya. Jxijwx qeiipx\n" .
		   "rzuuxdxya qdzaxdzt. Oca zu aexdx zp t oxaaxd hts tniyg ntys\n" .
		   "twaxdytazkxp, Z htya ai xyqicdtgx aeta hts os ntfzyg za qinuidatowx.\n" .
		   "Pi aeta'p heta Z'kx adzxr ai ri.\n" .
		   "Z htya ai piwkx jdiowxnp Z nxxa zy aex rtzws wzux os cpzyg qinjcaxdp,\n" .
		   "pi Z yxxr ai hdzax jdigdtnp. Os cpzyg Dcos, Z htya ai qiyqxyadtax aex\n" .
		   "aezygp Z ri, yia aex ntgzqtw dcwxp iu aex wtygctgx, wzfx patdazyg hzae\n" .
		   "jcowzq kizr  pinxaezyg pinxaezyg pinxaezyg ai pts, \"jdzya exwwi hidwr.\"\n" .
		   "Z vcpa htya ai pts, \"jdzya aezp!\" Z riy'a htya tww aex pcddicyrzyg\n" .
		   "ntgzq fxshidrp. Z vcpa htya ai qiyqxyadtax iy aex atpf. Aeta'p aex otpzq\n" .
		   "zrxt. Pi Z etkx adzxr ai ntfx Dcos qirx qiyqzpx tyr pcqqzyqa.\n" .
		   "Scfzezdi Ntapcniai. (hhh.tdaznt.qin/zyak/dcos)";

my $freqLang = "TEOIARNSHLMYUCWDGPFBVKJ";

my $len = length( $text );
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

# Sort in descending order
foreach ( sort( {$frequency{$b}<=>$frequency{$a}} keys( %frequency ) ) )
{
	##print( $_, " - ", $frequency{ $_ }, "\n" );
	$freqText .= $_;
	$dic{uc( $_ )} = substr( $freqLang, $index++, 1);
}
print( "$freqText\n" );
print( "$freqLang\n" );

my $decrypted;
$len = length( $text );

for ( my $k = 0; $k < $len; $k++ )
{
	my $uper = 0;
	my $c = substr( $text, $k, 1 );
	if ( $c =~ /[A-Z]/ )
    {
        $uper = 1;
    }
	else
    {
        $c = uc( $c );
    }
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

################################################################################
=ENCRYPT
#===============================================================================
my $brownCorpusFrequency = "ETAOINSRHLDCUMFPGWYBVKXJQZ";

my $input = "For me, the purpose of life is, at least partly, to have joy.\n" .
			"Ruby inherited the Perl philosophy of having more than one way\n" .
			"to do the same thing. I inherited that philosophy from Larry Wall,\n" .
			"who is my hero actually. I want to make Ruby users free. I want to\n" .
			"give them the freedom to choose. People are different. People choose\n" .
			"different criteria. But if there is a better way among many\n" .
			"alternatives, I want to encourage that way by making it comfortable.\n" .
			"So that's what I've tried to do.\n" .
			"I want to solve problems I meet in the daily life by using computers,\n" .
			"so I need to write programs. By using Ruby, I want to concentrate the\n" .
			"things I do, not the magical rules of the language, like starting with\n" .
			"public void  something something something to say, \"print hello world.\"\n" .
			"I just want to say, \"print this!\" I don't want all the surrounding \n" .
			"magic keywords. I just want to concentrate on the task. That's the basic\n" .
			"idea. So I have tried to make Ruby code concise and succinct.\n" .
			"Yukihiro Matsumoto. (www.artima.com/intv/ruby)";

my $len = length( $input );
my %frequency;

for( my $k = 0; $k < $len; $k++ )
{
	my $char = uc( substr( $input, $k, 1 ) );
	if( $char =~ /[A-Z]/ )
	{
		if( exists( $frequency{ $char } ) )	{ $frequency{ $char } = $frequency{ $char } + 1; }
		else								{ $frequency{ $char } = 1; }
	}
}

my $freqText;

# Sort in descending order
foreach( sort( { $frequency{$b}<=>$frequency{$a} } keys( %frequency ) ) )
{
	print( $_, " - ", $frequency{ $_ }, "\n" );
	$freqText .= uc( $_ );
}
print( "$freqText\n" );				    # TEOIARNSHLMYUCWDGPFBVKJ + ZQX
print( "$brownCorpusFrequency\n\n" );   # ETAOINSRHLDCUMFPGWYBVKXJQZ

# Encrypt
my @alphabet;
for( my $k = 0; $k < 26; $k++ )	{ $alphabet[ $k ] = chr( $k + ord( 'A' ) ); }
print( "@alphabet\n" );

my @crypt;

srand();
$len = @alphabet;

while( $len > 0 )
{
	my $k = int( rand( $len ) );
	push( @crypt, $alphabet[ $k ] );
	splice( @alphabet, $k, 1 );
	$len = @alphabet;
}
print( "@crypt\n" );

my $cryptedMsg;

$len = length( $input );
for( my $k = 0; $k < $len; $k++ )
{
	my $char = substr( $input, $k, 1 );
	if( $char =~ /[A-Za-z\d]/ )
	{
		my $uper = 0;
		if( $char =~ /[A-Z]/ )	{ $uper = 1; }
		my $pos = ord( uc( $char ) ) - ord( 'A' );
		if( $uper ) { $cryptedMsg .= $crypt[ $pos ]; }
		else		{ $cryptedMsg .= lc( $crypt[ $pos ] ); }
	}
	else { $cryptedMsg .= $char; }
}
print( "$cryptedMsg\n" );
=cut

