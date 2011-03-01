package GenomeREST::Controller::Page;

use strict;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use Module::Load;
use Try::Tiny;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    $self->render_format;
}

sub index_html {
    my ($self) = @_;
    my $gene_id = $self->stash('gene_id');
    my $db = dicty::UI::Tabview::Page::Gene->new(
        -primary_id => $gene_id,
        -active_tab => ' gene ',
        -base_url   => $self->base_url
    );

    $self->stash( $db->result );
    $self->render( template => $self->stash('species') . '/gene' );
}

sub index_json {
    my ($self) = @_;
    my $gene_id = $self->stash('gene_id');

    my $factory = dicty::Factory::Tabview::Tab->new(
        -tab        => 'gene',
        -primary_id => $gene_id,
        -base_url   => $self->base_url
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
        my $trans_id = $self->transcript_id($gene_id);
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
    $self->render( template => $self->stash('species') . '/gene' );

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

sub transcript_id {
    my ( $self, $id ) = @_;
    load dicty::Feature;
    my $gene;
    try {
        $gene = dicty::Feature->new( -primary_id => $id );
    }
    catch {
        $self->app->log->debug($_);
        return 0;
    };
    my ($trans) = @{ $gene->primary_features() };
    $trans->primary_id if $trans;
}

1;

