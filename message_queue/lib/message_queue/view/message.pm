
package message_queue::view::message;
use strict;
use warnings;
use base qw(ClearPress::view);
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
  my $queue = $parsed_xml->getElementsByTagName('queue')->[0];

  my $q_object = message_queue::model::queue->new({
    util => $util,
    name => $queue->getAttribute('name'),
  });
  $q_object->read();

  my $model = $self->model();
  $model->id_queue($q_object->id_queue()); 
	$model->date($message->getAttribute('date'));
	$model->message($message->getAttribute('body'));
	$model->under_action(0);
	$model->sender($message->getAttribute('sender'));

  $model->save();
  return 1;
}

sub read__by_queue {
  my ($self) = @_;
  my $model = $self->model();
  my $queue = $model->id_message();
  $model->id_message(undef);
  my $q_object = message_queue::model::queue->new({
    util => $self->util(),
    name => $queue->getAttribute('name'),
  });
  $q_object->read();
  $model->id_queue($q_object->id_queue());
  return $self->list();
}



1;
 
