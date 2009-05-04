# $Author: setitesuk@gmail.com$

package message_queue::view::message;
use strict;
use warnings;
use base qw(ClearPress::view);
use English qw{-no_match_vars};
use Carp;
use DateTime;
use message_queue::model::queue;

our $VERSION = 1.0;

sub create_xml {
  my ($self) = @_;
  my $util    = $self->util();
  my $cgi     = $util->cgi();

  my $content = $self->_obtain_content();

  my $parsed_xml;
  eval {
    $parsed_xml = $util->parser->parse_string($content);
    1;
  } or do {
    croak 'Error parsing xml: ' . $EVAL_ERROR;
  };

  return $self->_process_xml($parsed_xml);
}

sub create_json {
  my ($self) = @_;
  my $util    = $self->util();
  my $cgi     = $util->cgi();

  my $content = $self->_obtain_content();

  my $parsed_json;
  eval {
    $parsed_json = $util->json_parser->decode($content);
    1;
  } or do {
    croak 'Error parsing json: ' . $EVAL_ERROR;
  };

  return $self->_process_json($parsed_json);
}

sub _obtain_content {
  my ($self) = @_;
  my $cgi = $self->util->cgi();
  my $content = $cgi->param('POSTDATA');

  if (!$content) {
    $content = $cgi->param('XForms:Model');
  }
  return $content;
}

sub _process_xml {
  my ($self, $parsed_xml) = @_;
  my $util = $self->util();
  my $message = $parsed_xml->getElementsByTagName('message')->[0];
  my $body = $message->getElementsByTagName('body')->[0];
  my $queue = $message->getElementsByTagName('queue')->[0];

  my $q_object = $self->_get_q_object($queue->getAttribute('name'));

  my $date = $message->getAttribute('date') || $self->_get_date();

  my $message_node = $body->firstChild();
  my $message_body = $message_node->toString();

  my $arg_refs = {
    id_queue => $q_object->id_queue(),
    date => $date,
    message => $message_body,
    sender => $message->getAttribute('sender'),
  };
	$arg_refs->{completed} = $message->getAttribute(q{completed}) || 0;
	$arg_refs->{release} = $message->getAttribute(q{release}) || 0;
  eval {
    $self->_populate_model($arg_refs);
    1;
  } or do {
    croak $EVAL_ERROR;
  };
  return 1;
}

sub _process_json {
  my ($self, $parsed_json) = @_;
  my $util = $self->util();
  my $arg_refs = {};

  $arg_refs->{id_queue} = $self->_get_q_object($parsed_json->{message}->{queue})->id_queue();
  $arg_refs->{date} = $parsed_json->{message}->{date} || $self->_get_date();
	$arg_refs->{sender} = $parsed_json->{message}->{sender};
	$arg_refs->{completed} = $parsed_json->{message}->{completed} || 0;
	$arg_refs->{release} = $parsed_json->{message}->{release} || 0;
	my $message_body = $parsed_json->{message}->{body};
	if (ref$message_body eq 'HASH' || ref$message_body eq 'ARRAY') {
	  $message_body = $self->util->json_parser->encode($message_body);
	}
  $arg_refs->{message} = $message_body;

  eval {
    $self->_populate_model($arg_refs);
    1;
  } or do {
    croak $EVAL_ERROR;
  };

  return 1;
}

sub _populate_model {
  my ($self, $arg_refs) = @_;
  my $util = $self->util();
  my $model = $self->model();

  $model->id_queue($arg_refs->{id_queue});
	$model->date($arg_refs->{date});
	$model->message($arg_refs->{message});
	if (!$model->{id_message} || $arg_refs->{release}) {
	  $model->under_action(0);
	} else {
	  $model->under_action(1);

	}
	$model->sender($arg_refs->{sender});

  if ($model->id_message()) {
    $model->update();
  } else {
    $model->create();
  }
  return 1;
}

sub _get_date {
  my ($self) = @_;
  my $dt = DateTime->now();
  return $dt->ymd(q{-}) . q{ } . $dt->hms(q{:});
}

sub _get_q_object {
  my ($self, $queue) = @_;

  my $q_object = message_queue::model::queue->new({
    util => $self->util(),
    name => $queue,
  });
  $q_object->read();

  return $q_object;
}

sub read_by_queue {
  my ($self) = @_;
  my $model = $self->model();
  my $queue = $model->id_message();
  return 1;
}

sub update_json {
  my ($self) = @_;
  my $util   = $self->util();
  my $cgi    = $util->cgi();

  my $content = $self->_obtain_content();
  my $parsed_json;
  eval {
    $parsed_json = $util->json_parser->decode($content);
    1;
  } or do {
    croak 'Error parsing json: ' . $EVAL_ERROR;
  };

  return $self->_process_json($parsed_json);
}

sub update_xml {
  my ($self) = @_;
  my $util    = $self->util();
  my $cgi     = $util->cgi();

  my $content = $self->_obtain_content();

  my $parsed_xml;
  eval {
    $parsed_xml = $util->parser->parse_string($content);
    1;
  } or do {
    croak 'Error parsing xml: ' . $EVAL_ERROR;
  };

  return $self->_process_xml($parsed_xml);
}

sub update {
  my ($self,@args) = @_;
  my $model = $self->model();
  my $cgi = $self->util->cgi();
  my $release = $cgi->param('release');
  my $completed = $cgi->param('completed');
  my $under_action = $cgi->param('under_action');
  if ($completed) {
    return $self->delete()
  } elsif ($release) {
    $model->under_action(0);
  } elsif ($under_action) {
    $model->under_action(1);
  } else {}

  $model->save();
  return 1;
}

sub delete_json {
  my ($self) = @_;
  my $util    = $self->util();
  my $cgi     = $util->cgi();

  my $content = $self->_obtain_content();

  my $parsed_json;
  eval {
    $parsed_json = $util->json_parser->decode($content);
    if (!$parsed_json->{message}->{completed}) {
      croak q{no completed flag};
    }
    $self->delete();
    1;
  } or do {
    croak 'Error parsing json: ' . $EVAL_ERROR;
  };
  return 1;
}

sub delete_xml {
  my ($self) = @_;
  my $util    = $self->util();
  my $cgi     = $util->cgi();

  my $content = $self->_obtain_content();

  my $parsed_xml;
  eval {
    $parsed_xml = $util->parser->parse_string($content);
    if (!$parsed_xml->getElementsByTagName(q{message})->[0]->getAttribute(q{completed})) {
      croak q{no completed flag}
    }
    $self->delete();
    1;
  } or do {
    croak 'Error parsing xml: ' . $EVAL_ERROR;
  };

  return 1;
}

1;
__END__
=head1 NAME

message_queue::view::message

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oMessage = message_queue::view::message->new({util => $oUtil});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 create - method called on creation of message

=head2 create_xml - method called to process an incoming create that is xml

=head2 create_json - method called to process an incoming create that is json

=head2 read_by_queue - method to provide a response which will link through to queue/<name>

=head2 update - method called on update

=head2 update_json - method to update a message via json input

=head2 delete_json - method to delete a message via json input

=head2 update_xml - method to update a message via xml input

=head2 delete_xml - method to delete a message via xml input

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item base

=item ClearPress::view

=item DateTime

=item message_queue::model::queue

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
