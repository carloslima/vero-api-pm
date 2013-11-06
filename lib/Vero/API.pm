package Vero::API;
use 5.010;
use strict;
use warnings;
use Carp;
use Moo;
use namespace::autoclean;

use Mojo::UserAgent;
use Mojo::JSON 'j';

has ua => (
    is      => 'rw',
    default => sub { Mojo::UserAgent->new },
);

has token => (
    is      => 'rw',
    builder => 1,
);

sub _build_token {
    croak 'A token is required during initialization. Pass one on constructor or override "_build_token" to return one';
}

sub identify_user {
    my ($self, %info) = @_;
    my $id    = delete $info{id};
    my $email = delete $info{email};

    croak 'id or email is required' unless defined $id or defined $email;

    my $a = $self->ua->post(
        'https://api.getvero.com/api/v2/users/track.json',
        json => {
            auth_token => $self->token,
            ($id    ? (id    => $id)    : ()),
            ($email ? (email => $email) : ()),
            data => {%info},
        });
    unless ($a->success) {
        my ($err, $code) = $a->error;
        carp "Vero API returned error: code $code, error $err, data " . j($a->res->json);
        return;
    }
    return 1;
}

sub track_event {
    my ($self, $event_name, %info) = @_;
    my $id    = delete $info{id};
    my $email = delete $info{email};

    croak 'id or email is required' unless defined $id or defined $email;

    my $a = $self->ua->post(
        'https://api.getvero.com/api/v2/events/track.json',
        json => {
            auth_token => $self->token,
            'identity' => {
                ($id    ? (id    => $id)    : ()),
                ($email ? (email => $email) : ()),
            },
            event_name => $event_name,
            data       => {%info},
        });
    unless ($a->success) {
        my ($err, $code) = $a->error;
        carp "Vero API returned error: code $code, error $err, data " . j($a->res->json);
        return;
    }
    return 1;
}

1;
