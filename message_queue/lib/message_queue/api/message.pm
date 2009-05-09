# $Author: setitesuk@gmail.com$

package message_queue::api::message;
use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};

use Readonly;
use Class::Std;
use base qw{message_queue::api::base};
use message_queue::api::queue;

our $VERSION = 1.0;

{
  ## no critic
  my %id_message_of :ATTR( :get<id_message>, :set<id_message> );
  my %id_queue_of :ATTR( :get<id_queue>, :set<id_queue> );
  my %queue_of :ATTR( :get<queue>, :set<queue> );
  my %queue_obj_of :ATTR( :get<queue_object>, :set<queue_object> );
  my %sender_of :ATTR( :get<sender>, :set<sender> );
  my %body_of :ATTR( :get<body>, :set<body> );
  my %date_of :ATTR( :get<date>, :set<date> );
  my %under_action_of :ATTR( :get<under_action>, :set<under_action> );
  my %action_date_of :ATTR( :get<action_date>, :set<action_date> );
  ## use critic

  sub fields {
    return qw{
      id_message
      id_queue
      queue
      sender
      body
      date
      under_action
      action_date
    };
  }

  sub id_message {
    my ($self, $value) = @_;
    if ($value) {
      $self->set_id_message($value);
    }
    return $self->get_id_message();
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

  sub queue_name {
    my ($self) = @_;
    if (!defined $self->get_queue()) {
      $self->read();
    }
    return $self->get_queue();
  }

  sub sender {
    my ($self, $value) = @_;
    if ($value) {
      $self->set_sender($value);
    }
    if (!defined $self->get_sender()) {
      $self->read();
    }
    return $self->get_sender();
  }

  sub body {
    my ($self, $value) = @_;
    if ($value) {
      $self->set_body($value);
    }
    if (!defined $self->get_body()) {
      $self->read();
    }
    return $self->get_body();
  }

  sub date {
    my ($self, $value) = @_;
    if ($value) {
      $self->set_date($value);
    }
    if (!defined $self->get_date()) {
      $self->read();
    }
    return $self->get_date();
  }

  sub under_action {
    my ($self, $value) = @_;
    if ($value) {
      $self->set_under_action($value);
    }
    if (!defined $self->get_under_action()) {
      $self->read();
    }
    return $self->get_under_action();
  }

  sub action_date {
    my ($self, $value) = @_;
    if ($value) {
      $self->set_action_date($value);
    }
    if (!defined $self->get_action_date()) {
      $self->read();
    }
    return $self->get_action_date();
  }

  sub message {
    my ($self, $message) = @_;
    if ($message) {
      $self->body($message);
    }
    return $self->body();
  }

  sub queue {
    my ($self) = @_;
    if ($self->get_queue_object()) {
      return $self->get_queue_object();
    }
    my $q_obj = message_queue::api::queue->new();
    $q_obj->set_id_queue($self->id_queue());
    $q_obj->set_name($self->queue_name());
    $q_obj->util($self->util());
    $self->set_queue_object($q_obj);
    return $q_obj;
  }

  sub messages {
    my ($self) = @_;
    return $self->list();
  }

  sub create {
    my ($self) = @_;
    if (!$self->get_body()) {
      croak q{You have not written a message to be posted to};
    }
    if (!$self->get_queue()) {
      croak q{You have no queue for the message to be posted to};
    }

    if (!$self->get_sender()) {
      croak q{You have not added a sender for the message};
    }

    return $self->SUPER::create();
  }
}

1;
__END__

=head1 NAME

  message_queue::api::message

=head1 VERSION

  1.0

=head1 SYNOPSIS

  my $oMessage = message_queue::api::message->new();

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - returns an array of fieldnames

=head2 id_message - accessor for message id

  my $iIdMessage = $oMessage->id_message($iIdMessage);

=head2 id_queue - accessor for queue id

  my $iIdQueue = $oMessage->id_queue($iIdQueue);

=head2 queue_name - retrieve the queue name

  my $sQueueName = $oMessage->queue_name();

=head2 sender - accessor for the senders name

  my $sSender = $oMessage->sender($sSender);

=head2 body - accessor for the message body (can be a string, arrayref or hashref)

  my $Body = $oMessage->body($Body);

=head2 message - psuedonym for body

  my $Message = $oMessage->message($Message);

=head2 date - retrieve the date the message was logged

  my $sDate = $oMessage->date();

=head2 under_action - retrieve if the message is currently being acted upon

  my $boolUnderAction = $oMessage->under_action();

=head2 action_date - retrieve the date the message is logged as being acted upon

  my $sActionDate = $oMessage->action_date();

=head2 messages - returns arrayref of all messages in system

  my $aMessages = $oMessage->messages();

=head2 queue - returns a queue object for the queue which this message is in

  my $oQueue = $oMessage->queue();

=head2 create

=head2 update

=head2 read forces a read on the message, assuming you have the id_message

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
