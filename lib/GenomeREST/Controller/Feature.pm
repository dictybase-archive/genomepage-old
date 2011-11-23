package GenomeREST::Controller::Gene;

use strict;
use Genome::Tabview::Page::Gene;
use Genome::Factory::Tabview::Tab;
use Genome::Factory::Tabview::Section;
use Module::Load;
use Try::Tiny;
use base 'GenomeREST::Controller';

sub show_tab_html {
    my ($self) = @_;
    my $db = Genome::Tabview::Page::Gene->new(
        primary_id => $self->stash('gene_id'),
        active_tab => 'feature',
        context    => $self,
        model      => $self->app->modware->handler
    );
    $self->stash( $db->result );
    $self->render( template => 'protein/index' );

}

sub show_tab_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Tab->new(
        tab        => 'feature',
        primary_id => $self->stash('gene_id'),
        model      => $self->app->modware->handler,
        context    => $self
    );
    $self->render_json( $self->panel_to_json($factory) );
}

sub show_section_html {
    my ($self) = @_;

    my $db = Genome::Tabview::Page::Gene->new(
        primary_id => $self->stash('gene_id'),
        active_tab => 'feature',
        base_url   => $self->base_url,
        sub_id     => $self->stash('section'),
    );

    $self->stash( $db->result );
    $self->render( template => 'gene/index' );
}

sub section_json {
    my ($self) = @_;
	my $factory = Genome::Factory::Tabview::Tab->new(
        tab        => 'feature',
        primary_id => $self->stash('id'),
        context    => $self,
        model      => $self->app->modware->handler
    );
    $self->render_json( $self->panel_to_json($factory) );
}

sub show_subsection_json {
	my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Section->new(
        primary_id => $self->stash('gene_id'),
        tab        => 'protein',
        section    => $self->stash('section'),
        context    => $self,
        model      => $self->app->modware->handler
        sub_section => $self->stash('sub_section')
    );
    $self->render_json( $self->panel_to_json($factory) );
}

1;
