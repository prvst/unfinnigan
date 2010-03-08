use 5.010000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Finnigan',
    VERSION_FROM      => 'lib/Finnigan.pm', # finds $VERSION
    PREREQ_PM         => {
			  Module::Find => '0.10',
			  DateTime::Format::WindowsFileTime => '0.02',
			 },
    EXE_FILES         => [
			  'bin/uf-header',
			  'bin/uf-seqrow',
			  'bin/uf-casinfo',
			  'bin/uf-rfi',
			 ],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Finnigan.pm', # retrieve abstract from module
       AUTHOR         => 'Gene Selkov <selkovjr@gmail.com>') : ()),
);
