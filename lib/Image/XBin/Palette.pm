package Image::XBin::Palette;

use strict;

$image::XBin::Palette::VERSION = '0.01';

sub new {
	my $class = shift;
	my $data  = shift;
	my $self  = {};

	bless $self, $class;

	$self->clear;
	$self->read( $data ) if $data;

	return $self;
}

sub read {
	my $self    = shift;
	my $data    = shift;

	$self->{ data } = $data if ref( $data ) eq 'ARRAY';

	my @palette = unpack( 'C*', $data );

	my $palette = [];
	for my $i ( 0..15 ) {
		push @$palette, [];
		for my $j ( 0..2 ) {
			push @{ $palette->[ $#{ $palette } ] }, $palette[ $i * 3 + $j ];
		}
	}

	$self->{ data } = $palette;
}

sub get {
	my $self  = shift;
	my $index = shift;

	return $self->{ data }->[ $index ]; 
}

sub set {
	my $self = shift;
	my ( $index, $rgb ) = @_;

	$self->{ data }->[ $index ] = $rgb; 
}

sub clear {
	my $self = shift;

	$self->{ data } = [];
}

1;

=pod

=head1 NAME

Image::XBin::Palette - Manipulate XBin palette data

=head1 SYNOPSIS

	use Image::XBin::Palette;

	# Read the data...
	my $pal = Image::XBin::Palette->new( $data );

	# Get
	my $rgb = $pal->get( $index );

	# Set
	$pal->set( $index, $rgb );

	# Clear the data
	$pal->clear;

=head1 DESCRIPTION

Xbin images can contain palette (16 indexes) data. This module will allow you to create, and manipulate that data.

=head1 METHODS

=over 4

=item new($data)

Creates a new Image::XBin::Palette object. Unpacks 16 rgb triples.

=item read($data)

Explicitly reads in data.

=item clear()

Clears any in-memory data.

=item get($index)

Get the rgb triple at index $index

=item set($index, $rgb)

Write an rgb triple at index $index

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