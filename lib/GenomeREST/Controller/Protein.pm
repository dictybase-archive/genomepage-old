package GenomeREST::Controller::Protein;

use strict;
use Genome::Tabview::Page::Gene;
use Genome::Factory::Tabview::Tab;
use Genome::Factory::Tabview::Section;
use base 'GenomeREST::Controller';

sub show_tab_html {
    my ($self) = @_;
    my $db = Genome::Tabview::Page::Gene->new(
        primary_id => $self->stash('id'),
        active_tab => 'protein',
        context    => $self,
        model      => $self->app->modware->handler
    );
    $self->stash( $db->result );
    $self->render( template => 'gene/show' );

}

sub show_tab_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Tab->new(
        tab        => 'protein',
        primary_id => $self->stash('id'),
        model      => $self->app->modware->handler,
        base_url   => $self->gene_url, 
        context    => $self
    );

    my $tabview = $factory->instantiate;
    $tabview->init;
    my $conf = $tabview->config;
    $self->render_json( [ map { $_->to_json } $conf->panels ] );
}

sub show_section_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Tab->new(
        tab        => 'protein',
        primary_id => $self->stash('id'),
        context    => $self,
        model      => $self->app->modware->handler
    );
    $self->render_json( $self->panel_to_json($factory) );
}

sub show_subsection_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Section->new(
        primary_id => $self->stash('subid'),
        tab        => 'protein',
        section    => $self->stash('subsection'),
        context    => $self,
        model      => $self->app->modware->handler, 
        base_url => $self->gene_url
    );

    my $tabview = $factory->instantiate;
    $tabview->init;
    my $conf = $tabview->config;
    $self->render_json( [ map { $_->to_json } $conf->panels ] );
}

1;
