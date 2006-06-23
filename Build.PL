#! perl

use strict;
use warnings;

use Module::Build;
use File::Spec::Functions;

my $class = Module::Build->subclass(
	class => 'Module::Build::FilterTests',
	code  => <<'END_HERE',
	
	use File::Glob;
	use File::Spec::Functions;
	
	sub ACTION_disttest
	{
		my $self = shift;
		local $ENV{PERL_RUN_ALL_TESTS} = 1;
		$self->SUPER::ACTION_disttest( @_ );
	}
	
	sub find_test_files
	{
		my $self  = shift;
		my $tests = $self->SUPER::find_test_files( @_ );
	    
		return $tests unless $ENV{PERL_RUN_ALL_TESTS};
	
		my $test_pattern = catfile(qw( t developer *.t ) );
		unshift @$tests, File::Glob::bsd_glob( $test_pattern );
		return $tests;
	}
END_HERE
);

my $builder = $class->new(
    module_name          => 'Pod::PseudoPod::LaTeX',
    license              => 'perl',
    dist_author          => 'chromatic <chromatic@wgz.org>',
    dist_version_from    => 'lib/Pod/PseudoPod/LaTeX.pm',
	requires             =>
	{
		'Pod::PseudoPod' => 0,
	},
    build_requires =>
	{
        'Test::More'     => 0,
    },
    add_to_cleanup       => [ 'Pod-PseudoPod-LaTeX-*' ],
	create_makefile_pl   => 'traditional',
	sign                 => 1,
	script_files         => [ catfile(qw( scripts ppod2latex )) ],
);

$builder->create_build_script();
