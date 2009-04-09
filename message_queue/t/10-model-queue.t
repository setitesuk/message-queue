use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 6;
use t::util;

use_ok('message_queue::model::queue');

my $ua    = t::useragent->new({
                is_success => 1,
            });
my $util  = t::util->new({
                useragent => $ua,
                fixtures  => 1,
            });

{
  my $model = message_queue::model::queue->new({
    util => $util,
  });
  isa_ok($model, 'message_queue::model::queue', '$model');
}
{
  my $model = message_queue::model::queue->new({
    util => $util,
    name => qw{test},
  });
  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'no croak on generation of queue');
  $model->name('spam');
  eval { $model->save(); };
  is($EVAL_ERROR, q{}, 'no croak on update to name of queue');

  my $model_by_name = message_queue::model::queue->new({
    util => $util,
    name => qw{spam},
  });
  is($model_by_name->id_queue(), $model->id_queue(), 'fetched id on creation ok');
  
  my $model_by_id = message_queue::model::queue->new({
    util => $util,
    id_queue => $model->id_queue(),
  });
  is($model_by_id->name(), $model->name(), 'created via id_queue ok');
}