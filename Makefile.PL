use ExtUtils::MakeMaker;
WriteMakefile(
    NAME		=> 'Image::XBin',
    VERSION_FROM	=> 'lib/Image/XBin.pm', 
    PREREQ_PM		=> 
			    { 
				File::Sauce	=> 0.03,
			    },
              );
