use Test::More;
use strict; use warnings FATAL => 'all';

{ package
    Foo;
  use List::Objects::Types -all;
  use List::Objects::WithUtils;
  use Moo;

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
}

my $foo = Foo->new;
ok $foo->myarray->does('List::Objects::WithUtils::Role::Array'),
  '->array() ok';
ok $foo->myimmarray->isa('List::Objects::WithUtils::Array::Immutable'),
  '->immarray() ok';
ok $foo->myhash->does('List::Objects::WithUtils::Role::Hash'),
  '->hash() ok';

done_testing;
