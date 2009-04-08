
package message_queue::model::queue;
use strict;
use warnings;
use base qw(ClearPress::model);
use English qw{-no_match_vars};

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_many([qw(message )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_queue
	    name
	  );
}

sub init {
  my ($self) = @_;
  if (!$self->{id_queue} && $self->{name}) {
    my $q = q{SELECT id_queue FROM queue WHERE name = ?};
    my $ref   = [];

    eval {
      $ref = $self->util->dbh->selectall_arrayref($q, {}, $self->name());
    } or do {
      carp $EVAL_ERROR;
      return;
    };

    if(@{$ref}) {
      $self->{'id_queue'} = $ref->[0]->[0];
    }
  }
  return 1;
}

1;
 
