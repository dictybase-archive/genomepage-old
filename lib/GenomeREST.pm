package GenomeREST;

use strict;
use Homology::Chado::DataSource;
use base 'Mojolicious';

# This will run once at startup
sub startup {
    my ($self) = @_;

    $self->plugin('yml_config');
    $self->plugin('modware-oracle');
    $self->plugin('asset_tag_helpers');
    $self->plugin('GenomeREST::Plugin::Validate::Organism');
    $self->plugin('GenomeREST::Plugin::Validate::Gene');
    $self->plugin('GenomeREST::Plugin::DefaultHelpers');
    
    if ( defined $self->config->{cache} ) {
        ## -- add the new cache plugin
        $self->plugin(
            'cache-action',
            {   actions => [qw/index tab section sub_section/],
                options => {
                    driver     => $self->config->{cache}->{driver},
                    root_dir   => $self->config->{cache}->{root_dir},
                    namespace  => $self->config->{cache}->{namespace},
                    depth      => $self->config->{cache}->{depth},
                    expires_in => $self->config->{cache}->{expires_in}
                }
            }
        );
    }

    ## routing setup
    my $router = $self->routes();

    ## first brige: validate organism (species)
    my $species = $router->bridge('/:name')->to('controller-genome#validate');

    ## all that goes under..
    $species->route('/')->to('controller-genome#index');
    $species->route('/contig')->to('controller-genome#contig');
    $species->route('/contig/page/:page')
        ->to('controller-genome#contig_with_page');
    $species->route('/downloads')->to('controller-genome#download');

    ## second brige for gene id/name validation
    my $gene = $species->bridge('/gene/:id')->to('controller-gene#validate');

    $gene->route('/')->name('gene')->to( 'controller-gene#index', format => 'html' );
    $gene->route('/:tab')->to('controller-gene#tab');
    $gene->route('/:tab/:section')->to('controller-gene#section');
    $gene->route('/:tab/:subid/:section')->to('controller-gene#section');

    ## init database connection
    my $datasource = Homology::Chado::DataSource->instance;
    $datasource->dsn( $self->config->{database}->{dsn} )
        if !$datasource->has_dsn;
    $datasource->user( $self->config->{database}->{user} )
        if !$datasource->has_user;
    $datasource->password( $self->config->{database}->{password} )
        if !$datasource->has_password;

}

1;

__END__

=head1 NAME

GenomeREST - Web Framework

=head1 SYNOPSIS

    use base 'GenomeREST';
    sub startup {
        my $self = shift;

        my $r = $self->routes;

        $r->route('/:controller/:action')
          ->to(controller => 'foo', action => 'bar');
    }

=head1 DESCRIPTION

L<Mojolicous> is a web framework built upon L<Mojo>.

See L<Mojo::Manual::GenomeREST> for user friendly documentation.

=head1 ATTRIBUTES

L<GenomeREST> inherits all attributes from L<Mojo> and implements the
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
    $mojo        = $mojo->renderer(GenomeREST::Renderer->new);

=head2 C<routes>

    my $routes = $mojo->routes;
    $mojo      = $mojo->routes(GenomeREST::Dispatcher->new);

=head2 C<static>

    my $static = $mojo->static;
    $mojo      = $mojo->static(MojoX::Dispatcher::Static->new);

=head2 C<types>

    my $types = $mojo->types;
    $mojo     = $mojo->types(MojoX::Types->new)

=head1 METHODS

L<GenomeREST> inherits all methods from L<Mojo> and implements the following
new ones.

=head2 C<new>

    my $mojo = GenomeREST->new;

Returns a new L<GenomeREST> object.
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
