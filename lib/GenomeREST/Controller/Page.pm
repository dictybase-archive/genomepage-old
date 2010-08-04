package GenomeREST::Controller::Page;

use strict;
use warnings;
use GenomeREST::Singleton::Cache;
use base qw/Mojolicious::Controller/;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use Module::Load;

sub index {
    my ( $self, $c ) = @_;
    my $method = 'index_' . $c->stash('format');
    $self->$method($c);

}

sub index_html {
    my ( $self, $c ) = @_;

    my $app     = $self->app;
    my $cache   = GenomeREST::Singleton::Cache->cache;
    my $gene_id = $c->stash('gene_id');
    my $key     = $gene_id . '_index';

    my $result;
    if ( $cache->is_valid($key) ) {
        $result = $cache->get($key);
        $app->log->debug("got index for $gene_id from cache");
    }
    else {

        #database query
        my $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => ' gene ',
            -base_url   => $c->stash('base_url')
        );
        $result = $db->result;
        $cache->set( $key, $result );
    }

    #default rendering
    $c->stash($result);
    $self->render( template => $c->stash('species') . '/'
            . $app->config->param('genepage.template') );

}

sub index_json {
    my ( $self, $c ) = @_;
    my $gene_id = $c->stash('gene_id');
    my $cache   = GenomeREST::Singleton::Cache->cache;
    my $key     = $gene_id . '_index_json';
    my $data;

    if ( $cache->is_valid($key) ) {
        $data = $cache->get($key);
        $self->app->log->debug("got json data for $gene_id from cache");
    }
    else {
        #now rendering
        my $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => 'gene',
            -primary_id => $gene_id,
            -base_url   => $c->stash('base_url')
        );
        $data = $factory->instantiate;
        $cache->set($key, $data);
    }
    $self->render( handler => 'json', data => $data );

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
        my $trans_id = $self->transcript_id($gene_id);
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


sub transcript_id {
    my ( $self, $id ) = @_;
    load dicty::Feature;
    my $gene;
    try {
        $gene = dicty::Feature->new( -primary_id => $id );
    }
    catch {
        return 0;
    };
    my ($trans) = @{ $gene->primary_features() };
    $trans->primary_id if $trans;
}

1;

