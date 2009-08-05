package DictyREST::Controller::Tab;

use strict;
use warnings;
use base qw/Mojolicious::Controller/;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;

sub section {
    my ( $self, $c ) = @_;

    my $id      = $c->stash('id');
    my $tab     = $c->stash('tab');
    my $section = $c->stash('section');
    my $app     = $self->app;


    my $gene_id = $app->helper->process_id($id);
    if ( !$gene_id ) {
        $self->render(
            template => $app->config->param('genepage.error'),
            message  => "Input $id not found",
        );
        return;
    }

    #the default format is json here

    if ( $c->stash('format') and $c->stash('format') eq 'json' ) {
        my $factory;
        if ( $app->helper->is_ddb($section) ) {
            $factory = dicty::Factory::Tabview::Tab->new(
                -tab        => $tab,
                -primary_id => $section,
            );
        }
        else {

            $factory = dicty::Factory::Tabview::Section->new(
                -tab        => $tab,
                -primary_id => $gene_id,
                -section    => $section,
            );
        }

        my $obj = $factory->instantiate;
        $self->render( handler => 'json', data => $obj );
        return;
    }

    #i am assuming that it is html
    #need to change that assumtion at my earliest
    #did it because of deadlines
    #detect if it a dynamic tab
    if ( $app->config->param('tab.dynamic') eq $tab ) {
        my $db = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => $tab,
            -sub_id     => $section,
        );
        $c->stash( $db->result() );
        #force formatter
        $self->render( 
        	template => $app->config->param('genepage.template'),
        );
    }

    #here handle html format

}

sub sub_section {
    my ( $self, $c ) = @_;

    $c->stash('format') || $c->stash( format => 'json' );
    if ( $c->stash('format') eq 'json' ) {
        my $factory = dicty::Factory::Tabview::Section->new(
            -primary_id => $c->stash('subid'),
            -section    => $c->stash('section'),
            -tab        => $c->stash('tab'),
        );
        my $obj = $factory->instantiate;
        $self->render( handler => 'json', data => $obj );
    }

    #here handle non supported format

}

1;

