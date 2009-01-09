use strict;
use warnings;

use inc::Module::Install;
use File::Find;

all_from('lib/Catalyst/View/Text/Template.pm');

requires('Catalyst::View');
requires('parent');
requires('Scalar::Util');
requires('Text::Template');

auto_manifest;

WriteAll();
