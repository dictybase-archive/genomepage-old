package GenomeREST::Controller::Page;

use strict;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use Module::Load;
use Try::Tiny;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $method = 'index_' . $self->stash('format');
    $self->$method;
}

sub index_html {
    my ($self) = @_;

    my $app = $self->app;
    my $gene_id = $self->stash('gene_id');

    #database query
    my $db = dicty::UI::Tabview::Page::Gene->new(
        -primary_id => $gene_id,
        -active_tab => ' gene ',
        -base_url   => $self->stash('base_url')
    );

    $self->stash($db->result);
    $self->render( template => $self->stash('species') . '/gene' );
}

sub index_json {
    my ($self) = @_;
    my $gene_id = $self->stash('gene_id');

    my $factory = dicty::Factory::Tabview::Tab->new(
        -tab        => 'gene',
        -primary_id => $gene_id,
        -base_url   => $self->url_for('gene')
    );
    
    my $obj = $factory->instantiate;
    $obj->init;
    my $conf = $obj->config;
    $self->render_json( [ map { $_->to_json } @{ $conf->panels } ] );
}

sub tab {
    my ($self) = @_;
    my $method = 'tab_' . $self->stash('format');
    $self->$method();
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
            -base_url   => $self->url_for('gene')
        );
        $app->log->debug("going through $trans_id");
    }
    else {
        $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -base_url   => $self->url_for('gene')
        );
    }

    $self->stash($db->result);
    $self->render( template => $self->stash('species') . '/gene');

}

sub tab_json {
    my ($self)  = @_;

    my $tab     = $self->stash('tab');
    my $gene_id = $self->stash('gene_id');
    my $app = $self->app;

    my $factory = dicty::Factory::Tabview::Tab->new(
        -tab        => $tab,
        -primary_id => $gene_id,
        -base_url   => $self->url_for('gene')
    );
    
    my $obj = $factory->instantiate;
    $obj->init;
    my $conf = $obj->config;
    $self->render_json( [ map { $_->to_json } @{ $conf->panels } ] );
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

