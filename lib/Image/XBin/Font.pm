package Image::XBin::Font;

=head1 NAME

Image::XBin::Font - Manipulate XBin font data

=head1 SYNOPSIS

	use Image::XBin::Font;

	# Read the data...
	my $fnt = Image::XBin::Font->new( $data, $chars, $height );

	# Get output suitable for saving...
	my $out = $fnt->as_string;

	# Clear the data
	$fnt->clear;

=head1 DESCRIPTION

Xbin images can contain font data. This module will allow you to create, and manipulate that data.

=cut

use strict;
use warnings;

our $VERSION = '0.03';

=head1 METHODS

=head2 new( [$data, $chars] )

Creates a new Image::XBin::Font object. Reads in the data for $chars characters. Each character has $data/$height scanlines.

=cut

sub new {
	my $class = shift;
	my ( $data, $chars ) = @_;
	my $self  = {};

	bless $self, $class;

	$self->clear;
	$self->read( $data, $chars ) if $data;

	return $self;
}

=head2 read( $data, $chars )

Explicitly reads in data.

=cut

sub read {
	my $self = shift;
	my ( $data, $chars ) = @_;

#	$self->{ data } = $data if ref( $data ) eq 'ARRAY';

	$self->{ chars  } = $chars;
	$self->{ height } = length( $data ) / $chars;

	my @font = unpack( 'C*', $data );

	my $height = $self->{ height };
	my $font = [];
	for my $i ( 0..$chars - 1 ) {
		push @$font, [];
		for my $j ( 0..$height - 1 ) {
			push @{ $font->[ $#{ $font } ] }, $font[ $i * $height + $j ];
		}
	}

	$self->{ data } = $font;
}

=head2 as_string( )

Returns the font as a pack()'ed string - suitable for saving in an XBin.

=cut

sub as_string {
	my $self = shift;

	my $output;

	for my $char ( @{ $self->{ data } } ) {
		$output .= pack( 'C', $_ ) for @{ $char };
	}

	return $output;	
}

=head2 clear( )

Clears any in-memory data.

=cut

sub clear {
	my $self = shift;

	$self->{ data } = [];
}

=head1 TODO

=over 4

=item * write some useful methods :)

=back

=head1 AUTHOR

=over 4 

=item * Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Brian Cassidy

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;