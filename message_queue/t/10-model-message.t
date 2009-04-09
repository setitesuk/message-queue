use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 21;
use t::util;

use_ok('message_queue::model::message');

my $util = t::util->new({fixtures => 1});

{
  my $model = message_queue::model::message->new({
    util => $util,
  });
  isa_ok($model, 'message_queue::model::message', '$model');
}

{
  my $model = message_queue::model::message->new({
    util => $util,
    id_queue => 1,
    sender => 'someone',
    body => 'this is a message',
  });

  my $messages = $model->messages();
  isa_ok($messages, 'ARRAY', '$model->messages()');

  my $number_of_messages = scalar@{$messages};

  eval {
    $model->save();
  };
  is($EVAL_ERROR, q{}, 'no croak on save with no primary key (therefore create)');
  is($model->id_message(), $number_of_messages + 1, 'correct id_message generated')
}

{
  my $model = message_queue::model::message->new({
    util => $util,
    id_message => 1,
  });

  is($model->queue()->name(), 'test_queue_1', '$model->queue()->name() returns queue name');
  ok(!$model->under_action(), 'message is not under_action');
  ok(!$model->action_date(), 'no action date');

  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'no croak on update - act upon');
  ok($model->action_date(), 'action_date set');
  ok($model->under_action(), 'under_action set');

  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'no croak on update - release');
  ok(!$model->under_action(), 'message is not under_action');
  ok(!$model->action_date(), 'no action date');

  eval { $model->delete(); };
  is($EVAL_ERROR, q{}, 'no croak on delete');
  my $messages = $model->messages();
  is(scalar@{$messages}, 2, '2 messages in queue');
  isnt($messages->[0]->id_queue(), 1, 'message id_queue == 1 not present');
}

{
  my $model = message_queue::model::message->new({
    util => $util,
    id_queue => 2,
    sender => 'someone',
    body => q{<root><of all="evil">xml</of></root>},
    date => q{2009-01-01 00:00:15},
  });
  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'saved ok with a date and xml string as body');
  is($model->date(), q{2009-01-01 00:00:15}, 'date is inserted value');
}

{
  my $model = message_queue::model::message->new({
    util => $util,
    id_queue => 2,
    sender => 'someone',
    body => q({'some':[{'people':'might','use':'json'}]}),
    date => q{2009-01-01 00:00:15},
  });
  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'saved ok with a date and json string as body');
  is($model->date(), q{2009-01-01 00:00:15}, 'date is inserted value');
}
