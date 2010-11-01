package GenomeREST::Controller::Page;

use strict;
use Moose;
use GenomeREST::Singleton::Cache;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use Module::Load;
use Try::Tiny;
use namespace::autoclean;
extends 'Mojolicious::Controller';

with 'GenomeREST::Controller::Role::WithJSON';

sub index {
    my ($self) = @_;
    my $method = 'index_' . $self->stash('format');
    $self->$method;

}

sub index_html {
    my ($self) = @_;

    my $app     = $self->app;
    my $cache   = GenomeREST::Singleton::Cache->cache;
    my $gene_id = $self->stash('gene_id');
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
            -base_url   => $self->stash('base_url')
        );
        $result = $db->result;
        $cache->set( $key, $result, $app->config->param('cache.expires_in') );
    }

    #default rendering
    $self->stash($result);
    $self->render( template => $self->stash('species') . '/'
            . $app->config->param('genepage.template') );

}

sub index_json {
    my ($self)  = @_;
    my $gene_id = $self->stash('gene_id');
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
            -base_url   => $self->stash('base_url')
        );
        $data = $factory->instantiate;
        $cache->set( $key, $data,
            $self->app->config->param('cache.expires_in') );
    }
    $self->render( handler => 'json', data => $data );

    #$app->log->debug( 'from json' );
}

sub tab {
    my ( $self, $c ) = @_;
    my $method = 'tab_' . $self->stash('format');
    $self->$method($c);

}

sub tab_html {
    my ($self)  = @_;
    my $id      = $self->stash('id');
    my $tab     = $self->stash('tab');
    my $gene_id = $self->stash('gene_id');
    my $app     = $self->app;
    my $cache   = GenomeREST::Singleton::Cache->cache;
    my $key = sprintf "%s_%s_html", $gene_id, $tab;

    my $result;
    if ( $cache->is_valid($key) ) {
        $result = $cache->get($key);
        $app->log->debug(
            "got tab_html from cache for $gene_id with key $key");
    }
    else {
        my $db;
        if ( $app->config->param('tab.dynamic') eq $tab ) {

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
                -base_url   => $self->stash('base_url'),
            );
            $app->log->debug("going through $trans_id");
        }
        else {
            $db = dicty::UI::Tabview::Page::Gene->new(
                -primary_id => $gene_id,
                -active_tab => $tab,
                -base_url   => $self->stash('base_url'),
            );
        }
        $result = $db->result;
        $cache->set( $key, $result );
        $app->log->debug("storing tab_html for $gene_id with key $key");
    }

    #result
    $self->stash($result);
    $self->render( template => $self->stash('species') . '/'
            . $app->config->param('genepage.template') );

}

sub tab_json {
    my ($self)  = @_;
    my $id      = $self->stash('id');
    my $tab     = $self->stash('tab');
    my $gene_id = $self->stash('gene_id');

    my $app   = $self->app;
    my $cache = GenomeREST::Singleton::Cache->cache;
    my $key   = sprintf "%s_%s_json", $gene_id, $tab;

    my $json;
    if ( $cache->is_valid($key) ) {
        $json = $cache->get($key);
        $app->log->debug("got tab_json from cache for $gene_id");
    }
    else {
        my $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $gene_id,
            -base_url   => $self->stash('base_url')
        );
        my $tabobj = $factory->instantiate;
        $json = $self->obj2json($tabobj);
        $cache->set( $key, $json );
        $app->log->debug("store tab_json in cache for $gene_id");
    }

    $self->render( text => $json, format => 'json' );
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

