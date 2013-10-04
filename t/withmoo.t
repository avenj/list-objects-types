BEGIN {
  unless (eval {; require Moo; require MooX::late; 1 } && !$@) {
    require Test::More;
    Test::More::plan(skip_all =>
      'these tests require Moo and MooX::late'
    );
  }

  unless (eval {; MooX::late->VERSION(0.014) }) {
    require Test::More;
    Test::More::plan(skip_all =>
      'these tests require MooX::late-0.014 or newer'
    );
  }
}

use Test::More;
use strict; use warnings FATAL => 'all';

{ package
    Foo;
  use List::Objects::Types -all;
  use List::Objects::WithUtils;
  use Moo;
  use MooX::late;

  has myarray => (
    is  => 'ro',
    isa => ArrayObj,
    default => sub { array },
  );

  has myimmarray => (
    is  => 'ro',
    isa => ImmutableArray,
    default => sub { immarray },
  );

  has myhash => (
    is  => 'ro',
    isa => HashObj,
    default => sub { hash },
  );

  has mycoercible => (
    is  => 'ro',
    isa => ArrayObj,
    coerce => 1,
    default => sub { [] },
  );
}

my $foo = Foo->new;
ok $foo->myarray->does('List::Objects::WithUtils::Role::Array'),
  '->array() ok';
ok $foo->myimmarray->isa('List::Objects::WithUtils::Array::Immutable'),
  '->immarray() ok';
ok $foo->myhash->does('List::Objects::WithUtils::Role::Hash'),
  '->hash() ok';
ok $foo->mycoercible->does('List::Objects::WithUtils::Role::Array'),
  '->mycoercible ok';

done_testing;
