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
  ## no critic (ProhibitUnusedVariables)
  my %id_queue_of :ATTR( :get<id_queue>, :set<id_queue> );
  my %name_of     :ATTR( :get<name>,     :set<name>     );
  my %messages_of :ATTR( :get<messages>, :set<messages> );
  ## use critic

  sub fields {
    return qw{
      id_queue
      name
      messages
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
    return $self->list();
  }

  sub messages {
    my ($self) = @_;
    my $messages_array = $self->get_messages();
    my $util = $self->util();
    my $xml_parser = $util->xml_parser();
    my $xml;

    if (!$messages_array) {
      $self->read();
      $messages_array = $self->get_messages();
    }

    if (!$messages_array) {
      $self->set_messages([]);
      return $self->get_messages();
    }

    if (ref$messages_array eq 'ARRAY' &&
        (!scalar@{$messages_array} || ref$messages_array->[0] eq 'message_queue::api::message')
       ) {
      return $messages_array;
    }

    if (!ref$messages_array) {
      $xml = $self->_test_is_xml($messages_array);
      if (!$xml) {
        $self->set_messages([]);
        return $self->get_messages();
      }
    }

    if (!$xml) {
      foreach my $m (@{$messages_array}) {
        my $obj = message_queue::api::message->new();
        $obj->util($self->util());
        $obj->_populate_object($m);
        $m = $obj;
      }
      return $messages_array;
    }

    my @messages = $xml->getElementsByTagName(q{message});
    foreach my $m (@messages) {
      my $obj = message_queue::api::message->new({ util => $self->util() });
      $obj->_populate_object_from_xml($m);
      $m = $obj;
    }
    $self->set_messages(\@messages);
    return $self->get_messages();
  }

  sub _test_is_xml {
    my ($self, $what) = @_;
    if (!$what || ref$what) {
      return 0;
    }
    my $xml;
    my $xml_parser = $self->util->xml_parser();
    eval {
      $xml = $xml_parser->parse_string($what);
    } or do {
      return 0;
    };
    return $xml;
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
