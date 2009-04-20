# $Author: setitesuk@gmail.com$

package message_queue::controller;
use strict;
use warnings;
use base qw{ClearPress::controller};

use message_queue::decorator;
use message_queue::model::queue;
use message_queue::model::message;
use message_queue::view::error;
use message_queue::view::queue;
use message_queue::view::message;


our $VERSION = 1.0;

sub decorator {
  my ($self, $util) = @_;

  if(!$self->{decorator}) {
    my $appname        = $util->config->val('application', 'name') || 'Application';
    $self->{decorator} = message_queue::decorator->new({
						     title      => $appname,
						     stylesheet => [$util->config->val('application','stylesheet')],
						     cgi => $util->cgi(),
						    });
  }

  return $self->{decorator};
}

1;
__END__
=head1 NAME

message_queue::controller

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oController = message_queue::controller->new({});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 decorator - obtains a decorator object

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item base

=item ClearPress::controller

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Andy Brown, E<lt>setitesuk@gmail.com<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009 Andy Brown (setitesuk)

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

=cut
