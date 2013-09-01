use strict; use warnings FATAL => 'all';

use Test::More;
use Test::TypeTiny;

use Types::Standard -types;

use List::Objects::Types -all;
use List::Objects::WithUtils qw/
  array
  array_of
  immarray
  hash
/;

# array/hash
should_pass array(), ArrayObj;
should_pass hash(),  HashObj;

# immarray
ok_subtype ArrayObj, ImmutableArray;
should_pass immarray(), ArrayObj;
should_pass immarray(), ImmutableArray;

# array_of
should_pass array_of(Int() => 2, 3, 4), TypedArray;

# failures
should_fail [],  ArrayObj;
should_fail +{}, HashObj;
should_fail [],  ImmutableArray;
should_fail [],  TypedArray;
should_fail array(), ImmutableArray;
should_fail array(), TypedArray;

# unions
should_pass [],       (ArrayRef | ArrayObj);
should_pass array(),  (ArrayRef | ArrayObj);
should_fail 'foo',    (ArrayRef | ArrayObj);

# helpers
ok is_ArrayObj(array), 'is_ArrayObj ok';
ok is_HashObj(hash),   'is_HashObj ok';
ok is_ImmutableArray(immarray), 'is_ImmutableArray ok';

# coercions
my $coerced = ArrayObj->coerce([]);
ok $coerced->count == 0, 'ArrayRef coerced to ArrayObj ok';

$coerced = ImmutableArray->coerce($coerced);
ok is_ImmutableArray($coerced), 'ArrayObj coerced to ImmutableArray ok';

$coerced = HashObj->coerce(+{});
ok $coerced->keys->count == 0, 'HashRef coerced to HashObj ok';

done_testing;
