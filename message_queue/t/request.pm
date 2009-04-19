package t::request;
use strict;
use warnings;
use IO::Scalar;
use Carp;
use CGI;
use t::util;
use message_queue::controller;

sub new {
  my ($class, $ref) = @_;

  if(!exists $ref->{PATH_INFO}) {
    croak q[Must specify PATH_INFO];
  }

  if(!exists $ref->{REQUEST_METHOD}) {
    croak q[Must specify REQUEST_METHOD];
  }

  $ENV{HTTP_HOST}       = q[test];
  $ENV{SERVER_PROTOCOL} = q[HTTP];
  $ENV{REQUEST_METHOD}  = $ref->{REQUEST_METHOD};
  $ENV{PATH_INFO}       = $ref->{PATH_INFO};
  $ENV{REQUEST_URI}     = "/cgi-bin/message_queue$ref->{PATH_INFO}";

  my $util = $ref->{util} || t::util->new({
					   fixtures => 1,
					  });
  $util->catch_email($ref);
  my $cgi = CGI->new();
  $util->cgi($cgi);

  for my $k (keys %{$ref->{cgi_params}}) {
    my $v = $ref->{cgi_params}->{$k};
    if(ref $v eq 'ARRAY') {
      $cgi->param($k, @{$v});
    } else {
      $cgi->param($k, $v);
    }
  }
  $ref->{util} = $util;

  my $str;
  my $io = tie *STDOUT, 'IO::Scalar', \$str;

  message_queue::controller->handler($util);
  return $str;
}

1;
