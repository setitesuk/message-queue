use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More 'no_plan';#tests => ;
use lib qw{t};
use t::util;
use t::useragent;
use DateTime;

use_ok('message_queue::api::queue');

my $ua_mock = {
  q{http://localhost:8080/queue.json}   => q{t/data/rendered/queue/list.json},
  q{http://localhost:8080/queue.xml}    => q{t/data/rendered/queue/list.xml},
  q{http://localhost:8080/queue/1.json} => q{t/data/rendered/queue/read_1.json},
  q{http://localhost:8080/queue/1.xml}  => q{t/data/rendered/queue/read.xml},
  q{http://localhost:8080/queue/2.xml}  => q{t/data/rendered/queue/read_2.xml},
  q{http://localhost:8080/queue/;create_xml}  => q{t/data/rendered/queue/read.xml},
  q{http://localhost:8080/queue/;update_xml}  => q{t/data/rendered/queue/read.xml},
  q{http://localhost:8080/queue/test_queue_1.xml} => q{t/data/rendered/queue/test_queue_1.xml}
};
my $ua = t::useragent->new({is_success => 1, mock => $ua_mock});
my $util = t::util->new({ fixtures => 1 });
{

  my $queue = message_queue::api::queue->new();
  isa_ok($queue, q{message_queue::api::queue}, q{$queue});
  is($queue->_construct_uri(), q{http://localhost:8080/queue}, q{correct uri constructed to obtain queue feeds});

  my $api_util = $queue->util();
  isa_ok($api_util, q{message_queue::api::util}, q{$message->util()});
  is($queue->util(), $api_util, q{util cache ok});
  $api_util->useragent($ua);
  is($api_util->useragent(), $ua, q{test useragent in use});
  
  my $list;
  eval { $list = $queue->queues(); };
  is($EVAL_ERROR, q{}, q{no croak obtaining list of queue});
  isa_ok($list, q{ARRAY}, q{$queue->queues()});
  is(scalar@{$list}, 2, q{2 queues});
  my $queue_1 = $list->[0];
  isa_ok($queue_1, q{message_queue::api::queue}, q{$queue->queues()->[0]});
  is($queue_1->id_queue(), 1, '$queue_1->get_id_queue() is correct');
  is($queue_1->name(), q{test_queue_1}, '$queue_1->name() is correct');
  my $queue_2 = $list->[1];
  isa_ok($queue_2, q{message_queue::api::queue}, q{$queue->queues()->[1]});
  is($queue_2->id_queue(), 2, '$queue_2->get_id_queue() is correct');
  is($queue_2->name(), q{test_queue_2}, '$queue_2->name() is correct');

  my $messages;
  eval { $messages = $queue_1->messages(); };
  is($EVAL_ERROR, q{}, q{no croak obtaining messages});
  is($queue_1->messages(), $messages, q{cache used});
  isa_ok($messages->[0], q{message_queue::api::message}, q{$messages->[0]});
  
}
{
  my $queue = message_queue::api::queue->new();
  my $api_util = $queue->util();
  $api_util->useragent($ua);

  $queue->name(q{test_queue_1});
  my $id = $queue->id_queue();
  is($id, 1, q{id found ok from using name in object});
}
{
  my $queue = message_queue::api::queue->new();
  my $api_util = $queue->util();
  $api_util->useragent($ua);

  $queue->id_queue(2);
  my $name = $queue->name();
  is($name, q{test_queue_2}, q{name found ok from using id in object});
  my $messages = $queue->messages();
  isa_ok($messages->[0], q{message_queue::api::message}, q{$messages->[0]});
}
1;