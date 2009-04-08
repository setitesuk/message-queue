
package message_queue::view::queue;
use strict;
use warnings;
use base qw(ClearPress::view);

sub read {
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
 
