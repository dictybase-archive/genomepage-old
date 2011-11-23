package GenomeREST::Controller::Protein;

use strict;
use Genome::Tabview::Page::Gene;
use Genome::Factory::Tabview::Tab;
use Genome::Factory::Tabview::Section;
use base 'GenomeREST::Controller';

sub show_tab_html {
    my ($self) = @_;
    my $db = Genome::Tabview::Page::Gene->new(
        primary_id => $self->stash('gene_id'),
        active_tab => 'protein',
        context    => $self,
        model      => $self->app->modware->handler
    );
    $self->stash( $db->result );
    $self->render( template => 'protein/index' );

}

sub show_tab_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Tab->new(
        tab        => 'protein',
        primary_id => $self->stash('gene_id'),
        model      => $self->app->modware->handler,
        context    => $self
    );
    $self->render_json( $self->panel_to_json($factory) );
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
        primary_id => $self->stash('id'),
        tab        => 'protein',
        section    => $self->stash('subsection'),
        context    => $self,
        model      => $self->app->modware->handler
    );
    $self->render_json( $self->panel_to_json($factory) );
}

1;
