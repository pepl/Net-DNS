# $Id$	-*-perl-*-

use strict;
use Test::More tests => 14;


use Net::DNS;


my $name = 'CDS.example';
my $type = 'CDS';
my $code = 59;
my @attr = qw( keytag algorithm digtype digest );
my @data = ( 42495, 5, 1, '0ffbeba0831b10b8b83440dab81a2148576da9f6' );
my @also = qw( digestbin babble );

my $wire = join '', qw( A5FF 05 01 0FFBEBA0831B10B8B83440DAB81A2148576DA9F6 );


{
	my $typecode = unpack 'xn', new Net::DNS::RR(". $type")->encode;
	is( $typecode, $code, "$type RR type code = $code" );

	my $hash = {};
	@{$hash}{@attr} = @data;

	my $rr = new Net::DNS::RR(
		name => $name,
		type => $type,
		%$hash
		);

	my $string = $rr->string;
	my $rr2	   = new Net::DNS::RR($string);
	is( $rr2->string, $string, 'new/string transparent' );

	is( $rr2->encode, $rr->encode, 'new($string) and new(%hash) equivalent' );

	foreach (@attr) {
		is( $rr->$_, $hash->{$_}, "expected result from rr->$_()" );
	}

	foreach (@also) {
		is( $rr2->$_, $rr->$_, "additional attribute rr->$_()" );
	}


	my $empty   = new Net::DNS::RR("$name $type");
	my $encoded = $rr->encode;
	my $decoded = decode Net::DNS::RR( \$encoded );
	my $hex1    = uc unpack 'H*', $decoded->encode;
	my $hex2    = uc unpack 'H*', $encoded;
	my $hex3    = uc unpack 'H*', substr( $encoded, length $empty->encode );
	is( $hex1, $hex2, 'encode/decode transparent' );
	is( $hex3, $wire, 'encoded RDATA matches example' );


	$rr->algorithm('RSASHA512');
	is( $rr->algorithm(), 10, 'algorithm mnemonic accepted' );

	$rr->digtype('SHA256');
	is( $rr->digtype(), 2, 'digest type mnemonic accepted' );

	$rr->digtype(0);
	is( $rr->digtype(), 0, 'digest type 0 accepted' );
}


{
	my $rr = new Net::DNS::RR("$name $type @data");
	$rr->print;
}
exit;

