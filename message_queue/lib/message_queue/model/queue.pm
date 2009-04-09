# $Author: setitesuk@gmail.com$

package message_queue::model::queue;
use strict;
use warnings;
use base qw(ClearPress::model);
use English qw{-no_match_vars};
use Carp;
use message_queue::model::message;

our $VERSION = 1.0;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_many([qw(message )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_queue
	    name
	  );
}

sub init {
  my ($self) = @_;
  if (!$self->{id_queue} && $self->{name}) {
    my $q = q{SELECT id_queue FROM queue WHERE name = ?};
    my $ref   = [];

    eval {
      $ref = $self->util->dbh->selectall_arrayref($q, {}, $self->name());
    } or do {
      carp $EVAL_ERROR;
      return;
    };

    if(@{$ref}) {
      $self->{'id_queue'} = $ref->[0]->[0];
    }
  }
  return 1;
}

1;
__END__
=head1 NAME

message_queue::model::queue

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oQueue = message_queue::model::queue->new({});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - returns an array of the fields for a row in the database table, each of which is an accessor method on the object

  my @Fields = $oQueue->fields();

=head2 init - on initialisation, if a name is given, but with no id_queue, then it will attempt to fetch this from the database

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item base

=item ClearPress::model

=item English

=item Carp

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

Andy Brown, E<lt>setitesuk@gmail.com<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009 Andy Brown (setitesuk)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
