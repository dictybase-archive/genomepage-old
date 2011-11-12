package GenomeREST::Controller::Gene;

use strict;

#use Genome::Tabview::Page::Gene;
#use Genome::Factory::Tabview::Tab;
#use Genome::Factory::Tabview::Section;
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

sub search {
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

sub show {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    if ( $self->stash('format') and $self->stash('format') eq 'json' ) {
        return $self->show_json;
    }
    $self->show_html;
}

sub show_html {
    my ($self)  = @_;
    my $gene_id = $self->stash('gene_id');
    my $tabview = Genome::Tabview::Page::Gene->new(
        primary_id => $gene_id,
        base_url   => $self->url_for('current'),
        active_tab => 'gene'
    );
    $tabview->model( $self->app->modware->handler );
    $self->stash( $tabview->result );
    $self->render( template => 'gene/index' );
}

sub show_json {
    my ($self) = @_;
    my $gene_id = $self->stash('gene_id');

    my $factory = Genome::Factory::Tabview::Tab->new(
        primary_id => $gene_id,
        tab        => 'gene',
        context    => $self
    );

    my $tabview = $factory->instantiate;
    $tabview->model( $self->app->modware->handler );
    $tabview->init;
    my $conf = $tabview->config;
    $self->render_json( [ map { $_->to_json } $conf->panels ] );
}

sub show_tab {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    if ( $self->stash('format') and $self->stash('format') eq 'json' ) {
        return $self->show_tab_json;
    }
    $self->show_tab_html;
}

sub show_tab_html {
    my ($self)  = @_;
    my $tab     = $self->stash('tab');
    my $gene_id = $self->stash('gene_id');
    my $app     = $self->app;

    my $db;
    if ( $app->config->{tab}->{dynamic} eq $tab ) {

        #convert gene id to its primary DDB id
        my $trans_id = $self->gene2transid($gene_id);
        if ( !$trans_id ) {    #do some octocat based template here
            $app->log->error(
                "unable to convert to transcript id for $gene_id");
            return;
        }
        $db = Genome::Tabview::Page::Gene->new(
            primary_id => $gene_id,
            active_tab => $tab,
            context    => $self,
            model      => $app->modware->handler,
            sub_id     => $trans_id
        );
        $app->log->debug("going through $trans_id");
    }
    else {
        $db = Genome::Tabview::Page::Gene->new(
            primary_id => $gene_id,
            active_tab => $tab,
            context    => $self,
            model      => $app->modware->handler
        );
    }

    $self->stash( $db->result );
    $self->render( template => 'gene/index' );

}

sub show_tab_json {
    my ($self) = @_;

    my $tab     = $self->stash('tab');
    my $gene_id = $self->stash('gene_id');

    my $factory = Genome::Factory::Tabview::Tab->new(
        tab        => $tab,
        primary_id => $gene_id,
        base_url   => $self->base_url model => ''
    );
    $self->render_json( $self->panel_to_json($factory) );
}

sub show_section {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);
    if ( $self->stash('format') and $self->stash('format') eq 'json' ) {
        return $self->show_section_json;
    }
    $self->show_section_html;
}

sub section_html {
    my ($self) = @_;

    my $gene_id = $self->stash('gene_id');
    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');

    if ( $self->app->config->{tab}->{dynamic} eq $tab ) {
        my $db = Genome::Tabview::Page::Gene->new(
            primary_id => $gene_id,
            active_tab => $tab,
            base_url   => $self->base_url,
            sub_id     => $section,
        );

        $self->stash( $db->result );
        $self->render( template => 'gene/index' );
    }
}

sub section_json {
    my ($self) = @_;

    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');

    my $factory;
    if ( $self->is_ddb($section) ) {
        $factory = Genome::Factory::Tabview::Tab->new(
            tab        => $tab,
            primary_id => $section,
            base_url   => $self->base_url
        );
    }
    else {
        $factory = Genome::Factory::Tabview::Section->new(
            base_url   => $self->base_url,
            primary_id => $gene_id,
            tab        => $tab,
            section    => $section,
            context    => $self
        );
    }
    $self->render_json( $self->panel_to_json($factory) );
}

sub show_subsection_json {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    my $gene_id = $self->stash('gene_id');
    my $tab     = $self->stash('tab');
    my $subid = $self->stash('subid');
    my $sub_section = $self->stash('subsection');

    my $factory = Genome::Factory::Tabview::Section->new(
        primary_id => $subid,
        tab        => $tab,
        section    => $sub_section,
        context    => $self, 
        model => $self->app->modware->handler
    );
}

1;
