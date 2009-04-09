# $Author: setitesuk@gmail.com$

package message_queue::view::message;
use strict;
use warnings;
use base qw(ClearPress::view);
use DateTime;
use message_queue::model::queue;

our $VERSION = 1.0;

sub create {
  my ($self) = @_;
  my $util    = $self->util();
  my $cgi     = $util->cgi();

  my $content = $cgi->param('POSTDATA');

  if (!$content) {
    $content = $cgi->param('XForms:Model');
  }

  my $parsed_xml = $self->parse_xml($content);

  my $message = $parsed_xml->getElementsByTagName('message')->[0];
  my $body = $message->getElementsByTagName('body')->[0];
  my $queue = $parsed_xml->getElementsByTagName('queue')->[0];

  my $q_object = message_queue::model::queue->new({
    util => $util,
    name => $queue->getAttribute('name'),
  });
  $q_object->read();

  my $date = $message->getAttribute('date');

  if (!$date) {
    my $dt = DateTime->now();
    $date = $dt->ymd(q{-}) . q{ } . $dt->hms(q{:});
  }

  my $model = $self->model();
  $model->id_queue($q_object->id_queue());
	$model->date($date);
	$model->message($body->value());
	$model->under_action(0);
	$model->sender($message->getAttribute('sender'));

  $model->save();
  return 1;
}

sub read__by_queue {
  my ($self) = @_;
  my $model = $self->model();
  my $queue = $model->id_message();
  return 1;
}

sub update {
  my ($self,@args) = @_;
  my $model = $self->model();
  if ($model->under_action()) {
    return $self->delete(@args);
  }
  $model->save();
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

=head2 read__by_queue - method to provide a response which will link through to queue/<name>

=head2 update - method called on update

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
