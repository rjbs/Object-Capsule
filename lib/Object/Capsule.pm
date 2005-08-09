package Object::Capsule;

use warnings;
use strict;

=head1 NAME

Object::Capsule - wrap any object in a flavorless capsule

=head1 VERSION

version 0.01

	$Id: Capsule.pm,v 1.5 2004/09/12 14:38:56 rjbs Exp $

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

 use Object::Capsule;
 use Widget;

 my $widget = new Widget;

 my $capsule = encapsulate($widget);

 $capsule->some_widget_method; # performs method on widget

 print ref $capsule;  # prints "Object::Capsule"

 print ref $$capsule; # prints "Widget"

=head1 DESCRIPTION

An Object::Capsule is a thin, permeable membrane that fits nicely around an
object.  Method calls are passed on to the object, which functions normally
inside the capsule.  The object can be retrieved by dereferencing the capsule
as a scalar.

My intent is to use an object capsule subclass to allow the inflation of
multiple object types from a single column in Class::DBI.

=head1 FUNCTIONS

=head2 C< encapsulate($object) >

This function encases the given object in an Object::Capsule and returns the
capsule.  It's exported by default and is otherwise non-existent.

=cut

sub import {
	my ($importer) = caller;
	no strict 'refs';
	*{$importer."\::encapsulate"} = sub {
		my $object = shift;
		bless \$object => __PACKAGE__;
	}
}

sub AUTOLOAD { 
	my $self = shift;
	my $method = our $AUTOLOAD;
	$method =~ s/.*:://;

	unless (ref $self) {
		my($callpack, $callfile, $callline) = caller;
		die sprintf
			qq{Can\'t locate object method "%s" via package "%s" }.
		  qq{at %s line %d.\n},
			$method, $self, $callfile, $callline;
	}
	return unless UNIVERSAL::can($$self, $method);
	$$self->$method(@_);
}

=begin future

use overload
	'${}'    => sub { $_[0] },
	'""'     => sub { "${$_[0]}" },
	'0+'     => sub { 0 + ${$_[0]} },
	'eq'     => sub { ${$_[0]} eq $_[1] },
	'=='     => sub { ${$_[0]} == $_[1] },
	nomethod => sub {
		my $expr = $_[2]
			? "\$_[1] $_[3] \${\$_[0]}"
			: "\${\$_[0]} $_[3] \$_[1]";
		warn "eval: $expr\n";
		eval $expr;
	},
;

=end future

=cut

=begin automatic

my $overload = q!
	use overload
		'${}'    => sub { $_[0] },
		'""'     => sub { "${$_[0]}" },
		'0+'     => sub { 0 + ${$_[0]} },
		'atan2'  => sub { $_[2] ? atan2($_[1],${$_[0]}) : atan2(${$_[0]},$_[1]) },
		#'<>'     => sub { <${$_[0]}> },
		#'bool'   => sub { ${$_[0]} },
!;

my $overload_binary = sub { 
	"'".$_[0]."' => " .
	q! sub { $_[2]
		? ($_[1] ! . $_[0] . q! ${$_[0]})
		: (${$_[0]} ! . $_[0] . q! $_[1]);
	},
	!;
};

my $overload_unary = sub { 
	"'".$_[0]."' => " .
	q! sub { ! . $_[0] . q!(${$_[0]}) },
	!;
};

$overload .= $overload_binary->($_) for (
	"+", "+=", "-", "-=", "*", "*=", "/", "/=", "%", "%=", "**", "**=", "<<",
	"<<=", ">>", ">>=", "x", "x=", ".", ".=", "<", "<=", ">", ">=", "==", "!=",
	"<=>", "lt", "le", "gt", "ge", "eq", "ne", "cmp", "&", "^", "|");

$overload .= $overload_unary->($_) for (
	"neg", "!", "~", "cos", "sin", "exp", "abs", "log", "sqrt", "int");

$overload .= ';';

eval $overload;

=end automatic

=cut

# ++ --

use overload
	'${}'    => sub { $_[0] },
	'@{}'    => sub { @{$_[0]} },
	'%{}'    => sub { %{$_[0]} },
	'*{}'    => sub { *{$_[0]} },
	'""'     => sub { "${$_[0]}" },
	'0+'     => sub { 0 + ${$_[0]} },
	'bool'   => sub { ${$_[0]} },
	'+'   =>  sub { $_[2] ? ($_[1] + ${$_[0]})   : (${$_[0]} + $_[1]); },
	'+='  =>  sub { $_[2] ? ($_[1] += ${$_[0]})  : (${$_[0]} += $_[1]); },
	'-'   =>  sub { $_[2] ? ($_[1] - ${$_[0]})   : (${$_[0]} - $_[1]); },
	'-='  =>  sub { $_[2] ? ($_[1] -= ${$_[0]})  : (${$_[0]} -= $_[1]); },
	'*'   =>  sub { $_[2] ? ($_[1] * ${$_[0]})   : (${$_[0]} * $_[1]); },
	'*='  =>  sub { $_[2] ? ($_[1] *= ${$_[0]})  : (${$_[0]} *= $_[1]); },
	'/'   =>  sub { $_[2] ? ($_[1] / ${$_[0]})   : (${$_[0]} / $_[1]); },
	'/='  =>  sub { $_[2] ? ($_[1] /= ${$_[0]})  : (${$_[0]} /= $_[1]); },
	'%'   =>  sub { $_[2] ? ($_[1] % ${$_[0]})   : (${$_[0]} % $_[1]); },
	'%='  =>  sub { $_[2] ? ($_[1] %= ${$_[0]})  : (${$_[0]} %= $_[1]); },
	'**'  =>  sub { $_[2] ? ($_[1] ** ${$_[0]})  : (${$_[0]} ** $_[1]); },
	'**=' =>  sub { $_[2] ? ($_[1] **= ${$_[0]}) : (${$_[0]} **= $_[1]); },
	'<<'  =>  sub { $_[2] ? ($_[1] << ${$_[0]})  : (${$_[0]} << $_[1]); },
	'<<=' =>  sub { $_[2] ? ($_[1] <<= ${$_[0]}) : (${$_[0]} <<= $_[1]); },
	'>>'  =>  sub { $_[2] ? ($_[1] >> ${$_[0]})  : (${$_[0]} >> $_[1]); },
	'>>=' =>  sub { $_[2] ? ($_[1] >>= ${$_[0]}) : (${$_[0]} >>= $_[1]); },
	'x'   =>  sub { $_[2] ? ($_[1] x ${$_[0]})   : (${$_[0]} x $_[1]); },
	'x='  =>  sub { $_[2] ? ($_[1] x= ${$_[0]})  : (${$_[0]} x= $_[1]); },
	'.'   =>  sub { $_[2] ? ($_[1] . ${$_[0]})   : (${$_[0]} . $_[1]); },
	'.='  =>  sub { $_[2] ? ($_[1] .= ${$_[0]})  : (${$_[0]} .= $_[1]); },
	'<'   =>  sub { $_[2] ? ($_[1] < ${$_[0]})   : (${$_[0]} < $_[1]); },
	'<='  =>  sub { $_[2] ? ($_[1] <= ${$_[0]})  : (${$_[0]} <= $_[1]); },
	'>'   =>  sub { $_[2] ? ($_[1] > ${$_[0]})   : (${$_[0]} > $_[1]); },
	'>='  =>  sub { $_[2] ? ($_[1] >= ${$_[0]})  : (${$_[0]} >= $_[1]); },
	'=='  =>  sub { $_[2] ? ($_[1] == ${$_[0]})  : (${$_[0]} == $_[1]); },
	'!='  =>  sub { $_[2] ? ($_[1] != ${$_[0]})  : (${$_[0]} != $_[1]); },
	'<=>' =>  sub { $_[2] ? ($_[1] <=> ${$_[0]}) : (${$_[0]} <=> $_[1]); },
	'lt'  =>  sub { $_[2] ? ($_[1] lt ${$_[0]})  : (${$_[0]} lt $_[1]); },
	'le'  =>  sub { $_[2] ? ($_[1] le ${$_[0]})  : (${$_[0]} le $_[1]); },
	'gt'  =>  sub { $_[2] ? ($_[1] gt ${$_[0]})  : (${$_[0]} gt $_[1]); },
	'ge'  =>  sub { $_[2] ? ($_[1] ge ${$_[0]})  : (${$_[0]} ge $_[1]); },
	'eq'  =>  sub { $_[2] ? ($_[1] eq ${$_[0]})  : (${$_[0]} eq $_[1]); },
	'ne'  =>  sub { $_[2] ? ($_[1] ne ${$_[0]})  : (${$_[0]} ne $_[1]); },
	'cmp' =>  sub { $_[2] ? ($_[1] cmp ${$_[0]}) : (${$_[0]} cmp $_[1]); },
	'&'   =>  sub { $_[2] ? ($_[1] & ${$_[0]})   : (${$_[0]} & $_[1]); },
	'^'   =>  sub { $_[2] ? ($_[1] ^ ${$_[0]})   : (${$_[0]} ^ $_[1]); },
	'|'   =>  sub { $_[2] ? ($_[1] | ${$_[0]})   : (${$_[0]} | $_[1]); },
	'!'   =>  sub {   !(${$_[0]}) },
	'~'   =>  sub {   ~(${$_[0]}) },
	'neg' =>  sub { neg(${$_[0]}) },
	'cos' =>  sub { cos(${$_[0]}) },
	'sin' =>  sub { sin(${$_[0]}) },
	'exp' =>  sub { exp(${$_[0]}) },
	'abs' =>  sub { abs(${$_[0]}) },
	'log' =>  sub { log(${$_[0]}) },
	'int' =>  sub { int(${$_[0]}) },
	'atan2'  => sub { $_[2] ? atan2($_[1],${$_[0]}) : atan2(${$_[0]},$_[1]) },
	'sqrt'   => sub { sqrt(${$_[0]}) },
	'<>'     => sub { <${$_[0]}> },
; 

=head1 AUTHOR

Ricardo Signes, C<< <rjbs@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-object-capsule@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.  I will be notified, and then you'll automatically
be notified of progress on your bug as I make changes.

=head1 TODO

The proxy overloading code is hideous.  The "future" version in the code had
bizarre problems that I couldn't quite solve, but I'll try again sometime.

=head1 COPYRIGHT & LICENSE

Copyright 2004 Ricardo Signes, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
