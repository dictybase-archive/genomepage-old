package GenomeREST::Controller::Gene;

use strict;
use Genome::Tabview::Page::Gene;
use Genome::Factory::Tabview::Tab;
use Genome::Factory::Tabview::Section;
use Carp::Always;
use base 'GenomeREST::Controller';

sub index {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);
}

sub search {
    my ($self) = @_;

    $self->set_organism( $self->stash('common_name') );

    my $rows = $self->param('iDisplayLength');
    my $page = $self->param('iDisplayStart') / $rows + 1;

    my $gene_rs = $self->stash('organism_resultset')->search_related(
        'features',
        { 'type.name' => 'gene' },
        {   join     => 'type',
            prefetch => [qw/dbxref featureloc_features/],
            rows     => $rows,
            page     => $page
        }
    );
    my $data = [];
    while ( my $row = $gene_rs->next ) {
        my $seqlen = $row->seqlen;
        if ( !$seqlen ) {
            my $floc = $row->featureloc_features->first;
            $seqlen = sprintf( "%.1f", ( $floc->fmax - $floc->fmin ) / 1000 );
        }
        push @$data, [ $row->dbxref->accession, $seqlen ];
    }
    my $total = $gene_rs->pager->total_entries;
    $self->render_json(
        {   sEcho                => $self->param('sEcho'),
            iTotalRecords        => $total,
            iTotalDisplayRecords => $total,
            aaData               => $data
        }
    );
}

sub show {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    my $gene = $self->stash('organism_resultset')->search_related(
        'features',
        { 'dbxref.accession' => $self->stash('id') },
        { join               => 'dbxref', rows => 1 }
    )->single;

    if ( !$gene ) {
        $self->render_not_found;
        return;
    }

    $self->stash( 'gene' => $gene );
    my $fmt = $self->stash('format');
    if ( $fmt eq 'json' ) {
        $self->show_tab_json;
    }
    elsif ( $fmt eq 'fasta' ) {
        $self->show_fasta;
    }
    else {
        $self->stash( 'tab' => 'gene' );
        $self->show_tab_html;
    }
}

sub show_fasta {
    my ($self) = @_;
    my $header = '>' . $self->stash('id') ;
    $self->render_text( $header . "\n"
            . $self->formatted_sequence( $self->stash('gene')->residues ) );
}

sub show_tab_html {
    my ($self) = @_;
    my $tabview = Genome::Tabview::Page::Gene->new(
        primary_id => $self->stash('id'),
        base_url   => $self->gene_url,
        active_tab => $self->stash('tab'),
        context    => $self,
        model      => $self->app->modware->handler
    );
    $self->stash( $tabview->result );
    $self->render( template => 'gene/show' );
}

sub show_tab_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Tab->new(
        primary_id => $self->stash('id'),
        tab        => $self->stash('tab'),
        context    => $self,
        model      => $self->app->modware->handler,
        base_url   => $self->gene_url
    );

    my $tabview = $factory->instantiate;
    $tabview->init;
    my $conf = $tabview->config;
    $self->render_json( [ map { $_->to_json } $conf->panels ] );
}

sub show_section_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Section->new(
        primary_id => $self->stash('id'),
        tab        => $self->stash('tab'),
        section    => $self->stash('section'),
        context    => $self,
        model      => $self->app->modware->handler,
        base_url   => $self->gene_url
    );

    my $tabview = $factory->instantiate;
    $tabview->init;
    my $conf = $tabview->config;
    $self->render_json( [ map { $_->to_json } $conf->panels ] );
}

1;
