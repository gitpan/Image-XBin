use ExtUtils::MakeMaker;
WriteMakefile(
    NAME		=> 'Image::Xbin',
    VERSION_FROM	=> 'lib/Image/XBin.pm', 
    PREREQ_PM		=> 
			    { 
				File::Sauce	=> 0.3,
			    },
              );
