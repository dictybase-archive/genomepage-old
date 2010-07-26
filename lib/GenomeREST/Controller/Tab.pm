package GenomeREST::Controller::Tab;

use strict;
use warnings;
use base qw/Mojolicious::Controller/;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;

sub section {
    my ( $self, $c ) = @_;
    my $method = 'section_' . $c->stash('format');
    $self->$method($c);

}

sub section_html {
    my ( $self, $c ) = @_;

    my $id      = $c->stash('id');
    my $tab     = $c->stash('tab');
    my $section = $c->stash('section');
    my $gene_id = $c->stash('gene_id');
    my $app     = $self->app;

    #detect if it a dynamic tab
    if ( $app->config->param('tab.dynamic') eq $tab ) {
        my $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -sub_id     => $section,
            -base_url   => $c->stash('base_url')
        );
        $c->stash( $db->result() );
        $self->render( template => $c->stash('species') . '/'
                . $app->config->param('genepage.template') );
    }

}

sub section_json {
    my ( $self, $c ) = @_;

    my $id      = $c->stash('id');
    my $tab     = $c->stash('tab');
    my $section = $c->stash('section');
    my $gene_id = $c->stash('gene_id');
    my $app     = $self->app;

    my $factory;
    if ( $app->helper->is_ddb($section) ) {
        $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $section,
            -base_url   => $c->stash('base_url')
        );
    }
    else {

        $factory = dicty::Factory::Tabview::Section->new(
            -base_url   => $c->stash('base_url'),
            -primary_id => $gene_id,
            -tab        => $tab,
            -section    => $section,
        );
    }

    my $obj = $factory->instantiate;
    $self->render( handler => 'json', data => $obj );
}

sub sub_section {
    my ( $self, $c ) = @_;

    my $factory = dicty::Factory::Tabview::Section->new(
        -primary_id => $c->stash('subid'),
        -section    => $c->stash('section'),
        -tab        => $c->stash('tab'),
        -base_url   => $c->stash('base_url')
    );
    my $obj = $factory->instantiate;
    $self->render( handler => 'json', data => $obj );

}

1;

