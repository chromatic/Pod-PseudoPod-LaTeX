#! perl

use strict;
use warnings;

use Test::More tests => 3;

use_ok( 'Pod::PseudoPod::LaTeX' ) or exit;

subtest "default options" => sub {
    plan tests => 2;

    my $parser = Pod::PseudoPod::LaTeX->new();
    ok !$parser->{'keep_ligatures'}, "default keep_ligatures value";
    ok !$parser->{'captions_below'}, "default captions_below value";
};

subtest "set options explicitly" => sub {
    plan tests => 2;

    my $parser = Pod::PseudoPod::LaTeX->new(
        keep_ligatures => 1,
        captions_below => 1,
    );
    ok $parser->{'keep_ligatures'}, "keep_ligatures turned on";
    ok $parser->{'captions_below'}, "captions_below turned on";
};

# vim: expandtab shiftwidth=4
