# $Author: setitesuk@gmail.com$

package message_queue::api::base;
use strict;
use warnings;
use Carp;
use English qw{-no_match_vars};

use Readonly;
use Class::Std;
use message_queue::api::util;
use JSON;

our $VERSION = 1.0;

Readonly::Scalar our $MESSAGE_QUEUE_URI => q{http://localhost:8080/};

{
  ## no critic (ProhibitUnusedVariables)
  my %util_of :ATTR( :get<util>, :set<util> );
  ## use critic

  sub name {
    return q{};
  }

  sub util {
    my ($self, $util) = @_;
    if ($util) {
      $self->set_util($util);
    }
    if ($self->get_util()) {
      return $self->get_util();
    }
    $self->set_util(message_queue::api::util->new());
    return $self->get_util();
  }

  sub _name_space {
    my ($self) = @_;
    my $ref = ref$self;
    my ($name_space) = $ref =~ /.*::(.*)\z/xms;
    return $name_space;
  }

  sub _construct_uri {
    my ($self) = @_;
    return $MESSAGE_QUEUE_URI.$self->_name_space();
  }

  sub _parse_json_response {
    my ($self, $response) = @_;
    my $json_parser = $self->util->json_parser();
    return $json_parser->decode($response->content());
  }

  sub _parse_xml_response {
    my ($self, $response) = @_;
    my $xml_parser = $self->util->xml_parser();
    return $xml_parser->parse_string($response->content());
  }

  sub list {
    my ($self) = @_;

    my $ua = $self->util->useragent();
    my $ref = ref$self;
    my $uri = $self->_construct_uri().q{.json};
    my $response = $ua->get($uri);
    if (!$response->is_success()) {
      croak $response->status_line();
    }
    my $list = [];
    eval {
      my $info = $self->_parse_json_response($response);
      foreach my $key (sort keys %{$info}) {
        foreach my $item (@{$info->{$key}}) {
          my $object = $ref->new();
          $object->util($self->util());
          $object->_populate_object($item);
          push @{$list}, $object;
        }
      }
      1;
    } or do {
      $uri = $self->_construct_uri().q{.xml};
      $response = $ua->get($uri);
      if (!$response->is_success()) {
        croak $response->status_line();
      }
      my $info = $self->_parse_xml_response($response);
      my $name_space = $self->_name_space();
      foreach my $item (@{$info->getElementsByTagName($name_space)}) {
        my $object = $ref->new();
        $object->_populate_object_from_xml($item);
        push @{$list}, $object;
      }
    };

    return $list;
  }

  sub _populate_object {
    my ($self, $hash) = @_;
    if (ref$hash ne q{HASH}) {
      croak qq{$hash is not a HASH};
    }
    my @fields = $self->fields();
    foreach my $f (@fields) {
      my $set_method = q{set_}.$f;
      $self->$set_method($hash->{$f});
    }
    return 1;
  }

  sub _populate_object_from_xml {
    my ($self, $xml) = @_;
    foreach my $f ($self->fields()) {
      my $value = $xml->getAttribute($f) || $xml->getElementsByTagName($f)->[0]->firstChild();
      if (ref$value) {
        my $temp = $value->toString();
        my $text = $temp;
        $temp =~ s/\s//gxms;
        if ($temp eq q{}) {
          $text = $xml->getElementsByTagName($f)->[0]->toString();
        }
        $value = $text;
      }
      my $set_method = q{set_}.$f;
      $self->$set_method($value);
    }
    return 1;
  }

  sub read { ## no critic (Subroutines::ProhibitBuiltinHomonyms)
    my ($self) = @_;
    my $id = $self->pk();
    if (!$id) {
      $id = $self->name();
    }
    if (!$id) {
      croak q{No primary key or name (if applicable) provided - try running list method};
    }
    my $ua = $self->util->useragent();

    my $uri = $self->_construct_uri().q{/}.$id.q{.json};
    my $response = $ua->get($uri);
    if (!$response->is_success()) {
      croak $response->status_line();
    }
    eval {
      my $info = $self->_parse_json_response($response);
      foreach my $key (sort keys %{$info}) {
        $self->_populate_object($info->{$key});
      }
      1;
    } or do {
      $uri = $self->_construct_uri().q{/}.$id.q{.xml};
      $response = $ua->get($uri);
      if (!$response->is_success()) {
       croak $response->status_line();
      }
      my $info = $self->_parse_xml_response($response)->getElementsByTagName($self->_name_space())->[0];
      $self->_populate_object_from_xml($info);
    };
    return 1;
  }

  sub pk {
    my ($self, $value) = @_;
    my $get_pk_method = q{get_id_}.$self->_name_space();
    my $set_pk_method = q{set_id_}.$self->_name_space();
    if (defined $value) {
      $self->$set_pk_method($value);
    }
    return $self->$get_pk_method();
  }

  sub create {
    my ($self) = @_;
    if ($self->pk()) {
      croak q{You have a primary key, please use $oModule->update()}; ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    }
    my $uri = $self->_construct_uri().q{/;create_xml};
    my $ua = $self->util->useragent();
    my $response = $ua->post($uri);
    if (!$response->is_success()) {
      croak $response->status_line();
    }
    my $info = $self->_parse_xml_response($response)->getElementsByTagName($self->_name_space())->[0];
    $self->_populate_object_from_xml($info);
    return 1;
  }

  sub update {
    my ($self) = @_;
    if (!$self->pk()) {
      croak q{You have no primary key, please use $oModule->create()}; ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    }
    my $uri = $self->_construct_uri().q{/;update_xml};
    my $ua = $self->util->useragent();
    my $response = $ua->post($uri);
    if (!$response->is_success()) {
      croak $response->status_line();
    }
    my $info = $self->_parse_xml_response($response)->getElementsByTagName($self->_name_space())->[0];
    $self->_populate_object_from_xml($info);
    return 1;
  }

}

1;
__END__

=head1 NAME

  message_queue::api::base

=head1 VERSION

  1.0

=head1 SYNOPSIS

  my $oDerivedClass = message_queue::api::derived_class->new();

=head1 DESCRIPTION

=head1 SUBROUTINES/METHODS

=head2 name - ensures that a name method is available, returning empty string if not in derived class

=head2 util

=head2 list

=head2 read

=head2 create

=head2 update

=head2 pk - accessor to directly access the primary key field for derived class

=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=over

=item strict

=item warnings

=item Carp

=item English -no_match_vars

=item Class::Std

=item Readonly

=item base

=back

=head1 INCOMPATIBILITIES

=head1 BUGS AND LIMITATIONS

=head1 AUTHOR

$Author$

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2009 Andy Brown (setitesuk@gmail.com)

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
