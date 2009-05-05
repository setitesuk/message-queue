# $Author: setitesuk@gmail.com$

package message_queue::api::util;
use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};

use Readonly;
use Class::Std;
use LWP::UserAgent;

our $VERSION = 1.0;

{
  ## no critic
  my %useragent_of :ATTR( :get<useragent>, :set<useragent> );
  my %json_of :ATTR( :get<json>, :set<json> ); 
  ## use critic

  sub useragent {
    my ($self, $useragent) = @_;
    if ($useragent) {
      $self->set_useragent($useragent);
    }
    if ($self->get_useragent()) {
      return $self->get_useragent();
    }
    $self->set_useragent(LWP::UserAgent->new());
    return $self->get_useragent();
  }


  sub json_parser {
    my ($self) = @_;
    if ($self->get_json()) {
      return $self->get_json();
    }
    $self->set_json(JSON->new());
    return $self->get_json();
  }
}

1;
__END__

=head1 NAME

  message_queue::api::util

=head1 VERSION

  1.0

=head1 SYNOPSIS

  my $oUtil = message_queue::api::util->new();

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item Carp

=item English -no_match_vars

=item Class::Std

=item Readonly

=item base

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

$Author$

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009 Andy Brown (setitesuk@gmail.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
