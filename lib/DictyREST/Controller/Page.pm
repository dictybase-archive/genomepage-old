package DictyREST::Controller::Page;

use strict;
use warnings;
use Data::Dumper;
use base qw/Mojolicious::Controller/;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;

sub index {
    my ( $self, $c ) = @_;
    my $id      = $c->stash('id');
    my $app     = $self->app;
    my $gene_id = $app->helper->process_id($id);
    if ( !$gene_id ) {
        $self->render(
            template => $app->config->param('genepage.error'),
            message  => "Input $id not found",
        );
        return;
    }

    #database query
    my $db = dicty::UI::Tabview::Page::Gene->new(
        -primary_id => $gene_id,
        -active_tab => 'gene',
    );

    #now rendering
    if ( $c->stash('format') and $c->stash('format') eq 'json' ) {
        $self->render( handler => 'json', data => $db );
        return;
    }

    #default rendering
    $c->stash( $db->result() );
    $self->render( template => $app->config->param('genepage.template') );
    #$app->log->debug( $c->res->headers->content_type );

    #have to handle unrecognized format,  however does anybody care ????

}

sub tab {
    my ( $self, $c ) = @_;
    my $id  = $c->stash('id');
    my $tab = $c->stash('tab');
    my $app = $self->app;

    my $gene_id = $app->helper->process_id($id);
    if ( !$gene_id ) {
        $self->render(
            template => $app->config->param('genepage.error'),
            message  => "Input $id not found",
        );
        return;
    }

    if ( $c->stash('format') and $c->stash('format') eq 'json' ) {
        my $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $gene_id,
        );
        my $tabobj = $factory->instantiate;
        $self->render( handler => 'json', data => $tabobj );
        #$app->log->debug( $c->res->headers->content_type );
        #return;
    }

    my $db = dicty::UI::Tabview::Page::Gene->new(
        -primary_id => $gene_id,
        -active_tab => $tab,
    );

    #result
    $c->stash( $db->result() );
    $self->render( template => $app->config->param('genepage.template'), );
    #$app->log->debug( $c->res->headers->content_type );

    #have to handle unrecognized format,  however does anybody care ????

}

1;

