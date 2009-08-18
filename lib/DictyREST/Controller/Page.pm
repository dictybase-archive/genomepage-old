package DictyREST::Controller::Page;

use strict;
use warnings;
use Data::Dumper;
use base qw/Mojolicious::Controller/;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use dicty::Feature;

sub index {
    my ( $self, $c ) = @_;
    my $id      = $c->stash('id');
    my $app     = $self->app;
    my $gene_id = $app->helper->process_id($id);
    if ( !$gene_id ) {
        $self->render(
            template => $app->config->param('genepage.Error'),
            message  => "Input $id not found",
            error    => 1,
            header   => 'Error page',
        );
        return;
    }

    #logic for deleted feature
    my $gene_feat = dicty::Feature->new( -primary_id => $gene_id );
    if ( $gene_feat->is_deleted() ) {
        if ( my $replaced = $gene_feat->replaced_by() )
        {    #is it being replaced
            $c->stash(
                message  => "$gene_id has been replaced by",
                replaced => 1,
                id       => $replaced,
                header   => 'Error page',
            );
        }
        else {
            $c->stash(
                deleted => 1,
                message => "$gene_id has been deleted from dictyBase",
                header  => 'Error page',
            );

        }
        $self->render( template => $app->config->param('genepage.error') );
        return;
    }

    #database query
    my $db = dicty::UI::Tabview::Page::Gene->new(
        -primary_id => $gene_id,
        -active_tab => ' gene ',
    );

    #now rendering
    if ( $c->stash(' format') and $c->stash('format') eq 'json' ) {
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
            template => $app->config->param('genepage.Error'),
            message  => "Input $id not found",
            error    => 1,
        );
        return;
    }

	#logic for deleted feature
	#the logic is repeated however i cannot put it in helper because it conflict with the
	#loading of dicty::Feature under mod_perl
    my $gene_feat = dicty::Feature->new( -primary_id => $gene_id );
    if ( $gene_feat->is_deleted() ) {
        if ( my $replaced = $gene_feat->replaced_by() )
        {    #is it being replaced
            $c->stash(
                message  => "$gene_id has been replaced by",
                replaced => 1,
                id       => $replaced,
                header   => 'Error page',
            );
        }
        else {
            $c->stash(
                deleted => 1,
                message => "$gene_id has been deleted from dictyBase",
                header  => 'Error page',
            );

        }
        $self->render( template => $app->config->param('genepage.error') );
        return;
    }

    if ( $c->stash('format') and $c->stash('format') eq 'json' ) {
        my $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $gene_id,
        );
        my $tabobj = $factory->instantiate;
        $self->render( handler => 'json', data => $tabobj );
        return;
    }

    #another kludge
    #man we need to think seriously about this routing
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
        );

    }

    else {
        $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
        );
    }

    #result
    $c->stash( $db->result() );
    $self->render( template => $app->config->param('genepage.template') );

    #$app->log->debug( $c->res->headers->content_type );

    #have to handle unrecognized format,  however does anybody care ????

}

1;

