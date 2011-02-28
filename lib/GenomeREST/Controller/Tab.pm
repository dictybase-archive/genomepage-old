package GenomeREST::Controller::Tab;

use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use base 'Mojolicious::Controller';

sub section {
    my ($self) = @_;
    my $method = 'section_' . $self->stash('format');
    $self->$method();
}

sub section_html {
    my ($self) = @_;

    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');
    my $app     = $self->app;

    if ( $app->config->{tab}->{dynamic} eq $tab ) {
        my $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -base_url   => $self->url_for('gene')
            -sub_id     => $section,
        );

        $self->stash($db->result);
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
            -base_url   => $self->url_for('gene')
        );
    }
    else {
        $factory = dicty::Factory::Tabview::Section->new(
            -base_url   => $self->url_for('gene'),
            -primary_id => $gene_id,
            -tab        => $tab,
            -section    => $section,
        );
    }
    my $obj = $factory->instantiate;
    $obj->init;
    my $conf = $obj->config;
    $self->render_json( [ map { $_->to_json } @{ $conf->panels } ] );
}

sub sub_section {
    my ($self)  = @_;
    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');
    my $subid   = $self->stash('subid');

    my $json;
    my $factory = dicty::Factory::Tabview::Section->new(
        -primary_id => $subid,
        -section    => $section,
        -tab        => $tab,
        -base_url   => $self->stash('base_url')
    );
    my $obj = $factory->instantiate;
    $obj->init();
    my $conf = $obj->config();
    $self->render_json( [ map { $_->to_json } @{ $conf->panels } ] );
}

1;

