use strict;
package Catalyst::Helper::View::Text::Template;

=head1 NAME

Catalyst::Helper::View::Text::Template - Helper for Text::Template Views

=head1 SYNOPSIS

  script/create.pl view NameOfMyView Text::Template 

=head1 DESCRIPTION

Helper for Text::Template Views.

=head2 METHODS

=head3 mk_compclass

=cut

sub mk_compclass {
  my ($self, $helper) = @_;
  my $file = $helper->{file};
  $helper->render_file('compclass', $file);
}

=head1 SEE ALSO

L<Catalyst::Manual>, L<Catalyst::Test>, L<Catalyst::Request>,
L<Catalyst::Response>, L<Catalyst::Helper>, L<Catalyst::View::Text::Template>

=head1 AUTHOR

Dean Hamstead, C<dean@fragfest.com.au>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;

__DATA__

__compclass__
package [% class %];

use strict;
use warnings;

use parent 'Catalyst::View::Text::Template';

__PACKAGE__->config(TEMPLATE_EXTENSION => '.tmpl');

=head1 NAME

[% class %] - Catalyst Text::Template View for [% app %]

=head1 SYNOPSIS

See L<[% app %]>

=head1 DESCRIPTION

Catalyst Text::Template View for [% app %]

=head1 AUTHOR

[% author %]

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
