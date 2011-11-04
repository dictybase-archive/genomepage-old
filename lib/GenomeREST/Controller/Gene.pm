package GenomeREST::Controller::Gene;

use strict;
use Genome::Tabview::Page::Gene;
use Genome::Factory::Tabview::Tab;
use Genome::Factory::Tabview::Section;
use Module::Load;
use Try::Tiny;
use base 'GenomeREST::Controller';

sub list {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);
    $self->render( template => 'gene' );
}

sub gene_search {
    my ($self) = @_;

    my $model = $self->app->modware->handler;
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
        push @$data, [ $row->dbxref->accession, $row->uniquename, $seqlen ];
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

sub index {
    my ($self) = @_;
    $self->render_format;
}

sub index_html {
    my ($self)  = @_;
    my $gene_id = $self->stash('gene_id');
    my $db      = Genome::Tabview::Page::Gene->new(
        primary_id => $gene_id,
        base_url   => $self->url_for('current'),
        active_tab => 'gene'
    );
    $db->model($self->app->modware->handler);
    $self->stash( $db->result );
}

sub index_json {
    my ($self) = @_;
    my $gene_id = $self->stash('gene_id');

    my $factory = dicty::Factory::Tabview::Tab->new(
        -primary_id => $gene_id,
        -base_url   => $self->url_for('gene'),
        -tab        => 'gene',
        -context    => $self
    );
    $self->render_json( $self->panel_to_json($factory) );
}

sub tab {
    my ($self) = @_;
    $self->render_format;
}

sub tab_html {
    my ($self)  = @_;
    my $tab     = $self->stash('tab');
    my $gene_id = $self->stash('gene_id');
    my $app     = $self->app;

    my $db;
    if ( $app->config->{tab}->{dynamic} eq $tab ) {

        #convert gene id to its primary DDB id
        my ($trans_id) = @{ $self->stash('transcripts') };
        if ( !$trans_id ) {    #do some octocat based template here
            $app->log->error(
                "unable to convert to transcript id for $gene_id");
            return;
        }
        $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -sub_id     => $trans_id,
            -base_url   => $self->base_url
        );
        $app->log->debug("going through $trans_id");
    }
    else {
        $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -base_url   => $self->base_url
        );
    }

    $self->stash( $db->result );
    $self->render( template => '/gene/index' );

}

sub tab_json {
    my ($self) = @_;

    my $tab     = $self->stash('tab');
    my $gene_id = $self->stash('gene_id');

    my $factory = dicty::Factory::Tabview::Tab->new(
        -tab        => $tab,
        -primary_id => $gene_id,
        -base_url   => $self->base_url
    );
    $self->render_json( $self->panel_to_json($factory) );
}

sub section {
    my ($self) = @_;
    $self->render_format;
}

sub section_html {
    my ($self) = @_;

    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');

    if ( $self->app->config->{tab}->{dynamic} eq $tab ) {
        my $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -base_url   => $self->base_url,
            -sub_id     => $section,
        );

        $self->stash( $db->result );
        $self->render( template => '/gene/index' );
    }
}

sub section_json {
    my ($self) = @_;

    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');
    my $subid   = $self->stash('subid');

    my $factory;
    if ( $self->is_ddb($section) ) {
        $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $section,
            -base_url   => $self->base_url
        );
    }
    if ( $subid || !$self->is_ddb($section) ) {
        $factory = dicty::Factory::Tabview::Section->new(
            -base_url   => $self->base_url,
            -primary_id => $subid || $gene_id,
            -tab        => $tab,
            -section    => $section,
        );
    }
    $self->render_json( $self->panel_to_json($factory) );
}

sub validate {
    my ($self) = @_;
    my $id = $self->stash('id');

    if (   !$self->check_gene($id)
        || $self->stash('replaced')
        || $self->stash('deleted') )
    {
        $self->res->code(404);
        $self->render('gene/not_found');
    }
    return 1;
}

1;
