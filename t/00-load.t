#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Pod::PseudoPod::LaTeX' );
}

diag( "Testing Pod::PseudoPod::LaTeX $Pod::PseudoPod::LaTeX::VERSION, Perl $], $^X" );
