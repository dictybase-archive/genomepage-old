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
    $c->stash('format') || $c->stash( format => 'json' );
    if ( $c->stash('format') eq 'json' ) {
        my $factory;
        if ( $app->helper->is_ddb($section) ) {
            $factory = dicty::Factory::Tabview::Tab->new(
                -tab        => $tab,
                -primary_id => $section,
            );
        }
        else {

            $factory = dicty::Factory::Tabview::Section->new(
                -primary_id => $gene_id,
                -section    => $section,
                -tab        => $tab,
            );
        }

        my $obj = $factory->instantiate;
        $self->render( handler => 'json', data => $obj );

        return;
    }

    #here handle non supported format

    #why the block below is needed at all????
    #    if ( $section =~ /$GENE_ID_RGX|$DDB_ID_RGX/ ) {
    #        eval {
    #            my $factory = dicty::Factory::Tabview::Tab->new(
    #                -tab        => $tab,
    #                -primary_id => $section,
    #            );
    #
    #            my $tabobj = $factory->instantiate;
    #            $js = $tabobj->process;
    #        };
    #        if ($@) {
    #
    #            $c->res->code(404);
    #            $c->res->body($@);
    #            return;
    #        }
    #
    #        $c->res->headers->content_type('application/json');
    #        $c->res->code(200);
    #        $c->res->body($js);
    #        return;
    #    }

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

