package GenomeREST::Controller::Tab;

use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use base 'Mojolicious::Controller';

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
            -sub_id => $section,
        );

        $self->stash( $db->result );
        $self->render( template => $self->stash('species') . '/gene' );
    }
}

sub section_json {
    my ($self) = @_;

    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');

    my $factory;
    if ( $self->is_ddb($section) ) {
        $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $section,
            -base_url   => $self->base_url
        );
    }
    else {
        $factory = dicty::Factory::Tabview::Section->new(
            -base_url   => $self->base_url,
            -primary_id => $gene_id,
            -tab        => $tab,
            -section    => $section,
        );
    }
    $self->render_json( $self->panel_to_json($factory) );
}

sub sub_section {
    my ($self)  = @_;
    
    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');
    my $subid   = $self->stash('subid');

    my $factory = dicty::Factory::Tabview::Section->new(
        -primary_id => $subid,
        -section    => $section,
        -tab        => $tab,
        -base_url   => $self->stash('base_url')
    );
    $self->render_json( $self->panel_to_json($factory) );
}

1;

