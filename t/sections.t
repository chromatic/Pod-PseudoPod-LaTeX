#! perl

use strict;
use warnings;

use IO::String;
use File::Spec::Functions;

use Test::More 'no_plan'; # tests => 20;

use_ok( 'Pod::PseudoPod::LaTeX' ) or exit;

my $fh     = IO::String->new();
my $parser = Pod::PseudoPod::LaTeX->new();
$parser->output_fh( $fh );
$parser->parse_file( catfile( qw( t test_file.pod ) ) );

$fh->setpos(0);
my $text  = join( '', <$fh> );

like( $text, qr/\\chapter{Some Document}/,
	'0 heads should become chapter titles' );

like( $text, qr/\\section\*{A Heading}/,
	'A heads should become section titles' );

like( $text, qr/\\subsection\*{B heading}/,
	'B heads should become subsection titles' );

like( $text, qr/\\subsubsection\*{c heading}/,
	'C heads should become subsubsection titles' );
