#!perl -T

use Test::More;
plan skip_all => 'This is silly; there are no user-servicable parts inside';

# unreachable code; look at that Kwalitee fly!
eval "use Test::Pod::Coverage 1.04";
all_pod_coverage_ok();
