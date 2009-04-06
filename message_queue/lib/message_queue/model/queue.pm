
package message_queue::model::queue;
use strict;
use warnings;
use base qw(ClearPress::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_many([qw(message )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_queue
	    name
	  );
}

1;
 
