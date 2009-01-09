use strict;
use warnings;
package Catalyst::View::Text::Template;
use parent 'Catalyst::View';

our $VERSION = '0.000';

use Scalar::Util ();
use Text::Template ();

=head1 NAME

Catalyst::View::Text::Template - Text::Template views for Catalyst

=head1 WARNING

This is a quick bodge, and may change in lots of ways.  You may want to wait
for this warning to go away.

=cut

sub new {
  my ($class, $c, $arguments) = @_;
  my $config = {
    default_content_type => 'text/html; charset=utf-8',
    %{ $class->config },
    %{ $arguments },
  };

  my $self = $class->NEXT::new(
    $c,
    { %$config }, 
  );

  return $self;
}

sub _find_file {
  my ($self, $c, $template) = @_;
  my $file = $c->path_to(root => $template);
}

sub process {
  my ($self, $c) = @_;
  my $template = $c->stash->{template} || $c->action;
  $c->log->warn(sprintf ">> $template (action=%s)", $c->action);

  my $content_type = $c->res->content_type || $self->{default_content_type};

  my $result = $self->render(
    $c,
    $template,
    {
      %{ $c->stash },
      CONTENT_TYPE => \$content_type
    }
  );

  $c->res->content_type($content_type);
  $c->res->body($result);
}

sub _enref_as_needed {
  my ($self, $hash) = @_;

  my %return;
  while (my ($k, $v) = each %$hash) {
    $return{ $k } = (ref $v and not Scalar::Util::blessed $v) ? $v : \$v;
  }

  return \%return;
}

sub render  {
  my ($self, $c, $template, $args)= @_;
  $args ||= { %{ $c->stash } };

  my $file = $self->_find_file($c, $template);

  my $hash = $self->_enref_as_needed({
    CONTENT_TYPE => \do { my $x },
    (map {; $_ => ref $args->{$_} ? $args->{$_} : \$args->{$_} } keys %$args),
    $self->template_vars($c),
  });

  my $result = Text::Template::fill_in_file(
    $file,
    %{ $self->{template_args} || {} },
    HASH => $hash,
  );

  return $result;
}

# when merging template_vars and the stash, the template_vars win
sub template_vars {
  my ( $self, $c ) = @_;

  my $cvar = $self->config->{CATALYST_VAR};
     $cvar = 'c' unless defined $cvar;

  return (
    $cvar => \$c,
    base  => \$c->req->base,
    name  => \$c->config->{name}
  );
}

=head1 SEE ALSO

L<Text::Template>

=head1 AUTHOR

Ricardo SIGNES, C<< <rjbs at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Catalyst-View-Text-Template>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2009 Ricardo SIGNES.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
