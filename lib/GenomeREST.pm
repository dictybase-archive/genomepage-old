package GenomeREST;

use strict;
use base 'Mojolicious';
use Config::Simple;
use Carp;
use File::Spec::Functions;
use GenomeREST::Renderer::TT;
use GenomeREST::Renderer::Index;
use GenomeREST::Renderer::JSON;
use GenomeREST::Helper;
use Bio::Chado::Schema;
use Homology::Chado::DataSource;

__PACKAGE__->attr( 'config', default => sub { Config::Simple->new() } );
__PACKAGE__->attr('template_path');
__PACKAGE__->attr( 'has_config', default => 0 );
__PACKAGE__->attr( 'helper', default => sub { GenomeREST::Helper->new() } );
__PACKAGE__->attr('downloader');
__PACKAGE__->attr('model');

# This will run once at startup
sub startup {
    my ($self) = @_;

    #default log level
    $self->log->level('debug');

    #config file setup
    $self->set_config();

    $self->downloader(
        MojoX::Dispatcher::Static->new(
            prefix => '/bulkfile',
            root   => $self->config->param('download')
        )
    );

    $self->connect_dbh();
    $self->additional_dbh();
    my $router = $self->routes();

    #$self->log->debug("starting up");

    #reusing GenomeREST controller
    $router->namespace('GenomeREST::Controller');

    #routing setup
    #suffix based routing for multigenome setup

    #goes here before it passes to any other controller
    #kind of before action
    my $bridge = $router->bridge->to(
        controller => 'genome',
        action     => 'check_name',
    );

    $bridge->route('/:name')->to( controller => 'genome', action => 'index' );

    $bridge->route('/:name/downloads')->to(
        controller => 'download',
        action     => 'index',
    );

    #$bridge->route('/:name/downloads/fasta')->to(
    #    controller => 'download',
    #    action     => 'fasta',
    #);

    #write a more generic stuff
    #like types for genome backbone
    $bridge->route('/:name/contig')
        ->to( controller => 'genome', action => 'contig' );

    $bridge->route('/:name/contig/page/:page')
        ->to( controller => 'genome', action => 'contig_with_page' );

    my $bridge2 = $router->bridge('/:name/gene')->to(
        controller => 'input',
        action     => 'check_name'
    );

    #support both json and html
    #default is html
    $bridge2->route('/:id')
        ->to( controller => 'page', action => 'index', format => 'html' );

    #default is html
    $bridge2->route('/:id/:tab')
        ->to( controller => 'page', action => 'tab', format => 'html' );

#keeping the default to html as it is needed for feature tab
#this is the only url that is being called without any extension and gives back html
    $bridge2->route('/:id/:tab/:section')
        ->to( controller => 'tab', action => 'section', format => 'html' );

    #only support json response
    $bridge2->route('/:id/:tab/:subid/:section')->to(
        controller => 'tab',
        action     => 'sub_section',
        format     => 'json'
    );

   #organisms
   #$bridge2->route('/organism')
   #    ->to( controller => 'organism', action => 'index', format => 'json' );

    #set up various renderer
    $self->set_renderer();

    #$self->log->debug("done with startup");
}

sub process {
    my ( $self, $c ) = @_;
    my $base_url = $c->req->url->host;
    $base_url
        = $base_url
        ? $c->req->url->scheme . '://' . $base_url
        : $c->req->url->base;
    $c->stash( host => $base_url );
    $c->stash( base => $c->req->url->base );
    $self->log->debug("got base $base_url");
    $self->dispatch($c);
}

#set up config file usually look under conf folder
#supports similar profile as log file
sub set_config {
    my ( $self, $c ) = @_;
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

    #opendir my $conf, $folder or confess "cannot open folder $!:$folder";
    #my $file = catfile()
    #closedir $conf;

    my $file = catfile( $folder, $app_name . $suffix );
    $self->log->debug(qq/got config file $file/);
    $self->config->read($file);
    $self->has_config(1);

}

sub set_renderer {
    my ($self) = @_;

    #try to set the default template path for TT
    #keep in mind this setup is separate from the Mojo's default template path
    #if something not specifically is not set it defaults to Mojo's default
    $self->template_path( $self->renderer->root );
    if ( $self->has_config and $self->config->param('default.template_path') )
    {
        $self->template_path( $self->config->param('default.template_path') );
    }

    my $tpath = $self->template_path;
    $self->log->debug(qq/default template path for TT $tpath/);
    my $mode = $self->mode();
    my $tt = GenomeREST::Renderer::TT->new( path => $self->template_path, );
    my $index_tt
        = GenomeREST::Renderer::Index->new( path => $self->template_path, );

    my $json = GenomeREST::Renderer::JSON->new();

    $self->renderer->add_handler(
        tt    => $tt->build(),
        index => $index_tt->build(),
        json  => $json->build(),
    );
    $self->renderer->default_handler('tt');
}

sub connect_dbh {
    my $self   = shift;
    my $opt    = $self->config->param('database.opt');
    my $schema = Bio::Chado::Schema->connect(
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
            size          => 1
        }
    );
    $self->model($schema);

}

sub additional_dbh {
    my $self     = shift;
    my $homology = Homology::Chado::DataSource->instance;
    $homology->dsn( $self->config->param('database.dsn') );
    $homology->user( $self->config->param('database.user') );
    $homology->password( $self->config->param('database.pass') );

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
