# $Author: setitesuk@gmail.com$

package message_queue::model::message;
use strict;
use warnings;
use base qw(ClearPress::model);
use Carp;
use message_queue::model::queue;
use DateTime;
our $VERSION = 1.0;

__PACKAGE__->mk_accessors(__PACKAGE__->fields());
__PACKAGE__->has_a([qw(queue )]);
__PACKAGE__->has_all();

sub fields {
  return qw(id_message
	    id_queue 
	    date
	    message
	    under_action
	    action_date
	    sender
	  );
}

sub create {
  my ($self, @args) = @_;
  if (!$self->date()) {
    $self->date($self->_date_now());
  }
  return $self->SUPER::create(@args);
}

sub update {
  my ($self, @args) = @_;
  if (!$self->action_date()) {
    return $self->_update_act_upon(@args);
  }
  return $self->_update_release(@args);
}

sub _update_act_upon {
  my ($self, @args) = @_;
  $self->action_date($self->_date_now());
  $self->under_action(1);
  return $self->SUPER::update(@args);
}

sub _update_release {
  my ($self, @args) = @_;
  $self->action_date(undef);
  $self->under_action(0);
  return $self->SUPER::update(@args);
}

sub _date_now {
  my ($self) = @_;
  my $dt = DateTime->now();
  return $dt->ymd(q{-}) . q{ } . $dt->hms(q{:});
}

sub json_message {
  my ($self) = @_;
  my $message = $self->message();
  if ($message =~ /\A[\[\{]/xms) {
    return $message;
  }
  return q{"}.$message.q{"};
}

1;
__END__
=head1 NAME

message_queue::model::message

=head1 VERSION

1.0

=head1 SYNOPSIS

  my $oMessage = message_queue::model::message->new({});

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 fields - returns an array of the fields for a row in the database table, each of which is an accessor method on the object

  my @Fields = $oMessage->fields();

=head2 create - ensures that on creation, a date is present

=head2 update - ensures that on update, an action_date is present

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item base

=item ClearPress::model

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
