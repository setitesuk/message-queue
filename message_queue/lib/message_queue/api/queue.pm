# $Author: setitesuk@gmail.com$

package message_queue::api::queue;
use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};

use Readonly;
use Class::Std;
use base qw{message_queue::api::base};
use message_queue::api::message;

our $VERSION = 1.0;

{
  ## no critic
  my %id_queue_of :ATTR( :get<id_queue>, :set<id_queue> );
  my %name_of     :ATTR( :get<name>,     :set<name>     );
  ## use critic

  sub fields {
    return qw{
      id_queue
      name
    };
  }

  sub id_queue {
    my ($self, $value) = @_;
    if ($value) {
      $self->set_id_queue($value);
    }
    if (!defined $self->get_id_queue()) {
      $self->read();
    }
    return $self->get_id_queue();
  }

  sub name {
    my ($self, $value) = @_;
    if ($value) {
      $self->set_name($value);
    }
    if (!defined $self->get_name()) {
      $self->read();
    }
    return $self->get_name();
  }

  sub queues {
    my ($self) = @_;
    if ($self->get_all()) {
      return $self->get_all();
    }
    return $self->list();
  }

  sub messages {
    my ($self) = @_;
    return 1;
  }
}

1;
__END__

=head1 NAME

  message_queue::api::queue

=head1 VERSION

  1.0

=head1 SYNOPSIS

  my $oQueue = message_queue::api::queue->new();

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - returns an array of fieldnames

=head2 id_queue - accessor for primary key field

  my $iIdQueue = $oQueue->id_queue($iIdQueue);

=head2 name - accessor for the queue name

  my $sName = $oQueue->name($sName);

=head2 queues - returns arrayref of queue objects for all queues in system

  my $aQueues = $oQueue->queues();

=head2 messages - returns arrayref of all messages for this queue

  my $aMessages = $oQueue->messages()

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
