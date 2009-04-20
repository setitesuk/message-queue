use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 19;
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

{
  my $str = t::request->new({
			     PATH_INFO      => '/message/;create_xml',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'XForms:Model' => q{<?xml version="1.0" encoding="utf-8"?>
<message date="2009-01-01 00:00:01" sender="test_sender">
	<queue name="test_queue_1" />
	<body>some text</body>
</message>
			       },
			     },
			    });
  ok($util->test_rendered($str, q{t/data/rendered/message/create_xforms_model.xml}), q{create_xml xforms:model plain text message saved ok});
}
{
  my $str = t::request->new({
			     PATH_INFO      => '/message/;create_xml',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{<?xml version="1.0" encoding="utf-8"?>
<message date="2009-01-01 00:00:01" sender="test_sender">
	<queue name="test_queue_1" />
	<body><root><action to="perform">do something</action></root></body>
</message>
			       },
			     },
			    });

  ok($util->test_rendered($str, q{t/data/rendered/message/create_postdata_with_xml_as_message_body.xml}), q{create_xml postdata xml message saved ok});
}
{
  my $str = t::request->new({
			     PATH_INFO      => '/message/;create_xml',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{<?xml version="1.0" encoding="utf-8"?>
<message sender="test_sender">
	<queue name="test_queue_1" />
	<body>{"action":{"to":"perform","method":"do something with json"}}</body>
</message>
			       },
			     },
			    });

  ok($util->test_rendered($str, q{t/data/rendered/message/create_postdata_with_json_as_message_body.xml}), q{create_xml postdata json message saved ok});
}
{
  my $str = t::request->new({
			     PATH_INFO      => '/message/;create_json',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{{"message":{
	"date":"2009-01-01 00:00:00",
	"sender":"test_json_sender",
	"queue":"test_queue_2",
	"body":"string message"}}},
			     },
			    });

  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]application\/javascript\n//xms;
  my $href = from_json($str);
  isa_ok($href, 'HASH', q{create_json with message just a string ok});
  my $test_hash = {
    message => {
      id_queue  => 2,
      queue =>"test_queue_2",
      id_message => 6,
      sender => 'test_json_sender',
      body => 'string message',
      date => '2009-01-01 00:00:00',
      under_action => 0,
      action_date => ''
    }
  };
  is_deeply($href, $test_hash, 'returned json from create is correct');
}
{
  my $str = t::request->new({
			     PATH_INFO      => '/message/;create_json',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{{"message":{
	"date":"2009-01-01 00:00:00",
	"sender":"test_json_sender",
	"queue":"test_queue_2",
	"body":{"json":{"this":"is","some":["json","which"],"should":"be"},"stored":["as","a","string"]}
	}}},
			     },
			    });

  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]application\/javascript\n//xms;
  my $href = from_json($str);
  isa_ok($href, 'HASH', q{create_json with message as more json ok});
  my $test_hash = {
    message => {
      id_queue  => 2,
      queue =>"test_queue_2",
      id_message => 7,
      sender => 'test_json_sender',
      body => {
        json => {
          this => 'is',
          some => ['json','which'],
          should => 'be'
          },
        stored => ['as','a','string']
      },
      date => '2009-01-01 00:00:00',
      under_action => 0,
      action_date => ''
    }
  };
  is_deeply($href, $test_hash, 'returned json from create_json when message is also json is correct');
}
