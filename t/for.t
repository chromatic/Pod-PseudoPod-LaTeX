#! perl

use strict;
use warnings;

use IO::String;
use File::Spec::Functions;

use Test::More tests => 2;

use_ok( 'Pod::PseudoPod::LaTeX' ) or exit;

my $fh     = IO::String->new();
my $parser = Pod::PseudoPod::LaTeX->new();
$parser->output_fh( $fh );
$parser->parse_file( catfile( qw( t test_file.pod ) ) );


$fh->setpos(0);
my $text = join( '', <$fh> );

like( $text, qr/\\LaTeX/,
    '\LaTeX in a =for latex section remains intact' );
