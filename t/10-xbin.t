use Test::More qw( no_plan );

BEGIN { 
    use_ok( 'Image::XBin' );
}

my $xbin = Image::XBin->new;

isa_ok( $xbin, 'Image::XBin' );

$xbin->width( 80 );
$xbin->height( 25 );

is( $xbin->width, 80, '$xbin->width' );
is( $xbin->height, 25, '$xbin->height' );