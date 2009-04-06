
package message_queue::model::message;
use strict;
use warnings;
use base qw(ClearPress::model);

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw(queue )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_message
	    id_queue 
	    date
	    message
	    under_action
	    sender
	  );
}

1;
 
