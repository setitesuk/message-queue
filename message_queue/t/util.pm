package t::util;
use base qw(message_queue::util);
use Carp;
use t::dbh;
use t::useragent;
use Test::More;
use YAML qw(LoadFile);
use HTML::PullParser;

$ENV{dev} = 'test';

$ENV{HTTP_HOST}     = 'test.message_queue.com';
$ENV{DOCUMENT_ROOT} = './htdocs';
$ENV{SCRIPT_NAME}   = '/cgi-bin/message_queue';
$ENV{dev}           = 'test';

sub dbh {
  my ($self, @args) = @_;

  if($self->{fixtures}) {
    return $self->SUPER::dbh(@args);
  }

  $self->{'dbh'} ||= t::dbh->new({'mock'=>$self->{'mock'}});
  return $self->{'dbh'};
}

sub driver {
  my $self = shift;

  if($self->{fixtures}) {
    return $self->SUPER::driver();
  }

  return $self;
}

sub create {
  my ($self, @args) = @_;

  if($self->{fixtures}) {
    return $self->driver->create(@args);
  }

  return $self->dbh->do(@args);
}

sub new {
  my ($class, @args) = @_;
  my $self = $class->SUPER::new(@args);

  if($self->{fixtures}) {
    $self->load_fixtures();
  }

  return $self;
}

sub load_fixtures {
  my $self = shift;

  if($self->dbsection() ne 'test') {
    croak "dbsection is set to @{[$self->dbsection()]} which is not the same as 'test'. Refusing to go ahead!";
  }

  #########
  # build table definitions
  #
  if(!-e "data/schema.txt") {
    croak "Could not find data/schema.txt";
  }

  $self->log('Loading data/schema.txt');
  my $cmd = sprintf q(cat data/schema.txt | sqlite3 message_queue_test);

  $self->log("Executing: $cmd");
  open my $fh, q(-|), $cmd or croak $ERRNO;
  while(<$fh>) {
    print;
  }
  close $fh or croak $ERRNO;

  #########
  # populate test data
  #
  opendir my $dh, q(t/data/fixtures) or croak "Could not open t/data/fixtures";
  my @fixtures = sort grep { /\d+\-[a-z\d_]+\.yml$/mix } readdir $dh;
  closedir $dh;

  $self->log('Loading fixtures: '. join q[ ], @fixtures);

  my $dbh = $self->dbh();
  for my $fx (@fixtures) {
    my $yml     = LoadFile("t/data/fixtures/$fx");
    my ($table) = $fx =~ /\-([a-z\d_]+)/mix;
#    $self->log("+- Loading $fx into $table");
    my $row1    = $yml->[0];
    my @fields  = keys %{$row1};
    my $query   = qq(INSERT INTO $table (@{[join q(, ), @fields]}) VALUES (@{[join q(,), map { q(?) } @fields]}));

    for my $row (@{$yml}) {
      $dbh->do($query, {}, map { $row->{$_} } @fields);
    }
    $dbh->commit();
  }

  return;
}

sub rendered {
  my ($self, $tt_name) = @_;
  local $RS = undef;
  open my $fh, q(<), $tt_name or croak "Error opening $tt_name: $ERRNO";
  my $content = <$fh>;
  close $fh or croak "Error closing $tt_name: $ERRNO";
  return $content;
}

sub test_rendered {
  my ($self, $chunk1, $chunk2) = @_;
  my $fn = $chunk2 || q[];

  if(!$chunk1) {
    diag q(No chunk1 in test_rendered);
  }

  if(!$chunk2) {
    diag q(No chunk2 in test_rendered);
  }

  if($chunk2 =~ m{^t/}mx) {
    $chunk2 = $self->rendered($chunk2);

    if(!length $chunk2) {
      diag("Zero-sized $chunk2. Expected something like\n$chunk1");
    }
  }

  my $chunk1els = $self->parse_html_to_get_expected($chunk1);
  my $chunk2els = $self->parse_html_to_get_expected($chunk2);
  my $pass      = $self->match_tags($chunk2els, $chunk1els);

  if($pass) {
    return 1;

  } else {
    if($fn =~ m{^t/}mx) {
      ($fn) = $fn =~ m{([^/]+)$}mx;
    }
    if(!$fn) {
      $fn = q[blob];
    }

    my $rx = "/tmp/${fn}-chunk-received";
    my $ex = "/tmp/${fn}-chunk-expected";
    open my $fh1, q(>), $rx or croak "Error opening $ex";
    open my $fh2, q(>), $ex or croak "Error opening $rx";
    print $fh1 $chunk1;
    print $fh2 $chunk2;
    close $fh1 or croak "Error closing $ex";
    close $fh2 or croak "Error closing $rx";
    diag("diff $ex $rx");
  }

  return;
}

sub parse_html_to_get_expected {
  my ($self, $html) = @_;
  my $p;
  my $array = [];

  if ($html =~ m{^t/}xms) {
    $p = HTML::PullParser->new(
			       file  => $html,
			       start => '"S", tagname, @attr',
			       end   => '"E", tagname',
			      );
  } else {
    $p = HTML::PullParser->new(
			       doc   => $html,
			       start => '"S", tagname, @attr',
			       end   => '"E", tagname',
			      );
  }

  my $count = 1;
  while (my $token = $p->get_token()) {
    my $tag = q{};
    for (@{$token}) {
      $_ =~ s/\d{4}-\d{2}-\d{2}/date/xms;
      $_ =~ s/\d{2}:\d{2}:\d{2}/time/xms;
      $tag .= " $_";
    }
    push @{$array}, [$count, $tag];
    $count++;
  }

  return $array;
}

sub match_tags {
  my ($self, $expected, $rendered) = @_;
  my $fail = 0;
  my $a;

  for my $tag (@{$expected}) {
    my @temp = @{$rendered};
    my $match = 0;
    for ($a= 0; $a < @temp;) {
      my $rendered_tag = shift @{$rendered};
      if ($tag->[1] eq $rendered_tag->[1]) {
        $match++;
        $a = scalar @temp;
      } else {
        $a++;
      }
    }

    if (!$match) {
      diag("Failed to match '$tag->[1]'");
      return 0;
    }
  }

  return 1;
}

1;