use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};
use Test::More tests => 49;
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
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]text\/xml[\n]+//xms;

  my $parsed_response = $util->parser->parse_string($str);
  my $id_message = $parsed_response->getElementsByTagName(q{id_message})->[0]->firstChild()->toString();
  $id_message;

  $str = t::request->new({
			     PATH_INFO      => qq{/message/$id_message;update_xml},
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{<?xml version="1.0" encoding="utf-8"?>
<message sender="test_sender" completed="0" release="0">
  <id_message>5</id_message>
	<queue name="test_queue_1" />
	<body>{"action":{"to":"perform","method":"do something with json"}}</body>
</message>
},
			     },
			    });

  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]text\/xml[\n]+//xms;
  $parsed_response = $util->parser->parse_string($str);
  my $under_action = $parsed_response->getElementsByTagName(q{under_action})->[0]->firstChild()->toString();
  is($under_action, 1, q{message update_xml ok - is now under action});

  $str = t::request->new({
			     PATH_INFO      => qq{/message/$id_message;update_xml},
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{<?xml version="1.0" encoding="utf-8"?>
<message sender="test_sender" completed="0" release="1">
  <id_message>5</id_message>
	<queue name="test_queue_1" />
	<body>{"action":{"to":"perform","method":"do something with json"}}</body>
</message>},
            },
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]text\/xml[\n]+//xms;
  $parsed_response = $util->parser->parse_string($str);
  $under_action = $parsed_response->getElementsByTagName(q{under_action})->[0]->firstChild()->toString();
  is($under_action, 0, q{message update_xml ok - message released});

  $str = t::request->new({
			     PATH_INFO      => qq{/message/$id_message;update_xml},
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{<?xml version="1.0" encoding="utf-8"?>
<message sender="test_sender" completed="0" release="0">
  <id_message>5</id_message>
	<queue name="test_queue_1" />
	<body>{"action":{"to":"perform","method":"do something with json"}}</body>
</message>},
			     },
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]text\/xml[\n]+//xms;
  $parsed_response = $util->parser->parse_string($str);
  $under_action = $parsed_response->getElementsByTagName(q{under_action})->[0]->firstChild()->toString();
  is($under_action, 1, q{message update_xml ok - is now under action again});

  $str = t::request->new({
			     PATH_INFO      => qq{/message/$id_message;delete_xml},
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{<?xml version="1.0" encoding="utf-8"?>
<message sender="test_sender" completed="1" release="0">
  <id_message>5</id_message>
	<queue name="test_queue_1" />
	<body>{"action":{"to":"perform","method":"do something with json"}}</body>
</message>},
			     },
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]text\/xml[\n]+//xms;
  $parsed_response = $util->parser->parse_string($str);
  my $body = $parsed_response->getElementsByTagName(q{body})->[0]->firstChild();
  is($body, undef, q{message delete_xml ok - body is undef});

  $str = t::request->new({
			     PATH_INFO      => qq{/message/$id_message.xml},
			     REQUEST_METHOD => 'GET',
			     util           => $util,
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]text\/xml[\n]+//xms;
  $parsed_response = $util->parser->parse_string($str);
  $body = $parsed_response->getElementsByTagName(q{body})->[0]->firstChild();
  is($body, undef, q{message has been deleted - body is undef});

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
	"body":["json",{"this":"is","some":["json","which"],"should":"be"},{"stored":["as","a","string"]}]
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
      id_message => 8,
      sender => 'test_json_sender',
      body => [
        'json', {
          this => 'is',
          some => ['json','which'],
          should => 'be'
          },
        {stored => ['as','a','string']}
      ],
      date => '2009-01-01 00:00:00',
      under_action => 0,
      action_date => ''
    }
  };
  is_deeply($href, $test_hash, 'returned json from create_json when message is also json is correct');
}

{
  my $str = t::request->new({
			     PATH_INFO      => '/message/1;update_json',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{{"message":{
	"id_message":"1",
	"completed":"0",
	"release":"0",
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
  isa_ok($href, 'HASH', q{update_json ok});
  is($href->{message}->{under_action}, 1, q{ticket is under_action});
  $str = t::request->new({
			     PATH_INFO      => '/message/1;update_json',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{{"message":{
	"id_message":"1",
	"completed":"0",
	"release":"1",
	"date":"2009-01-01 00:00:00",
	"sender":"test_json_sender",
	"queue":"test_queue_2",
	"body":{"json":{"this":"is","some":["json","which"],"should":"be"},"stored":["as","a","string"]}
	}}},
			     },
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]application\/javascript\n//xms;
  $href = from_json($str);
  isa_ok($href, 'HASH', q{update_json ok});
  is($href->{message}->{under_action}, 0, q{ticket has been released});
  $str = t::request->new({
			     PATH_INFO      => '/message/1;update_json',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{{"message":{
	"id_message":"1",
	"completed":"0",
	"release":"0",
	"date":"2009-01-01 00:00:00",
	"sender":"test_json_sender",
	"queue":"test_queue_2",
	"body":{"json":{"this":"is","some":["json","which"],"should":"be"},"stored":["as","a","string"]}
	}}},
			     },
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]application\/javascript\n//xms;
  $href = from_json($str);
  isa_ok($href, 'HASH', q{update_json ok});
  is($href->{message}->{under_action}, 1, q{ticket has been taken again});
  $str = t::request->new({
			     PATH_INFO      => '/message/1;delete_json',
			     REQUEST_METHOD => 'POST',
			     util           => $util,
			     cgi_params => {
			       'POSTDATA' => q{{"message":{
	"id_message":"1",
	"completed":"1",
	"release":"0",
	"date":"2009-01-01 00:00:00",
	"sender":"test_json_sender",
	"queue":"test_queue_2",
	"body":{"json":{"this":"is","some":["json","which"],"should":"be"},"stored":["as","a","string"]}
	}}},
			     },
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]application\/javascript\n//xms;
  $href = from_json($str);
  isa_ok($href, 'HASH', q{delete_json ok});
  is($href->{message}->{body}, q{}, q{ticket has been completed and removed});
  $str = t::request->new({
			     PATH_INFO      => '/message/1.json',
			     REQUEST_METHOD => 'GET',
			     util           => $util,
			    });
  $str =~ s/\AX-Generated-By:[ ]ClearPress\n//xms;
  $str =~ s/\AContent-type:[ ]application\/javascript\n//xms;
  $href = from_json($str);
  isa_ok($href, 'HASH', q{delete_json ok});
  is($href->{message}->{body}, q{}, q{ticket is no longer in system});

}
{
  my $str = t::request->new({
			     PATH_INFO      => '/message/;add',
			     REQUEST_METHOD => 'GET',
			     util           => $util,
			     cgi_params => {},
			    });
  ok($util->test_rendered($str, q{t/data/rendered/message/add.html}), q{add render ok});

  $str = t::request->new({
    PATH_INFO => '/message/;create',
    REQUEST_METHOD => 'POST',
    util => $util,
    cgi_params => {
      id_queue => 1,
      sender => 'test_sender',
      message => 'some message to be posted',
    },
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/create.html}), q{create render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9;edit',
    REQUEST_METHOD => 'GET',
    util => $util,
    cgi_params => {},
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/edit.html}), q{edit render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9;update',
    REQUEST_METHOD => 'POST',
    util => $util,
    cgi_params => {
      id_queue => 1,
      sender => 'test_sender',
      message => 'some message to be posted',
      under_action => 1,
    },
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/update.html}), q{update render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9;edit',
    REQUEST_METHOD => 'GET',
    util => $util,
    cgi_params => {},
  });
#  warn $str;
  ok($util->test_rendered($str, q{t/data/rendered/message/edit2.html}), q{edit2 render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9;update',
    REQUEST_METHOD => 'POST',
    util => $util,
    cgi_params => {
      id_queue => 1,
      sender => 'test_sender',
      message => 'some message to be posted',
      release => 1,
      completed => 0,
    },
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/update.html}), q{update render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9;edit',
    REQUEST_METHOD => 'GET',
    util => $util,
    cgi_params => {},
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/edit.html}), q{edit render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9;update',
    REQUEST_METHOD => 'POST',
    util => $util,
    cgi_params => {
      id_queue => 1,
      sender => 'test_sender',
      message => 'some message to be posted',
      under_action => 1,
    },
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/update.html}), q{update render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9;edit',
    REQUEST_METHOD => 'GET',
    util => $util,
    cgi_params => {},
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/edit2.html}), q{edit2 render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9;update',
    REQUEST_METHOD => 'POST',
    util => $util,
    cgi_params => {
      id_queue => 1,
      sender => 'test_sender',
      message => 'some message to be posted',
      release => 0,
      completed => 1,
    },
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/update.html}), q{update render ok});

  $str = t::request->new({
    PATH_INFO => '/message/9',
    REQUEST_METHOD => 'GET',
    util => $util,
    cgi_params => {},
  });
  ok($util->test_rendered($str, q{t/data/rendered/message/read_deleted_message_id9.html}), q{read_deleted_message_id9 render ok});
}