# Copyright (C) 2008-2009, Sebastian Riedel.

package DictyREST;

use strict;
use warnings;

use base 'Mojo';

use Mojo::Loader;
use Mojo::URL;
use DictyREST::Dispatcher;
use DictyREST::Renderer;
use MojoX::Dispatcher::Static;
use MojoX::Types;

__PACKAGE__->attr(
    ctx_class => (
        chained => 1,
        default => 'DictyREST::Context'
    )
);
__PACKAGE__->attr(
    mode => (
        chained => 1,
        default => sub { ( $ENV{MOJO_MODE} || 'development' ) }
    )
);
__PACKAGE__->attr(
    renderer => (
        chained => 1,
        default => sub { DictyREST::Renderer->new }
    )
);
__PACKAGE__->attr(
    routes => (
        chained => 1,
        default => sub { DictyREST::Dispatcher->new }
    )
);
__PACKAGE__->attr(
    static => (
        chained => 1,
        default => sub { MojoX::Dispatcher::Static->new }
    )
);
__PACKAGE__->attr(
    types => (
        chained => 1,
        default => sub { MojoX::Types->new }
    )
);

# The usual constructor stuff
sub new {
    my $self = shift->SUPER::new();

    # Namespace
    $self->routes->namespace( ref $self );

    # Types
    $self->renderer->types( $self->types );
    $self->static->types( $self->types );

    # Root
    $self->home->detect( ref $self );
    $self->renderer->root( $self->home->rel_dir('templates') );
    $self->static->root( $self->home->rel_dir('public') );

    # Mode
    my $mode = $self->mode;

    # Log file
    if ( $mode ne 'development' ) {
        $self->log->path( $self->home->rel_file("/var/log/$mode.log") );
    }
    else {
        $self->log->path( $self->home->rel_file("log/$mode.log") );
    }

    # Run mode
    $mode = $mode . '_mode';
    $self->$mode if $self->can($mode);

    # Startup
    $self->startup(@_);

    # Load context class
    Mojo::Loader->new->load( $self->ctx_class );

    return $self;
}

sub build_ctx {
    my $self = shift;
    return $self->ctx_class->new( app => $self, tx => shift );
}

# You could just overload this method
sub dispatch {
    my ( $self, $c ) = @_;

    #fix the path
    #missing out the first part from mod_perl handler
    $c->req->url( Mojo::URL->new( $c->req->url->base . $c->req->url->path ) );

    # Try to find a static file
    my $done = $self->static->dispatch($c);

    # Use routes if we don't have a response yet
    $done ||= $self->routes->dispatch($c);

    $self->log->info( $c->req->url );

    # Nothing found
    $self->static->serve_404($c) unless $done;
}

# Bite my shiny metal ass!
sub handler {
    my ( $self, $tx ) = @_;

    # Build context and dispatch
    $self->dispatch( $self->build_ctx($tx) );

    return $tx;
}

# This will run once at startup
sub startup {
    my ($self) = @_;
    my $router = $self->routes();
    my $base   = $router->namespace();
    $router->namespace( $base . '::Controller' );
    $router->route('/gene/:id/:tab/:section')
        ->to( controller => 'gene', action => 'section' );
    $router->route('/gene/:id/:tab')
        ->to( controller => 'gene', action => 'tab' );
    $router->route('/gene/:id')->to( controller => 'gene', action => 'tab' );

}

1;
__END__

=head1 NAME

DictyREST - Web Framework

=head1 SYNOPSIS

    use base 'DictyREST';

    sub startup {
        my $self = shift;

        my $r = $self->routes;

        $r->route('/:controller/:action')
          ->to(controller => 'foo', action => 'bar');
    }

=head1 DESCRIPTION

L<Mojolicous> is a web framework built upon L<Mojo>.

See L<Mojo::Manual::DictyREST> for user friendly documentation.

=head1 ATTRIBUTES

L<DictyREST> inherits all attributes from L<Mojo> and implements the
following new ones.

=head2 C<mode>

    my $mode = $mojo->mode;
    $mojo    = $mojo->mode('production');

Returns the current mode if called without arguments.
Returns the invocant if called with arguments.
Defaults to C<$ENV{MOJO_MODE}> or C<development>.

    my $mode = $mojo->mode;
    if ($mode =~ m/^dev/) {
        do_debug_output();
    }

=head2 C<renderer>

    my $renderer = $mojo->renderer;
    $mojo        = $mojo->renderer(DictyREST::Renderer->new);

=head2 C<routes>

    my $routes = $mojo->routes;
    $mojo      = $mojo->routes(DictyREST::Dispatcher->new);

=head2 C<static>

    my $static = $mojo->static;
    $mojo      = $mojo->static(MojoX::Dispatcher::Static->new);

=head2 C<types>

    my $types = $mojo->types;
    $mojo     = $mojo->types(MojoX::Types->new)

=head1 METHODS

L<DictyREST> inherits all methods from L<Mojo> and implements the following
new ones.

=head2 C<new>

    my $mojo = DictyREST->new;

Returns a new L<DictyREST> object.
This method will call the method C<${mode}_mode> if it exists.
(C<$mode> being the value of the attribute C<mode>).
For example in production mode, C<production_mode> will be called.

=head2 C<build_ctx>

    my $c = $mojo->build_ctx($tx);

=head2 C<dispatch>

    $mojo->dispatch($c);

=head2 C<handler>

    $tx = $mojo->handler($tx);

=head2 C<startup>

    $mojo->startup($tx);

=cut
