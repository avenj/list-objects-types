package List::Objects::Types;
use strict; use warnings FATAL => 'all';

use Type::Library -base;
use Type::Utils   -all;
use Types::Standard -types;
use Types::TypeTiny ();

use List::Objects::WithUtils;


declare ArrayObj =>
  as ConsumerOf[ 'List::Objects::WithUtils::Role::Array' ];

coerce ArrayObj =>
  from ArrayRef() => via { array(@$_) };


declare ImmutableArray =>
  as ArrayObj(),
  where     { $_->does('List::Objects::WithUtils::Role::Array::Immutable') },
  inline_as { 
    (undef, qq[$_->does('List::Objects::WithUtils::Role::Array::Immutable')]) 
  };

coerce ImmutableArray =>
  from ArrayRef() => via { immarray(@$_) },
  from ArrayObj() => via { immarray($_->all) };


declare TypedArray =>
  as ConsumerOf[ 'List::Objects::WithUtils::Role::Array::Typed' ],
  constraint_generator => sub {
    my $param = Types::TypeTiny::to_TypeTiny(shift);
    return sub { $_->type->is_a_type_of($param) }
  },
  coercion_generator => sub {
    my ($parent, $child, $param) = @_;
    my $c = Type::Coercion->new(type_constraint => $child);
    if ($param->has_coercion) {
      my $inner = $param->coercion;
      $c->add_type_coercions(
        ArrayRef() => sub { array_of($param, map {; $inner->coerce($_) } @$_) },
        ArrayObj() => sub { array_of($param, map {; $inner->coerce($_) } $_->all) },
      );
    } else {
      $c->add_type_coercions(
        ArrayRef() => sub { array_of($param, @$_) },
        ArrayObj() => sub { array_of($param, $_->all) },
      );
    }

    return $c->freeze
  };

declare ImmutableTypedArray =>
  as InstanceOf[ 'List::Objects::WithUtils::Array::Immutable::Typed' ],
  constraint_generator => sub {
    my $param = Types::TypeTiny::to_TypeTiny(shift);
    return sub { $_->type->is_a_type_of($param) }
  },
  coercion_generator => sub {
    my ($parent, $child, $param) = @_;
    my $c = Type::Coercion->new( type_constraint => $child );
    if ($param->has_coercion) {
      my $inner = $param->coercion;
      $c->add_type_coercions(
        ArrayRef() => sub { 
          immarray_of($param, map {; $inner->coerce($_) } @$_)
        },
        ArrayObj() => sub {
          immarray_of($param, map {; $inner->coerce($_) } $_->all)
        },
      );
    } else {
      $c->add_type_coercions(
        ArrayRef() => sub { immarray_of($param, @$_) },
        ArrayObj() => sub { immarray_of($param, $_->all) },
      );
    }
  };

declare HashObj =>
  as ConsumerOf[ 'List::Objects::WithUtils::Role::Hash' ];

coerce HashObj =>
  from HashRef() => via { hash(%$_) };


declare ImmutableHash =>
  as HashObj(),
  where     { $_->does('List::Objects::WithUtils::Role::Hash::Immutable') },
  inline_as {
    (undef, qq[$_->does('List::Objects::WithUtils::Role::Hash::Immutable')])
  };

coerce ImmutableHash =>
  from HashRef() => via { immhash(%$_) },
  from HashObj() => via { immhash($_->export) };


declare TypedHash =>
  as ConsumerOf[ 'List::Objects::WithUtils::Role::Hash::Typed' ],
  constraint_generator => sub {
    my $param = Types::TypeTiny::to_TypeTiny(shift);
    return sub { $_->type->is_a_type_of($param) }
  },
  coercion_generator => sub {
    my ($parent, $child, $param) = @_;
    my $c = Type::Coercion->new(type_constraint => $child);
    if ($param->has_coercion) {
      my $inner = $param->coercion;
      $c->add_type_coercions(
        HashRef() => sub {
          my %old = %$_; my %new;
          @new{keys %old} = map {; $inner->coerce($_) } values %old;
          hash_of($param, %new)
        },
        HashObj() => sub { 
          my %old = $_->export; my %new;
          @new{keys %old} = map {; $inner->coerce($_) } values %old;
          hash_of($param, %new)
        },
      );
    } else {
      $c->add_type_coercions(
        HashRef() => sub { hash_of($param, %$_) },
        HashObj() => sub { hash_of($param, $_->export) },
      );
    }

 
    return $c->freeze
  };


declare ImmutableTypedHash =>
  as InstanceOf[ 'List::Objects::WithUtils::Hash::Immutable::Typed' ],
  constraint_generator => sub {
    my $param = Types::TypeTiny::to_TypeTiny(shift);
    return sub { $_->type->is_a_type_of($param) }
  },
  coercion_generator => sub {
    my ($parent, $child, $param) = @_;
    my $c = Type::Coercion->new(type_constraint => $child);
    if ($param->has_coercion) {
      my $inner = $param->coercion;
      $c->add_type_coercions(
        HashRef() => sub {
          my %old = %$_; my %new;
          @new{keys %old} = map {; $inner->coerce($_) } values %old;
          immhash_of($param, %new)
        },
        HashObj() => sub { 
          my %old = $_->export; my %new;
          @new{keys %old} = map {; $inner->coerce($_) } values %old;
          immhash_of($param, %new)
        },
      );
    } else {
      $c->add_type_coercions(
        HashRef() => sub { immhash_of($param, %$_) },
        HashObj() => sub { immhash_of($param, $_->export) },
      );
    }

 
    return $c->freeze
  };

1;


=pod

=head1 NAME

List::Objects::Types - Type::Tiny-based types for List::Objects::WithUtils

=head1 SYNOPSIS

  package Foo;

  use List::Objects::Types -all;
  use List::Objects::WithUtils;
  use Moo;
  use MooX::late;

  has my_array => (
    is  => 'ro',
    isa => ArrayObj,
    default => sub { array }
  );

  has static_array => (
    is  => 'ro',
    isa => ImmutableArray,
    coerce  => 1,
    default => sub { [qw/ foo bar /] }
  );

  has my_hash => (
    is  => 'ro',
    isa => HashObj,
    coerce  => 1,
    # Coercible from a plain HASH:
    default => sub { +{} }
  );

  use Types::Standard 'Int', 'Num';
  has my_ints => (
    is  => 'ro',
    # Nums added to this array_of(Int) are coerced to Ints:
    isa => TypedArray[ Int->plus_coercions(Num, 'int($_)') ],
    coerce  => 1,
    default => sub { [1, 2, 3.14] }
  );

=head1 DESCRIPTION

A small set of L<Type::Tiny>-based types & coercions for
L<List::Objects::WithUtils>.

Also see L<MoopsX::ListObjects>, which provides L<Moops> class-building sugar
with L<List::Objects::WithUtils> integration.

=head3 ArrayObj

An object that consumes L<List::Objects::WithUtils::Role::Array>.

Can be coerced from a plain ARRAY; a shallow copy is performed.

=head3 HashObj

An object that consumes L<List::Objects::WithUtils::Role::Hash>.

Can be coerced from a plain HASH; a shallow copy is performed.

=head3 ImmutableArray

An object that consumes L<List::Objects::WithUtils::Role::Array::Immutable>.

Can be coerced from a plain ARRAY or an L</ArrayObj>; a shallow copy is performed.

=head3 TypedArray

An object that consumes L<List::Objects::WithUtils::Role::Array::Typed>.

Not coercible.

=head3 TypedArray[`a]

TypedArray can be parameterized with another type constraint. For
example, the type constraint C<< TypedArray[Num] >> will accept
C<< array_of(Num, 1, 2, 3.14159) >>, and will also accept
C<< array_of(Int, 1, 2, 3) >> because C<Int> is a subtype of C<Num>.

Can be coerced from a plain ARRAY or an L</ArrayObj>; a shallow copy is
performed. If the parameter also has a coercion, this will be applied
to each item in the new array.

(The C<examples/> directory that comes with this distribution contains some
examples of parameterized & coercible TypedArrays.)

=head3 ImmutableTypedArray

An object that isa L<List::Objects::WithUtils::Array::Immutable::Typed>.

Not coercible.

=head3 ImmutableTypedArray[`a]

ImmutableTypedArray can be parameterized with another type constraint, like
L</TypedArray>.

Can be coerced from a plain ARRAY or an L</ArrayObj>.

=head3 TypedHash

An object that consumes L<List::Objects::WithUtils::Role::Hash::Typed>.

Not coercible.

=head3 TypedHash[`a]

TypedHash can be parameterized with another type constraint, like
L</TypedArray>.

Can be coerced from a plain HASH or a L</HashObj>. If the parameter also has a
coercion, this will be applied to each value in the new hash.

=head3 ImmutableTypedHash

An object that isa L<List::Objects::WithUtils::Hash::Immutable::Typed>.

Not coercible.

=head3 ImmutableTypedHash[`a]

ImmutableTypedHash can be parameterized with another type constraint, like
L</TypedHash>.

Can be coerced from a plain HASH or an L</HashObj>.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org> with significant contributions from Toby
Inkster (CPAN: TOBYINK)

=cut
