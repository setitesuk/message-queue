# $Author: setitesuk@gmail.com$

package message_queue::view::queue;
use strict;
use warnings;
use base qw(ClearPress::view);

our $VERSION = 1.0;

sub read { ## no critic (ProhibitBuiltinHomonyms)
  my ($self) = @_;
  my $model = $self->model();
  if ($model->id_queue() =~ /\A\d+\z/xms) {
    return 1;
  }
  $model->name($model->id_queue());
  $model->id_queue(undef);
  $model->init();
  return 1;
}

1;
__END__
=head1 NAME

message_queue::view::queue

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oQueue = message_queue::view::queue->new({util => $oUtil});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 read - override default Clearpress::read to allow access by queue name as well as id_queue

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item base

=item ClearPress::view

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
