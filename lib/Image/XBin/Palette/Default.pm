package Image::XBin::Palette::Default;

=head1 NAME

Image::XBin::Palette::Default - The default palette

=head1 SYNOPSIS

	$pal = Image::XBin::Palette::Default->new;

=cut

use base qw( Image::XBin::Palette );

use strict;
use warnings;

our $VERSION = '0.01';

my $palette = [
	[ 0,   0,   0   ], # black
	[ 170, 0,   0   ], # red
	[ 0,   170, 0   ], # green
	[ 170, 85,  0   ], # yellow
	[ 0,   0,   170 ], # blue
	[ 170, 0,   170 ], # magenta
	[ 0,   170, 170 ], # cya
	[ 170, 170, 170 ], # white
	                   # bright
	[ 85,  85,  85  ], # black
	[ 255, 85,  85  ], # red
	[ 85,  255, 85  ], # green
	[ 255, 255, 85  ], # yellow
	[ 85,  85,  255 ], # blue
	[ 255, 85,  255 ], # magenta
	[ 85,  255, 255 ], # cyan
	[ 255, 255, 255 ]  # white
];

sub new {
	my $class = shift;
	my $self  = $class->SUPER::new;

	bless $self, $class;

	for( 0..@$palette ) {
		$self->set( $_, $palette->[ $_ ] );
	}

	return $self;
}

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