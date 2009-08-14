#! perl

BEGIN { require 5.006002 }

use strict;
use warnings;

use Module::Build;
use File::Spec::Functions;

my $builder = Module::Build->new(
    module_name          => 'Pod::PseudoPod::LaTeX',
    license              => 'perl',
    dist_author          => 'chromatic <chromatic@wgz.org>',
    dist_version_from    => 'lib/Pod/PseudoPod/LaTeX.pm',
    requires             =>
    {
        'Pod::PseudoPod' => '0.15',
        'perl'           => '5.6.2',
    },
    build_requires =>
    {
        'Test::More'     => '0.60',
        'IO::String'     => 0,
    },
    config_requires =>
    {
        'Module::Build'  => '0.33',
    },
    add_to_cleanup       => [ 'Pod-PseudoPod-LaTeX-*' ],
    script_files         => [ catfile(qw( scripts ppod2latex )) ],
);

$builder->create_build_script();
