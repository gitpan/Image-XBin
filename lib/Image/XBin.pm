package Image::XBin;

use strict;
use Carp;
use File::SAUCE;

use Image::XBin::Palette;
use Image::XBin::Font;

$Image::XBin::VERSION = '0.01';

use constant XBIN_ID               => 'XBIN';

# Header byte constants
use constant PALETTE               => 1;
use constant FONT                  => 2;
use constant COMPRESSED            => 4;
use constant NON_BLINK             => 8;
use constant FIVETWELVE_CHARS      => 16;

# Compression byte constants
use constant COMPRESSION_TYPE      => 192;
use constant COMPRESSION_COUNTER   => 63;

# Compression type constants
use constant NO_COMPRESSION        => 0;
use constant CHARACTER_COMPRESSION => 64;
use constant ATTRIBUTE_COMPRESSION => 128;
use constant FULL_COMPRESSION      => 192;

# Attribute byte constants
use constant ATTR_BLINK            => 128;
use constant ATTR_BG               => 112;
use constant ATTR_512              => 8;
use constant ATTR_FG               => 7;

my $header_template   = 'A4 C S S C C';
my @header_fields     = qw( id eofchar width height fontsize flags );
my $eof_char          = chr( 26 );

# XBin:
#
#	Header		Required
#	Palette		Optional
#	Font		Optional
#	Image Data	Optional

sub new {
	my $class = shift;
	my $self = {};

	bless $self, $class;

	$self->clear;
	if ( @_ == 1 ) {
		$self->read( shift );
	}
	else {
		# create new using options
	}

	return $self;
}

sub clear {
	my $self = shift;

	$self->{
		header  => {
			width  => 0,
			height => 0
		},
		image   => [],
		font    => [],
		palette => []
	};
}

sub read {
	my ( $self, $file ) = @_;

	my( $data, $counter );

	if ( $file =~ /^XBIN$eof_char/ ) {
		$data = $file;
	}
	elsif ( ref( $file ) eq 'GLOB' ) {
		# read from filehandle

		{
			local $/;
			$data = <$file>;
		}
	}
	else {
		# open and read from filename

		if ( not open( FILE, $file ) ) {
			$@ = "File open error ($file): $!";
			return undef;
		}

		binmode( FILE );

		{
			local $/;
			$data = <FILE>;
		}

		close( FILE ) or carp( "File close error ($file): $!" );
	}

	return undef unless $data;

	$data = $self->_remove_sauce( $data );

	$self->_read_header( substr( $data, 0, 11 ) );

	$counter = 11;

	# read palette if it has one
	if ( $self->has_palette ) {
		$self->_read_palette( substr( $data, $counter, 48 ) );
		$counter += 48;
	}

	# read font if it has one
	if ( $self->has_font ) {
		my $chars = $self->{header}->{fontsize} * ( $self->has_512chars ? 512 : 256 );
		$self->_read_font( substr( $data, $counter, $chars ) );
		$counter += $chars;
	}

	# read compressed or uncompressed data
	if ( $self->is_compressed ) {
		$self->_read_compressed( substr( $data, $counter ) );
	}
	else {
		$self->_read_uncompressed( substr( $data, $counter ) );
	}
}

sub _remove_sauce {
	my ( $self, $data ) = @_;
	my $sauce = File::SAUCE->new;

	my $val = $sauce->remove( $data, 1 );

	return $val || $data;
}

sub _read_header {
	my ( $self, $data ) = @_;
	my %data;

	# ID to identify an XBIN
	return 0 unless $data =~ /^XBIN$eof_char/;

	@data{@header_fields} = unpack( $header_template, $data );
	$self->{header}       = \%data;

	return 1;
}

sub _read_palette {
	my ( $self, $data ) = @_;

	$self->{ palette } = Image::XBin::Palette->new( $data );
}

sub _read_font {
	my ( $self, $data ) = @_;

	my $chars  = $self->has_512chars ? 512 : 256;
	my $height = $self->{ header }->{ fontsize };
}

sub _read_compressed {
	my ( $self, $data ) = @_;

	@_ = unpack( 'C*', $data );

	my $image = [];

	while ( @_ ) { 
		my ( $char, $attr );

		$char = shift;

		my $type    = $char & COMPRESSION_TYPE;
		my $counter = $char & COMPRESSION_COUNTER;

		if ( $type == NO_COMPRESSION ) {
			push @$image, [ chr( shift ), shift ] for ( 0..$counter );
		}
		elsif ( $type == CHARACTER_COMPRESSION ) {
			$char = shift;
			push @$image, [ chr( $char ), shift ] for ( 0..$counter );
		}
		elsif ( $type == ATTRIBUTE_COMPRESSION ) {
			$attr = shift;
			push @$image, [ chr( shift ), $attr ] for ( 0..$counter );
		}
		else { # FULL_COMPRESSION
			$char = shift;
			$attr = shift;
			push @$image, [ chr( $char ), $attr ] for ( 0..$counter );
		}
	}

	@$image = @{ $image }[ 0..( $self->{ header }->{ width } * $self->{ header }->{ height } - 1 ) ];

	$self->{ image } = $image;
}

sub _read_uncompressed {
	my ( $self, $data ) = @_;

	@_ = unpack( 'C*', $data );

	my $image = [];

	# no compression, so read in everything 2 at a time
	while ( @_ ) {
		push @$image, [ chr( shift ), shift ];
	}

	$self->{ image } = $image;
}

sub has_palette {
	return $_[0]->{ header }->{ flags } & PALETTE;
}

sub has_font {
	return ( $_[0]->{ header }->{ flags } & FONT ) >> 1;
}

sub is_compressed {
	return ( $_[0]->{ header }->{ flags } & COMPRESSED ) >> 2;
}

sub is_nonblink {
	return ( $_[0]->{ header }->{ flags } & NON_BLINK ) >> 3;
}

sub has_512chars {
	return ( $_[0]->{ header }->{ flags } & FIVETWELVE_CHARS ) >> 4;
}

sub width {
	return $_[0]->{ header }->{ width };
}

sub height {
	return $_[0]->{ header }->{ height };
}

sub putpixel {
	my $self = shift;
	my( $x, $y, $char, $attr ) = @_;

	$self->{ image }->[ $y * $self->width + $x ] = [ $char, $attr ];
}

sub getpixel {
	my $self = shift;
	my( $x, $y ) = @_;

	return @{ $self->{ image }->[ $y * $self->width + $x ] };
}

sub attr_blink {
	my $self = shift;
	my $attr = shift;

	return ( $attr & ATTR_BLINK ) >> 7;
}

sub attr_bg {
	my $self = shift;
	my $attr = shift;

	return ( $attr & ATTR_BG ) >> 4;
}

sub attr_512 {
	my $self = shift;
	my $attr = shift;

	return ( $attr & ATTR_512 ) >> 3;
}

sub attr_fg {
	my $self = shift;
	my $attr = shift;

	return ( $attr & ATTR_FG );
}

sub font {
	my $self = shift;
	my $font = shift;

	return $self->{ font } unless $font;

	$self->{ font } = $font if ref $font eq 'Image::XBin::Font';
}

sub palette {
	my $self    = shift;
	my $palette = shift;

	return $self->{ palette } unless $palette;

	$self->{ palette } = $palette if ref $palette eq 'Image::XBin::Palette';
}

1;

=pod

=head1 NAME

Image::XBin - Load, create, manipulate and save XBin image files

=head1 SYNOPSIS

	use Image::XBin;

	# Read the data...
	# ...a filename, a reference to a filehandle, or raw data
	my $img = Image::XBin->new('myxbin.xb');

	# Image width and height
	my $w = $img->width;
	my $h = $img->height;

	# get and put "pixels"
	my ( $char, $attr ) = $img->getpixel( $x, $y );
	$img->putpixel( $x, $y, $char, $attr );

	# font (XBin::Font)
	my $font = $img->font;

	# palette (XBin::Palette)
	my $palette = $img->palette;

=head1 DESCRIPTION

XBin stands for "eXtended BIN" -- an extention to the normal raw-image BIN files.

XBin features:

	+ allows for binary images up to 65536 columns wide, and 65536 lines high
	+ can have an alternate set of palette colors either in blink or in non-blink mode
	+ can have different textmode fonts from 1 to 32 scanlines high, consisting of
	  either 256 or 512 different characters
	+ can be compressed

XBin file stucture:

	+------------+
	| Header     |
	+------------+
	| Palette    |
	+------------+
	| Font       |
	+------------+
	| Image Data |
	+------------+

Note, the only required element is a header. See the XBin specs for for information.
http://www.acid.org/info/xbin/xbin.htm

=head1 METHODS

=over 4

=item new([$filename or \*FILEHANDLE or $rawdata])

Creates a new XBin image. Currently only reads in data.

=item read($filename or \*FILEHANDLE or $rawdata)

Explicitly reads data.

=item clear()

Clears any in-memory data.

=item font([Image::XBin::Font])

Gets or sets the font. Must be of type Image::XBin::Font.

=item palette([Image::XBin::Palette])

Gets or sets the palette. Must be of type Image::XBin::Palette.

=item width()

Returns the image width.

=item height()

Returns the image height.

=item getpixel($x, $y)

Returns an array of the character and the attribute byte for the
"pixel" at $x, $y.

=item putpixel($x, $y, $char, $attr)

Sets the pixel at $x, $y with $char and $attr.

=item attr_blink($attr)

Returns the blink bit of the attribute byte.

=item attr_bg($attr)

Returns the background palette index.

=item attr_512($attr)

Returns the 512 bit of the attribute byte.

=item attr_fg($attr)

Returns the foreground palette index.

=item has_palette()

Returns true if the file has a palette defined.

=item has_font()

Returns true if the file has a font defined.

=item is_compressed()

Returns true if the data was compressed

=item is_nonblink()

Returns true if the file is in non-blink mode.

=back

=head1 TODO

	+ write a save method (with compression)
	+ use new()'s options to create a new file from scratch

=head1 BUGS

If you have any questions, comments, bug reports or feature suggestions, 
email them to Brian Cassidy <brian@alternation.net>.

=head1 CREDITS

This module was written by Brian Cassidy (http://www.alternation.net/).

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms
of the Artistic License, distributed with Perl.

=cut