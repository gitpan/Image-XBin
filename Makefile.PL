use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'Image::XBin',
	VERSION_FROM => 'lib/Image/XBin.pm', 
	PREREQ_PM    => {
		'Class::Accessor' => 0,
		'File::SAUCE'     => 0.12,
		'IO::File'        => 0,
		'IO::String'      => 0,
	}
);
