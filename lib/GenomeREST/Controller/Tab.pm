package GenomeREST::Controller::Tab;

use Moose;
use GenomeREST::Singleton::Cache;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use namespace::autoclean;
extends 'Mojolicious::Controller';

with 'GenomeREST::Controller::Role::WithJSON';

sub section {
    my ($self) = @_;
    my $method = 'section_' . $self->stash('format');
    $self->$method();
}

sub section_html {
    my ($self) = @_;

    my $id      = $self->stash('id');
    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');
    my $app     = $self->app;

    #    my $cache   = GenomeREST::Singleton::Cache->cache;
    my $key = sprintf "%s_%s_%s_html", $gene_id, $tab, $section;
    $app->log->debug("key is $key for section_html with $section");

    #detect if it a dynamic tab
    if ( $app->config->param('tab.dynamic') eq $tab ) {
        my $result;

   #        if ( $cache->is_valid($key) ) {
   #            $result = $cache->get($key);
   #            $app->log->debug(
   #                "got section html for $gene_id from cache with $section");
   #        }
   #        else {
        my $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -sub_id     => $section,
            -base_url   => $self->stash('base_url')
        );
        $result = $db->result;

        #            $cache->set( $key, $result,
        #                $app->config->param('cache.expires_in') );
        #            $app->log->debug(
        #                "cached section html for $gene_id with $section");
        #    }
        $self->stash($result);
        $self->render( template => $self->stash('species') . '/gene' );

    }
}

sub section_json {
    my ($self) = @_;

    my $id      = $self->stash('id');
    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');

    my $app = $self->app;

    #    my $cache = GenomeREST::Singleton::Cache->cache;
    my $key = sprintf "%s_%s_%s_json", $gene_id, $tab, $section;
    $app->log->debug($key);

    my $json;

    #    if ( $cache->is_valid($key) ) {
    #        $json = $cache->get($key);
    #        $app->log->debug("got tab_json from cache for $gene_id");
    #    }
    #    else {
    my $factory;
    if ( $self->is_ddb($section) ) {
        $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $section,
            -base_url   => $self->stash('base_url')
        );
    }
    else {
        $factory = dicty::Factory::Tabview::Section->new(
            -base_url   => $self->stash('base_url'),
            -primary_id => $gene_id,
            -tab        => $tab,
            -section    => $section,
        );
    }
    my $tabobj = $factory->instantiate;
    $json   = $self->obj2json($tabobj);

    #        $cache->set( $key, $json );
    #    }
    $self->render( text => $json, format => 'json' );
}

sub sub_section {
    my ($self)  = @_;
    my $tab     = $self->stash('tab');
    my $section = $self->stash('section');
    my $gene_id = $self->stash('gene_id');
    my $subid   = $self->stash('subid');

    my $app = $self->app;
    my $key = sprintf "%s_%s_%s_%s_json", $gene_id, $tab, $subid, $section;

    #    my $cache = GenomeREST::Singleton::Cache->cache;
    my $json;

    #    if ( $cache->is_valid($key) ) {
    #        $json = $cache->get($key);
    #        $app->log->debug("got tab_json from cache for $gene_id");
    #    }
    #    else {

    my $factory = dicty::Factory::Tabview::Section->new(
        -primary_id => $subid,
        -section    => $section,
        -tab        => $tab,
        -base_url   => $self->stash('base_url')
    );
    my $obj = $factory->instantiate;

    #        $cache->set( $key, $json );
    #    }
    $self->render( json => $obj );

}

sub is_ddb {
    my ( $self, $id ) = @_;

    ##should get the id signature  from config file
    return 1 if $id =~ /^[A-Z]{3}\d+$/;
    return 0;
}

1;

