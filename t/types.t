use strict; use warnings FATAL => 'all';

use Test::More;
use Test::TypeTiny;

use List::Objects::Types -all;
use List::Objects::WithUtils;

should_pass array(), ArrayObj;

should_pass hash(),  HashObj;

ok_subtype ArrayObj, ImmutableArray;
should_pass immarray(), ArrayObj;
should_pass immarray(), ImmutableArray;

should_fail [],  ArrayObj;
should_fail +{}, HashObj;
should_fail [],  ImmutableArray;
should_fail array(), ImmutableArray;

done_testing;
