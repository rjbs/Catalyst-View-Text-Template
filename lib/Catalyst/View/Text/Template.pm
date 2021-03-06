use strict;
use warnings;
package Catalyst::View::Text::Template;
# ABSTRACT: Text::Template views for Catalyst

use parent 'Catalyst::View';

use Scalar::Util ();
use Text::Template ();

=head1 WARNING

This is a quick bodge, and may change in lots of ways.  You may want to wait
for this warning to go away.

=head1 SYNOPSIS

The following C<< __PACKAGE__->config() >> options are available:

=head2 TEMPLATE_EXTENSION

This works as per its namesake in L<Catalyst::View::TT> in that it
provides the extension for autogenerated template filenames. If there
is no C<template> variable in the stash, the action name and this parameter
are concatenated to create the default template file name.

=head2 BROKEN, BROKEN_ARG, SAFE, DELIMITERS, PREPEND, SAFE

These config variables work as per their descriptions in the
L<Text::Template> documentation. No attempt is made to sanitize
them, they are passed straight through as is.

=head2 HASH

Values in this config variable will always be included in the
templates I<HASH> allow with the Catalyst stash values. It has
lower precedence than the stash values, so duplicate names will
be overridge by the stash.

This is intended for convenience in adding in useful helper
functions or variables that you might use frequently and which
seem to been more correcly placed in the view rather than stuffed
in the stash via the Controller. Perhaps you might place a function
to escape html, a list of states or countries?

=cut

sub new {
  my ($class, $c, $arguments) = @_;
  my $config = {
    TEMPLATE_EXTENSION   => '',
    default_content_type => 'text/html; charset=utf-8',
    %{ $class->config },
    %{ $arguments },
  };

  my $self = $class->next::method($c, {%$config});

  return $self;
}

sub _find_file {
  my ($self, $c, $template) = @_;
  my $file = $c->path_to(root => $template);
}

sub process {
  my ($self, $c) = @_;
  my $template = $c->stash->{template} || $c->action
               . $self->config->{TEMPLATE_EXTENSION};

  unless (defined $template) {
    $c->log->debug('No template specified for rendering') if $c->debug;
    return 0;
  }

  my $content_type = $c->res->content_type || $self->{default_content_type};

  my $result = $self->render(
    $c,
    $template,
    {
      %{ $c->stash },
      CONTENT_TYPE => \$content_type,
    },
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

sub render {
  my ($self, $c, $template, $args) = @_;
  $args ||= { %{ $c->stash } };

  my $file = $self->_find_file($c, $template);

  # this allows us to place things in the hash as part of the View
  # for example, utility subroutines that we like to use
  my $hashextras = $self->config->{HASH} || {};

  my $hash = $self->_enref_as_needed(
    {
      CONTENT_TYPE => \do { my $x },
      (
        map {;
          $_ => ref $hashextras->{$_} ? $hashextras->{$_} : \$hashextras->{$_}
        } keys %$hashextras
      ),
      (
        map {;
          $_ => ref $args->{$_} ? $args->{$_} : \$args->{$_}
        } keys %$args
      ),
      $self->template_vars($c),
    }
  );

  # load up various arguments for Text::Template rendering
  my %targs;
  for my $k ((qw( BROKEN BROKEN_ARG SAFE DELIMITERS PREPEND SAFE ))) {
    $targs{$k} = $self->config->{$k}
      if $self->config->{$k};
  }

  my $result = Text::Template::fill_in_file(
    $file,
    %{ $self->{template_args} || {} },  # where does this come from?
    %targs,
    HASH => $hash,
  ) or die "Couldn't fill in template: $Text::Template::ERROR";

  return $result;
}

# when merging template_vars and the stash, the template_vars win
sub template_vars {
  my ($self, $c) = @_;

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

=cut

1;
