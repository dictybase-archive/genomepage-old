package GenomeREST;

use strict;
use Homology::Chado::DataSource;
use base 'Mojolicious';

# This will run once at startup
sub startup {
    my ($self) = @_;

    ## -- plugin loading sections
    $self->plugin('yml_config');
    $self->plugin(
        'modware-oracle',
        {   dsn      => $self->config->{database}->{dsn},
            user     => $self->config->{database}->{user},
            password => $self->config->{database}->{password},
            attr     => { LongReadLen => 2**25 },
        }
    );
    $self->plugin('asset_tag_helpers');
    if ( defined $self->config->{cache} ) {
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
    $self->plugin('GenomeREST::Plugin::Genome');

    ## routing setup
    my $router = $self->routes();
    my $base   = $router->namespace();
    $router->namespace( $base . '::Controller' );

    # -- routing
    my $top      = $router->waypoint('/')->to('genome#index');
    my $organism = $top->waypoint('/:common_name')->name('genome')
        ->to('genome#species_index');

    ## all that goes under..
    $organism->route('/supercontig')->name('supercontig')
        ->to('genome#supercontig');
    $organism->route( '/supercontig/search', format => 'datatable' )
        ->name('super_pager')->to('genome#supercontig_search');

    $organism->route('/contig')->to('genome#contig');
    $organism->route( '/contig/search', format => 'datatable' )
        ->name('contig_pager')->to('genome#contig_search');

    $organism->route('/downloads')->to('genome#download');

    ### ---
    my $gene
        = $organism->waypoint('/gene')->name('all_genes')->to('gene#list');
    $gene->route( '/search', format => 'datatable' )->name('gene_pager')
        ->to('gene#search');
    my $geneid = $gene->waypoint('/:id')->name('gene')->to('gene#show');

    ## -- tabs
    my $general_tab = $geneid->waypoint( '/:tab',
        tab => [qw/gene orthologs blast references/] )->to('gene#show_tab');
    my $protein_tab = $geneid->waypoint('/protein')->to('protein#show_tab');
    my $feat_tab    = $geneid->waypoint('/feature')->to('feature#show_tab');

    ## -- section
    $general_tab->route(
        '/:section',
        format  => 'json',
        section => [qw/info genomic_info product sequences links/]
    )->to('gene#show_section');
    my $protein_section = $protein_tab->waypoint(
        '/:id',
        id     => qr/^[A-Z]{3}_\d{4, 12}$/,
        format => 'json'
    )->to('protein#show_section');
    my $feature_section
        = $feature_tab->waypoint( '/:id', id => qr/^[A-Z]{3}_\d{4, 12}$/ )
        ->to('feature#show_section');

    ## -- subsection
    $protein_section->route(
        '/:subsection',
        format     => 'json',
        subsection => [qw/info sequence/]
    )->to('protein#show_subsection');
    $feature_section->route(
        '/:subsection',
        format     => 'json',
        subsection => [qw/info references/]
    )->to('feature#show_subsection');
}

# init database connection
#    my $datasource = Homology::Chado::DataSource->instance;
#    $datasource->dsn( $self->config->{database}->{dsn} )
#        if !$datasource->has_dsn;
#    $datasource->user( $self->config->{database}->{user} )
#        if !$datasource->has_user;
#    $datasource->password( $self->config->{database}->{password} )
#        if !$datasource->has_password;

1;

