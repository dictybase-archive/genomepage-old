# Copyright (C) 2008-2009, Sebastian Riedel.

package DictyREST::Context;

use strict;
use warnings;

use base 'MojoX::Dispatcher::Routes::Context';

# Space: It seems to go on and on forever...
# but then you get to the end and a gorilla starts throwing barrels at you.
sub render {
    my $self = shift;

    # Merge args with stash
    my $args = ref $_[0] ? $_[0] : {@_};
    local $self->{stash} = {%{$self->stash}, %$args};

    # Template
    unless ($self->stash->{template}) {

        # Default template
        my $controller = $self->stash->{controller};
        my $action     = $self->stash->{action};

        $self->stash->{template} = join '/', split(/-/, $controller), $action;
    }

    # Render
    return $self->app->renderer->render($self);
}

sub url_for {
    my $self = shift;
    my $url  = $self->match->url_for(@_);
    $url->base($self->tx->req->url->base->clone);

    # Fix paths
    unshift @{$url->path->parts}, @{$url->base->path->parts};
    $url->base->path->parts([]);

    return $url;
}

sub url_param {
	my ($self,  $param) = @_;
	if (!$param) {
		return $self->stash();
	}

	return $self->stash->{$param} if defined $self->stash->{$param};
}

1;
__END__

=head1 NAME

DictyREST::Context - Context

=head1 SYNOPSIS

    use DictyREST::Context;

    my $c = DictyREST::Context->new;

=head1 DESCRIPTION

L<Mojolicous::Context> is a context container.

=head1 ATTRIBUTES

L<DictyREST::Context> inherits all attributes from
L<MojoX::Dispatcher::Routes::Context>.

=head1 METHODS

L<DictyREST::Context> inherits all methods from
L<MojoX::Dispatcher::Routes::Context> and implements the following new ones.

=head2 C<render>

    $c->render;
    $c->render(action => 'foo');

=head2 C<url_for>

    my $url = $c->url_for;
    my $url = $c->url_for(controller => 'bar', action => 'baz');
    my $url = $c->url_for('named', controller => 'bar', action => 'baz');

=cut
