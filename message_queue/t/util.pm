package t::util;
use base qw(message_queue::util);
use Carp;
use t::dbh;
use t::useragent;

$ENV{dev} = 'test';

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
  my $cmd = sprintf q(cat data/schema.txt | sqlite3 message_queue);

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


1;