package Image::XBin::Font;

use strict;

$image::XBin::Font::VERSION = '0.01';

sub new {
	my $class = shift;
	my ( $data, $chars, $height ) = @_;
	my $self  = {};

	bless $self, $class;

	$self->clear;
	$self->read( $data, $chars, $height ) if $data;

	return $self;
}

sub read {
	my $self = shift;
	my ( $data, $chars, $height ) = @_;

	$self->{ data } = $data if ref( $data ) eq 'ARRAY';

	$self->{ chars  } = $chars;
	$self->{ height } = $height;

	my @font = unpack( 'C*', $data );

	my $font = [];
	for my $i ( 0..$chars - 1 ) {
		push @$font, [];
		for my $j ( 0..$height - 1 ) {
			push @{ $font->[ $#{ $font } ] }, $font[ $i * $height + $j ];
		}
	}

	$self->{ data } = $font;
}

sub clear {
	my $self = shift;

	$self->{ data } = [];
}

1;

=pod

=head1 NAME

Image::XBin::Font - Manipulate XBin font data

=head1 SYNOPSIS

	use Image::XBin::Font;

	# Read the data...
	my $fnt = Image::XBin::Font->new( $data, $chars, $height );

	# Clear the data
	$fnt->clear;

=head1 DESCRIPTION

Xbin images can contain font data. This module will allow you to create, and manipulate that data.

=head1 METHODS

=over 4

=item new($data, $chars, $height)

Creates a new Image::XBin::Font object. Reads in the data for $chars characters. Each character has $height scanlines.

=item read($data, $chars, $height)

Explicitly reads in data.

=item clear()

Clears any in-memory data.

=back

=head1 TODO

	+ write some useful methods :)

=head1 BUGS

If you have any questions, comments, bug reports or feature suggestions, 
email them to Brian Cassidy <brian@alternation.net>.

=head1 CREDITS

This module was written by Brian Cassidy (http://www.alternation.net/).

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms
of the Artistic License, distributed with Perl.

=cut