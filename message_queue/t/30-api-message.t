use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More 'no_plan';#tests => ;
use lib qw{t};
use t::util;
use t::useragent;
use DateTime;

use_ok('message_queue::api::message');

my $ua_mock = {
  q{http://localhost:8080/message.json}   => q{t/data/rendered/message/list.json},
  q{http://localhost:8080/message.xml}    => q{t/data/rendered/message/list.xml},
  q{http://localhost:8080/message/1.json} => q{t/data/rendered/message/read_1.json},
  q{http://localhost:8080/message/3.xml}  => q{t/data/rendered/message/read.xml},
  q{http://localhost:8080/message/;create_xml}  => q{t/data/rendered/message/read.xml},
  q{http://localhost:8080/message/;update_xml}  => q{t/data/rendered/message/read.xml},
};
my $ua = t::useragent->new({is_success => 1, mock => $ua_mock});
my $util = t::util->new({ fixtures => 1 });
{

  my $message = message_queue::api::message->new();
  isa_ok($message, q{message_queue::api::message}, q{$message});
  is($message->_construct_uri(), q{http://localhost:8080/message}, q{correct uri constructed to obtain message feeds});

  my $api_util = $message->util();
  isa_ok($api_util, q{message_queue::api::util}, q{$message->util()});
  is($message->util(), $api_util, q{util cache ok});
  $api_util->useragent($ua);
  is($api_util->useragent(), $ua, q{test useragent in use});
  
  my $list;
  eval { $list = $message->messages(); };
  is($EVAL_ERROR, q{}, q{no croak obtaining list of messages});
  isa_ok($list, q{ARRAY}, q{$message->messages()});
  is(scalar@{$list}, 2, q{2 messages});
  my $message_1 = $list->[0];
  isa_ok($message_1, q{message_queue::api::message}, q{$message->messages()->[0]});
  is($message_1->get_id_message(), 1, '$message_1->get_id_message() is correct');
  is($message_1->get_id_queue(), 1, '$message_1->get_id_queue() is correct');
  is($message_1->get_queue(), 'test_queue_1', '$message_1->get_queue() is correct');
  is($message_1->get_sender(), 'greeter', '$message_1->get_sender() is correct');
  is($message_1->get_body(), 'Happy New Year', '$message_1->get_body() is correct');
  is($message_1->get_date(), '2009-01-01 00:00:15', '$message_1->get_date() is correct');
  is($message_1->get_under_action(), 0, '$message_1->get_under_action() is correct');
  is($message_1->get_action_date(), q{}, '$message_1->get_action_date() is correct');
  my $message_2 = $list->[1];
  isa_ok($message_2, q{message_queue::api::message}, q{$message->messages()->[1]});
  is($message_2->get_id_message(), 2, '$message_2->get_id_message() is correct');
  is($message_2->get_id_queue(), 2, '$message_2->get_id_queue() is correct');
  is($message_2->get_queue(), 'test_queue_2', '$message_2->get_queue() is correct');
  is($message_2->get_sender(), 'greeter', '$message_2->get_sender() is correct');
  is($message_2->get_body(), 'Happy Easter', '$message_2->get_body() is correct');
  is($message_2->get_date(), q{}, '$message_2->get_date() is correct');
  is($message_2->get_under_action(), 1, '$message_2->get_under_action() is correct');
  is($message_2->get_action_date(), '2009-04-12 12:00:15', '$message_2->get_action_date() is correct');

}
{
  my $message = message_queue::api::message->new();
  my $api_util = $message->util();
  $api_util->useragent($ua);
  $message->set_id_message(1);

  isa_ok($message->body(), 'HASH', q{$message->body()});
  is($message->queue_name(), 'test_queue_1', '$message->queue_name() is correct');
  is($message->id_message(), 1, q{$message->id_message() is correct});
  is($message->id_queue(), 1, q{$message->id_queue() is correct});
  is($message->sender(), q{test_json_sender}, q{$message->sender() is correct});
  isa_ok($message->message(), 'HASH', q{$message->message()});
  is($message->date(), q{2009-01-01 00:00:15}, q{$message->date() is correct});
  is($message->under_action(), 0, q{$message->under_action() is correct});
  is($message->action_date(), q{}, q{$message->action_date() is correct});
  my $queue = $message->queue();
  isa_ok($queue, q{message_queue::api::queue}, q{$message->queue()});
  is($message->queue(), $queue, q{cache ok});
}
{
  my $message = message_queue::api::message->new();
  my $api_util = $message->util();
  $api_util->useragent($ua);
  $message->set_id_message(3);
  is($message->body(), q{Happy New Year}, q{$message->body() is correct});
  is($message->queue_name(), 'test_queue_1', '$message->queue_name() is correct');
  is($message->id_message(), 1, q{$message->id_message() is correct});
  is($message->id_queue(), 1, q{$message->id_queue() is correct});
  is($message->sender(), q{greeter}, q{$message->sender() is correct});
  is($message->message(), q{Happy New Year}, q{$message->message() is correct});
  is($message->date(), q{2009-01-01 00:00:15}, q{$message->date() is correct});
  is($message->under_action(), 0, q{$message->under_action() is correct});
  is($message->action_date(), q{}, q{$message->action_date() is correct});
  my $queue = $message->queue();
  isa_ok($queue, q{message_queue::api::queue}, q{$message->queue()});
  is($message->queue(), $queue, q{cache ok});
}
{

  delete $ua_mock->{q{http://localhost:8080/message.json}};
  my $message = message_queue::api::message->new();
  isa_ok($message, q{message_queue::api::message}, q{$message});
  my $api_util = $message->util();
  $api_util->useragent($ua);
  
  my $list;
  eval { $list = $message->messages(); };
  is($EVAL_ERROR, q{}, q{no croak obtaining list of messages});
  isa_ok($list, q{ARRAY}, q{$message->messages()});
  is(scalar@{$list}, 2, q{2 messages});
  my $message_1 = $list->[0];
  isa_ok($message_1, q{message_queue::api::message}, q{$message->messages()->[0]});
  is($message_1->get_id_message(), 1, '$message_1->get_id_message() is correct');
  is($message_1->get_id_queue(), 1, '$message_1->get_id_queue() is correct');
  is($message_1->get_queue(), 'test_queue_1', '$message_1->get_queue() is correct');
  is($message_1->get_sender(), 'greeter', '$message_1->get_sender() is correct');
  is($message_1->get_body(), 'Happy New Year', '$message_1->get_body() is correct');
  is($message_1->get_date(), undef, '$message_1->get_date() is correct');
  is($message_1->get_under_action(), 0, '$message_1->get_under_action() is correct');
  is($message_1->get_action_date(), undef, '$message_1->get_action_date() is correct');
  my $message_2 = $list->[1];
  isa_ok($message_2, q{message_queue::api::message}, q{$message->messages()->[1]});
  is($message_2->get_id_message(), 2, '$message_2->get_id_message() is correct');
  is($message_2->get_id_queue(), 2, '$message_2->get_id_queue() is correct');
  is($message_2->get_queue(), 'test_queue_2', '$message_2->get_queue() is correct');
  is($message_2->get_sender(), 'greeter', '$message_2->get_sender() is correct');
  is($message_2->get_body(), 'Happy Easter', '$message_2->get_body() is correct');
  is($message_2->get_date(), undef, '$message_2->get_date() is correct');
  is($message_2->get_under_action(), 1, '$message_2->get_under_action() is correct');
  is($message_2->get_action_date(), '2009-04-12 12:00:15', '$message_2->get_action_date() is correct');

}
{
  my $message = message_queue::api::message->new();
  isa_ok($message, q{message_queue::api::message}, q{$message});
  my $api_util = $message->util();
  $api_util->useragent($ua);

  $message->set_body(q{<?xml version="1.0" encoding="utf-8"?>
<message date="2009-01-01 00:00:01" sender="test_sender">
	<queue name="test_queue_1" />
	<body><root><action to="perform">do something</action></root></body>
</message>});
  $message->set_queue(q{test_queue_1});
  $message->set_sender(q{test_sender});
  eval { $message->create(); };
  is($EVAL_ERROR, q{}, q{no croak creating a message});
  eval { $message->update(); };
  is($EVAL_ERROR, q{}, q{no croak updating a message});
}
{
  my $message = message_queue::api::message->new();
  isa_ok($message, q{message_queue::api::message}, q{$message});
  my $api_util = $message->util();
  $api_util->useragent($ua);

  $message->set_body(q{<?xml version="1.0" encoding="utf-8"?>
<message date="2009-01-01 00:00:01" sender="test_sender">
	<queue name="test_queue_1" />
	<body><root><action to="perform">do something</action></root></body>
</message>});

  eval { $message->update(); };
  like($EVAL_ERROR, qr{You[ ]have[ ]no[ ]primary[ ]key,[ ]please[ ]use[ ]\$oModule\-\>create\(\)}, q{croak updating a message - no prmary key});
  $message->id_message(3);
  $message->set_queue(q{test_queue_1});
  $message->sender(q{test_sender});
  eval { $message->create(); };
  like($EVAL_ERROR, qr{You[ ]have[ ]a[ ]primary[ ]key,[ ]please[ ]use[ ]\$oModule\-\>update\(\)}, q{croak creating a message - primary key});
}
{
  my $message = message_queue::api::message->new();
  isa_ok($message, q{message_queue::api::message}, q{$message});
  my $api_util = $message->util();
  $api_util->useragent($ua);

  eval { $message->create(); };
  like($EVAL_ERROR, qr{You[ ]have[ ]not[ ]written[ ]a[ ]message[ ]to[ ]be[ ]posted[ ]to}, q{croak creating a message - no message provided});
  $message->body(q{<?xml version="1.0" encoding="utf-8"?>
<message date="2009-01-01 00:00:01" sender="test_sender">
	<queue name="test_queue_1" />
	<body><root><action to="perform">do something</action></root></body>
</message>});

  eval { $message->create(); };
  like($EVAL_ERROR, qr{You[ ]have[ ]no[ ]queue[ ]for[ ]the[ ]message[ ]to[ ]be[ ]posted[ ]to}, q{croak creating a message - no queue provided});
  $message->set_queue(q{test_queue_1});
  eval { $message->create(); };
  like($EVAL_ERROR, qr{You[ ]have[ ]not[ ]added[ ]a[ ]sender[ ]for[ ]the[ ]message}, q{croak creating a message - no sender provided});
}


1;