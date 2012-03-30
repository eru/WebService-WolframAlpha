package WebService::WolframAlpha;
use 5.12.4;
use utf8;
use strict;
use warnings;

use base qw(Class::Accessor::Fast);

use URI;
use LWP::UserAgent;

our $VERSION = '1.01';

__PACKAGE__->mk_accessors(qw(appid useragent xml is_success error));

sub new {
    my $self = shift->SUPER::new(@_);

    die 'no appid' if !$self->appid;

    $self->useragent(__PACKAGE__ . '::' . $VERSION) if !$self->useragent;
    $self->{ua} = LWP::UserAgent->new(agent => $self->useragent);

    return $self;
};

sub construct_uri {
    my ($self, $method, $args) = @_;

    $self->error('no input') if !$args->{input};

    my $uri = URI->new('http://api.wolframalpha.com/v2/' . $method);
    $uri->query_form($args);
    $uri->query_form($uri->query_form, appid => $self->appid);

    return $uri;
};

sub get_xml {
    my ($self, $uri) = @_;

    my %timeout = (sum => 0);
    foreach(split('&', $uri->query)) {
        if($_ =~ /^(scan|pod|format|parse)timeout=(\d+)$/o) {
            $timeout{$1} = $2;
        }
    }
    $timeout{sum} += $timeout{scan}   || 3;
    $timeout{sum} += $timeout{pod}    || 4;
    $timeout{sum} += $timeout{format} || 8;
    $timeout{sum} += $timeout{parse}  || 5;
    $self->{ua}->timeout($timeout{sum});

    my $response = $self->{ua}->get($uri->as_string);

    my $xml;
    if($response->is_success) {
        $xml = $response->content;
    } elsif($response->is_error) {
        $self->error($response->code . ' ' . $response->message);
    } else {
        $self->error('unknown request error');
    }

    return $xml;
};

sub get_response {
    my ($self, $method, $args) = @_;

    $self->error(undef);
    $self->is_success(undef);

    my $uri = construct_uri($self, $method, $args);
    my $xml = get_xml($self, $uri) if $uri;

    $self->xml($xml) if $xml;
    $self->is_success('true') if !$self->error;
};

sub validatequery {
    my $self = shift;

    &get_response($self, 'validatequery', @_);

    return $self;
};

sub query {
    my $self = shift;

    &get_response($self, 'query', @_);

    return $self;
};

1;
__END__

=head1 NAME

WebService::WolframAlpha - Interface to WolframAlpha API

=head1 SYNOPSIS

  use WebService::WolframAlpha;

  my $wa = WebService::WolframAlpha->new( {
      appid     => 'Your WolframAlpha AppID',
      useragent => 'Your UserAgent', # Default is "WebService::WolframAlpha::$VERSION"
  } );

  ## This parameters based on API Document "Query Parameters" section
  $wa->query( {
      input         => 'pi',
      format        => 'plaintext,image',
      includepodid  => ['*'],
  #   excludepodid  => '',
      podtitle      => '*',
      podindex      => '2,3,5',
      scanner       => '',
      async         => 'false',
      units         => 'metric',
      ## LWP::Useragent->timeout set sum of the timeout paramaters
      scantimeout   => 3,
      podtimeout    => 4,
      formattimeout => 8,
      parsetimeout  => 5,
  } );

  if($wa->is_success) {
      print $wa->xml;
  } else {
      print $wa->error;
  }

=head1 DESCRIPTION

This module provides a convenient interface for using the WolframAlpha API v2.

For complete information about the WolframAlpha API v2 please visit:
L<http://products.wolframalpha.com/api/documentation.html>

To use this module you must obtain an API key.

=head1 AUTHOR

eru.tndl E<lt>eru.tndl@gmail.comE<gt>

=head1 SEE ALSO

=item * Wolfram|Alpha API: Terms of Use
L<http://products.wolframalpha.com/api/termsofuse.html>

=item * Wolfram|Alpha API: Interactive API Explorer
L<http://products.wolframalpha.com/api/explorer.html>

=item * Perl extension for the WolframAlpha API v1
L<WWW::WolframAlpha>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
