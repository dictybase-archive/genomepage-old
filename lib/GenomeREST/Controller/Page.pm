package GenomeREST::Controller::Page;

use strict;
use warnings;
use base qw/Mojolicious::Controller/;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;

sub index {
    my ( $self, $c ) = @_;
    my $method = 'index_' . $c->stash('format');
    $self->$method($c);

}

sub index_html {
    my ( $self, $c ) = @_;

    my $app     = $self->app;
    my $gene_id = $c->stash('gene_id');

    #$app->log->debug($c->url_for);
    #$app->log->debug($c->stash('base_url'));

    #database query
    my $db = dicty::UI::Tabview::Page::Gene->new(
        -primary_id => $gene_id,
        -active_tab => ' gene ',
        -base_url   => $c->stash('base_url')
    );

    #default rendering
    $c->stash( $db->result() );
    $self->render( template => $c->stash('species') . '/'
            . $app->config->param('genepage.template') );

    #$app->log->debug( 'from html' );
}

sub index_json {
    my ( $self, $c ) = @_;
    my $gene_id = $c->stash('gene_id');
    my $app     = $self->app;

    #now rendering
    my $factory = dicty::Factory::Tabview::Tab->new(
        -tab        => 'gene',
        -primary_id => $gene_id,
        -base_url   => $c->stash('base_url')
    );
    $self->render( handler => 'json', data => $factory->instantiate );

    #$app->log->debug( 'from json' );
}

sub tab {
    my ( $self, $c ) = @_;
    my $method = 'tab_' . $c->stash('format');
    $self->$method($c);

}

sub tab_html {
    my ( $self, $c ) = @_;
    my $id      = $c->stash('id');
    my $tab     = $c->stash('tab');
    my $gene_id = $c->stash('gene_id');
    my $app     = $self->app;

    my $db;
    if ( $app->config->param('tab.dynamic') eq $tab ) {

        #convert gene id to its primary DDB id
        my $trans_id = $app->helper->transcript_id($gene_id);
        if ( !$trans_id ) {    #do some octocat based template here
            return;
        }
        $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -sub_id     => $trans_id,
            -base_url   => $c->stash('base_url'),
        );
    }
    else {
        $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -base_url   => $c->stash('base_url'),
        );
    }

    #result
    $c->stash( $db->result() );
    $self->render( template => $c->stash('species') . '/'
            . $app->config->param('genepage.template') );

    #$app->log->debug( $c->res->headers->content_type );
}

sub tab_json {
    my ( $self, $c ) = @_;
    my $id      = $c->stash('id');
    my $tab     = $c->stash('tab');
    my $gene_id = $c->stash('gene_id');

    my $factory = dicty::Factory::Tabview::Tab->new(
        -tab        => $tab,
        -primary_id => $gene_id,
        -base_url   => $c->stash('base_url')
    );
    my $tabobj = $factory->instantiate;
    $self->render( handler => 'json', data => $tabobj );

    #$app->log->debug( $c->res->headers->content_type );
}

1;

