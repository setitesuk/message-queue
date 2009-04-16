use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 17;
use t::util;
use message_queue::model::message;
use JSON;
use t::request;

use_ok('message_queue::view::message');

my $util = t::util->new({fixtures => 1});

{
  my $model = message_queue::model::message->new({
    util => $util,
  });
  my $view = message_queue::view::message->new({
    util => $util,
    model => $model,
    action => q{list},
  });
  isa_ok($view, 'message_queue::view::message', '$view');
  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render');
  ok($util->test_rendered($render, q{t/data/rendered/message/list.html}), q{list render ok});
  
  $view->{aspect} = 'list_xml';
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render');
  ok($util->test_rendered($render, q{t/data/rendered/message/list.xml}), q{list_xml render ok});

  $view->{aspect} = 'list_json';
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render list_json');
  my $href = from_json($render);
  isa_ok($href, 'HASH', q{from_json($render)});
}

{
  my $model = message_queue::model::message->new({
    util => $util,
    id_message => 1,
  });
  my $view = message_queue::view::message->new({
    util => $util,
    model => $model,
    action => q{read},
  });
  my $render;
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render');
  ok($util->test_rendered($render, q{t/data/rendered/message/read.html}), q{read render ok});
  
  $view->{aspect} = 'read_xml';
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render');
  ok($util->test_rendered($render, q{t/data/rendered/message/read.xml}), q{read_xml render ok});
  
  $view->{aspect} = 'read_json';
  eval { $render = $view->render(); };
  is($EVAL_ERROR, q{}, 'no croak on render read_json');
  my $href = from_json($render);
  isa_ok($href, 'HASH', q{from_json($render)});
}
__END__
{
  my $str = t::request->new({
			     PATH_INFO      => '/queue/test_queue_2',
			     REQUEST_METHOD => 'GET',
			     util           => $util,
			    });
  ok($util->test_rendered($str, 't/data/rendered/queue/read.html'), 'read using queue name');
}
{
  my $str = t::request->new({
			     PATH_INFO      => '/queue/test_queue_2.xml',
			     REQUEST_METHOD => 'GET',
			     util           => $util,
			    });
  ok($util->test_rendered($str, 't/data/rendered/queue/read.xml'), 'read.xml using queue name');
}
{
  my $str = t::request->new({
			     PATH_INFO      => '/queue/test_queue_2.json',
			     REQUEST_METHOD => 'GET',
			     util           => $util,
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]application\/javascript\n//xms;
  my $href = from_json($str);
  isa_ok($href, 'HASH', q{from_json($render)});
}
