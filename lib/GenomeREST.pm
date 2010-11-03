package GenomeREST;

use strict;
use Moose;
use Config::Simple;
#use GenomeREST::Singleton::Cache;
use Carp;
use File::Spec::Functions;
use Homology::Chado::DataSource;
use namespace::autoclean;
extends 'Mojolicious';

#my $instance = GenomeREST::Singleton::Cache->instance;

has 'config' => (
    is         => 'rw',
    isa        => 'Config::Simple',
    lazy_build => 1
);

has 'dispatcher' => (
    is  => 'rw',
    isa => 'MojoX::Dispatcher::Static',
);

has 'model' => (
    is         => 'rw',
    isa        => 'Bio::Chado::Schema',
    lazy_build => 1
);

sub _build_config {
    my ($self) = @_;
    my $folder = $self->home->rel_dir('conf');
    if ( !-e $folder ) {
        return;
    }

    #$self->log->debug(qq/got folder $folder/);

#now the file name,  default which is developmental mode resolves to <name>.conf. For
#test and production it will be <name>.test.conf and <name>.production.conf respectively.
    my $mode   = $self->mode();
    my $suffix = '.conf';
    if ( $mode eq 'production' or $mode eq 'test' ) {
        $suffix = '.' . $mode . '.conf';
    }
    my $app_name = lc $self->home->app_class;

    my $file = catfile( $folder, $app_name . $suffix );
    $self->log->debug(qq/got config file $file/);
    return Config::Simple->new($file);
}

sub _build_model {
    my $self   = shift;
    my $opt    = $self->config->param('database.opt');
    my $schema = MyModel->connect(
        $self->config->param('database.dsn'),
        $self->config->param('database.user'),
        $self->config->param('database.pass'),
        { $opt => 1 }
    );
    my $source = $schema->source('Sequence::Feature');
    $source->add_column(
        is_deleted => {
            data_type     => 'boolean',
            default_value => 'false',
            is_nullable   => 0,
            size          => 1,
        }
    );
    my $source2 = $schema->source('Organism::Organism');
    $source2->remove_column('comment');
    $schema;
}

# This will run once at startup
sub startup {
    my ($self) = @_;

    #default log level
    $self->log->level( $ENV{MOJO_DEBUG} ? $ENV{MOJO_DEBUG} : 'debug' );

    $self->dispatcher(
        MojoX::Dispatcher::Static->new(
            prefix => '/bulkfile',
            root   => $self->config->param('download')
        )
    );

    $self->additional_dbh();

#    my $config = $self->config;
#    if ( !$instance->has_cache ) {
#        $self->log->debug("initing memcache");
#        $instance->init_cache($config);
#    }

    my $router = $self->routes();

    # reusing GenomeREST controller
    $router->namespace('GenomeREST::Controller');

    # routing setup
    # suffix based routing for multigenome setup
    # goes here before it passes to any other controller
   
    my $species_bridge = $router->bridge(':name')->to(
        controller => 'genome',
        action     => 'validate',
    );

    $species_bridge->route('')->to( controller => 'genome', action => 'index' );

    $species_bridge->route('downloads')->to(
        controller => 'download',
        action     => 'index',
    );

    # write a more generic stuff like types for genome backbone
    $species_bridge->route('contig')
        ->to( controller => 'genome', action => 'contig' );

    $species_bridge->route('contig/page/:page')
        ->to( controller => 'genome', action => 'contig_with_page' );
        
    my $gene_brige = $species_bridge->bridge('gene/:id')->to(
        controller => 'input',
        action     => 'validate'
    );
    
    # support both json and html, default is html
    $gene_brige->route('')->to(
        controller => 'page', action => 'index', format => 'html'
    );
    
    # default is html
    $gene_brige->route(':tab')->to(
        controller => 'page', action => 'tab', format => 'html'
    );
    
    $gene_brige->route(':tab/:section')->to(
        controller => 'tab', action => 'section', format => 'html'
    );
    
    # keeping the default to html as it is needed for feature tab
    # this is the only url that is being called without any extension and gives back html
    

#    # only support json response
#    $bridge2->route('/:id/:tab/:subid/:section')->to(
#        controller => 'tab',
#        action     => 'sub_section',
#        format     => 'json'
#    );
}

sub additional_dbh {
    my $self     = shift;
    my $homology = Homology::Chado::DataSource->instance;
    $homology->dsn( $self->config->param('database.dsn') );
    $homology->user( $self->config->param('database.user') );
    $homology->password( $self->config->param('database.pass') );
}

1;

package MyModel;
use base qw/Bio::Chado::Schema/;
__PACKAGE__->load_components(qw/Serialize::Storable/);

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
