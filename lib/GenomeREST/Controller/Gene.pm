package GenomeREST::Controller::Gene;

use strict;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
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
        my ($trans_id) = @{$self->stash('transcripts')};
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
    my $subid   = $self->stash('subid');
    
    my $factory;
    if ( $self->is_ddb($section) ) {
        $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $section,
            -base_url   => $self->base_url
        );
    }
    if ( $subid || !$self->is_ddb($section)) {
        $factory = dicty::Factory::Tabview::Section->new(
            -base_url   => $self->base_url,
            -primary_id => $subid || $gene_id,
            -tab        => $tab,
            -section    => $section,
        );
    }
    $self->render_json( $self->panel_to_json($factory) );
}

sub validate {
    my ( $self ) = @_;
    my $id      = $self->stash('id');
    
    if ( !$self->check_gene($id) ) {
        $self->render(
            template => 'missing',
            message => "Gene $id not found",
            error   => 1,
            header  => 'Error page',
            status => 404
        );
        return;
    }
    $self->stash(
        message =>  "$id has been deleted from dictyBase. It has been replaced by",
        replaced => 1,
        id       => join( ":", $self->stash('replaced') ),
        header   => 'Error page',
        url      => 'http://' . $ENV{WEB_URL_ROOT} . '/gene',
        status => 404
            #the ENV should be changed
    ) if $self->stash('replaced');
    $self->stash(
        deleted => 1,
        message => "$id has been deleted",
        header  => 'Error page',            
        status => 404
    ) if $self->stash('deleted');

    if ($self->stash('replaced') || $self->stash('deleted')){
        $self->render( template => 'missing' ) ;
        return
    };
    return 1;
}


1;

