package List::Objects::Types;
use strict; use warnings FATAL => 'all';

use Type::Library -base;
use Type::Utils   -all;
use Types::Standard -types;

use List::Objects::WithUtils qw/array immarray hash/;

declare ArrayObj =>
  as Object,
  where { $_->does('List::Objects::WithUtils::Role::Array') };

coerce ArrayObj =>
  from ArrayRef,
  via { array(@$_) };


declare ImmutableArray =>
  as 'ArrayObj',
  where { $_->isa('List::Objects::WithUtils::Array::Immutable') };

coerce ImmutableArray =>
  from ArrayRef,
  via { immarray(@$_) };

declare ImmutableArrayObj => as 'ImmutableArray';


declare HashObj =>
  as Object,
  where { $_->does('List::Objects::WithUtils::Role::Hash') };

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

Can be coerced from a plain ARRAY; a shallow copy is performed.

=head1 AUTHOR

Jon Portnoy <avenj@cobaltirc.org>

=cut
