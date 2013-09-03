package List::Objects::Types;
use strict; use warnings FATAL => 'all';

use Type::Library -base;
use Type::Utils   -all;
use Types::Standard -types;
use Types::TypeTiny 'to_TypeTiny';

use List::Objects::WithUtils qw/array immarray hash/;
use List::Objects::WithUtils::Array::Typed qw/array_of/;

declare ArrayObj =>
  as ConsumerOf[ 'List::Objects::WithUtils::Role::Array' ];

coerce ArrayObj =>
  from ArrayRef() =>
  via { array(@$_) };


declare ImmutableArray =>
  as ArrayObj =>
  where { $_->isa('List::Objects::WithUtils::Array::Immutable') },
  inline_as { (undef, qq[$_->isa('List::Objects::WithUtils::Array::Immutable')]) };

coerce ImmutableArray =>
  from ArrayRef() =>
    via { immarray(@$_) },
  from ArrayObj =>
    via { immarray($_->all) };

declare ImmutableArrayObj => as 'ImmutableArray';


declare TypedArray =>
  as InstanceOf[ 'List::Objects::WithUtils::Array::Typed' ],
  constraint_generator => sub {
    my $param = to_TypeTiny(shift);
    return sub { $_->{type}->is_a_type_of($param) };
  },
  coercion_generator => sub {
    my ($parent, $child, $param) = @_;
    my $c = Type::Coercion->new(type_constraint => $child);
    if ($param->has_coercion)
    {
      my $inner = $param->coercion;
      $c->add_type_coercions(
        ArrayRef() => sub { array_of($param, map { $inner->coerce($_) } @$_) },
        ArrayObj() => sub { array_of($param, map { $inner->coerce($_) } $_->all) },
      );
    }
    else
    {
      $c->add_type_coercions(
        ArrayRef() => sub { array_of($param, @$_) },
        ArrayObj() => sub { array_of($param, $_->all) },
      );
    }
    return $c->freeze;
  };


declare HashObj =>
  as ConsumerOf[ 'List::Objects::WithUtils::Role::Hash' ];

coerce HashObj =>
  from HashRef,
  via { hash(%$_) };

1;


=pod

=head1 NAME

List::Objects::Types - Type::Tiny-based types for List::Objects::WithUtils

=head1 SYNOPSIS

  package Foo;

  use List::Objects::Types -all;
  use List::Objects::WithUtils;
  use Moo;

  has my_array => (
    is  => 'ro',
    isa => ArrayObj,
    default => sub { array }
  );

  has my_hash => (
    is  => 'ro',
    isa => HashObj,
    default => sub { hash }
  );

  has static_array => (
    is  => 'ro',
    isa => ImmutableArray,
    default => sub { immarray(qw/ foo bar /) }
  );

=head1 DESCRIPTION

A small set of L<Type::Tiny>-based types & coercions.

Also see L<MoopsX::ListObjects>, which provides L<Moops> class-building sugar
with L<List::Objects::WithUtils> integration.

=head3 ArrayObj

An object that consumes L<List::Objects::WithUtils::Role::Array>.

Can be coerced from a plain ARRAY; a shallow copy is performed.

=head3 HashObj

An object that consumes L<List::Objects::WithUtils::Role::Hash>.

Can be coerced from a plain HASH; a shallow copy is performed.

=head3 ImmutableArray

An object that isa L<List::Objects::WithUtils::Array::Immutable>.

Can be coerced from a plain ARRAY or an L</ArrayObj>; a shallow copy is performed.

=head3 TypedArray

An object that isa L<List::Objects::WithUtils::Array::Typed>.

Not coercible.

=head3 TypedArray[`a]

TypedArray can be parameterized with another type constraint. For
example, the type constraint C<< TypedArray[Num] >> will accept
C<< array_of(Num, 1, 2, 3.14159) >>, and will also accept
C<< array_of(Int, 1, 2, 3) >> because C<Int> is a subtype of C<Num>.

Can be coerced from a plain ARRAY or an L</ArrayObj>; a shallow copy is
performed. If the parameter also has a coercion, this will be applied
to each item in the new array.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org> with significant helpful contributions from
Toby Inkster (CPAN: TOBYINK)

=cut
