use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
	NAME          => 'Catalyst-View-Text-Template',
  ABSTRACT      => 'Text::Template views for Catalyst',
	AUTHOR        => 'Ricardo SIGNES <rjbs@cpan.org>',
	VERSION_FROM  => 'lib/Catalyst/View/Text/Template.pm',
  (eval { ExtUtils::MakeMaker->VERSION(6.21) } ? (LICENSE => 'perl') : ()),
	PREREQ_PM => {
    'Catalyst::Runtime' => '5.8000',
    'parent' => 0,
    'Scalar::Util' => 0,
    'Text::Template' => 0,
	},
);

