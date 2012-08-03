package GenomeREST;

use strict;

#use Homology::Chado::DataSource;
use base 'Mojolicious';

# This will run once at startup
sub startup {
    my ($self) = @_;

    ##-- plugin loading sections
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
            $self->{config}->{cache}
        );
    }
    $self->plugin('GenomeREST::Plugin::Genome');
    $self->plugin('GenomeREST::Plugin::DefaultHelpers');

    ##-- routing setup
    my $router = $self->routes();
    my $base   = $router->namespace();
    $router->namespace( $base . '::Controller' );

    ## -- genomes
    my $top = $router->waypoint('/')->to('genome#index');
    my $organism
        = $top->waypoint('/:common_name')->name('genome')->to('genome#show');
    my $download = $organism->waypoint('/current')->name('current')
        ->to('genome#download');
    $organism->route('/browse')->name('gbrowse')->to('genome#browse');
    $organism->route( '/feature/length/search', format => 'datatable' )
        ->to('genome#lsearch');

    $download->route( "/$_", format => 'fasta' )->name($_)->to("genome#$_")
        for qw/dna mrna protein/;
    $download->route( '/feature', format => 'gff3' )->to('genome#feature');
    $download->route( '/mitochondria/dna', format => 'fasta' )
        ->to('mitochondria#dna');
    $download->route( '/mitochondria/feature', format => 'gff3' )
        ->to('mitochondria#feature');

    ## supercontig
    my $supercontig = $organism->waypoint('/supercontig')->name('supercontig')
        ->to('supercontig#index');
    $supercontig->route( '/search', format => 'datatable' )
        ->name('super_pager')->to('supercontig#search');
    $supercontig->route('/:id')->to( 'supercontig#show', format => 'html' );

    ## -- contig
    my $contig
        = $organism->waypoint('/contig')->name('contig')->to('contig#index');
    $contig->route( '/search', format => 'datatable' )->name('contig_pager')
        ->to('contig#search');
    $contig->route('/:id')->to( 'contig#show', format => 'html' );

    ## -- est
    my $est = $organism->waypoint('/est')->name('est')->to('est#index');
    $est->route( '/search', format => 'datatable' )->name('est_pager')
        ->to('est#search');
    $est->route('/:id')->to( 'est#show', format => 'html' );

    ### ---
    my $gene
        = $organism->waypoint('/gene')->name('all_genes')->to('gene#index');
    $gene->route( '/search', format => 'datatable' )->name('gene_pager')
        ->to('gene#search');
    my $geneid = $gene->waypoint('/:id')->name('gene')
        ->to( 'gene#show', format => 'html' );

    ## -- tabs
    my $protein_tab = $geneid->waypoint( '/protein', format => 'html' )
        ->to('protein#show_tab');
    my $feature_tab = $geneid->waypoint( '/feature', format => 'html' )
        ->to('feature#show_tab');
    my $general_tab
        = $geneid->waypoint( '/:tab', format => 'html' )->to('gene#show_tab');

    ## -- section
    ## -- currently it maps to the protein tab url for both html and json requests
    my $protein_section
        = $protein_tab->waypoint( '/:subid', format => 'html' )
        ->to('protein#show_section');
    my $feature_section
        = $feature_tab->waypoint( '/:subid', format => 'html' )
        ->to('feature#show_section');
    $general_tab->route( '/:section', format => 'json', )
        ->to('gene#show_section');

    ## protein amino acid statistics
    $protein_section->route('/statistics')->to('protein#stats');
    ## -- subsection
    $protein_section->route( '/:subsection', format => 'json', )
        ->to('protein#show_subsection');
    $feature_section->route( '/:subsection', format => 'json', )
        ->to('feature#show_subsection');
}

1;

