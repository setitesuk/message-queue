
package message_queue::view::message;
use strict;
use warnings;
use base qw(ClearPress::view);
use DateTime;
use message_queue::model::queue;

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
    $date = $dt->asString();
  }

  my $model = $self->model();
  $model->id_queue($q_object->id_queue()); 
	$model->date($date);
	$model->action_date($date);
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
  my $dt = DateTime->now();
  my $date = $dt->asString();
  $model->under_action(1);
  $model->action_date($date);
  $model->save();
  return 1;
}

1;
 
