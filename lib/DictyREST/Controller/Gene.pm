package DictyREST::Controller::Gene;

use strict;
use warnings;
use base qw/Mojolicious::Controller/;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use dicty::Gene;
use Data::Dumper;

my $GENE_ID_RGX = qr/^D[A-Z]+_G\d{6,}$/;
my $DDB_ID_RGX  = qr/^DDB\d{7,}/;

sub is_name {
    my ( $self, $id ) = @_;
    return 0 if $id =~ $GENE_ID_RGX;
    return 1;
}

sub name2id {
    my ( $self, $id ) = @_;
    my $feat;
    eval { $feat = dicty::Gene->new( -name => $id ); };
    return 0 if $@;
    return $feat->primary_id();
}

sub process_id {
    my ( $self, $id ) = @_;
    my $gene_id = $id;
    if ( $self->is_name($id) ) {
        $gene_id = $self->name2id($id);

        #in case the name does not get resolved
        #handle it here
        if ( !$gene_id ) {
            $self->render(
                template => $self->app->config->param('genepage.error'),
                message  => "Input $id not found",
            );
            return;
        }
    }
    return $gene_id;
}

sub id {
    my ( $self, $c ) = @_;
    my $id      = $c->stash('id');
    my $gene_id = $self->process_id($id);
    return if !$gene_id;

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
    $self->render(
        template => $self->app->config->param('genepage.template') );

    #have to handle unrecognized format,  however does anybody care ????

}

sub tab {
    my ( $self, $c ) = @_;
    my $id  = $c->stash('id');
    my $tab = $c->stash('tab');

    my $gene_id = $self->process_id($id);
    return if !$gene_id;

    if ( $c->stash('format') and $c->stash('format') eq 'json' ) {
        my $factory = dicty::Factory::Tabview::Tab->new(
            -tab        => $tab,
            -primary_id => $gene_id,
        );
        my $tabobj = $factory->instantiate;
        $self->render( handler => 'json', data => $tabobj );
        return;
    }

    my $db = dicty::UI::Tabview::Page::Gene->new(
        -primary_id => $gene_id,
        -active_tab => $tab,
    );

    #result
    $c->stash( $db->result() );
    $self->render( template => $self->app->config->param('genepage.template'),
    );

    #have to handle unrecognized format,  however does anybody care ????

}

sub section {
    my ( $self, $c ) = @_;

    my $id      = $c->stash('id');
    my $tab     = $c->stash('tab');
    my $section = $c->stash('section');

    my $gene_id = $self->process_id($id);
    return if !$gene_id;

    my $js;

    if ( $section =~ /$GENE_ID_RGX|$DDB_ID_RGX/ ) {
        eval {
            my $factory = dicty::Factory::Tabview::Tab->new(
                -tab        => $tab,
                -primary_id => $section,
            );

            my $tabobj = $factory->instantiate;
            $js = $tabobj->process;
        };
        if ($@) {

            $c->res->code(404);
            $c->res->body($@);
            return;
        }

        $c->res->headers->content_type('application/json');
        $c->res->code(200);
        $c->res->body($js);
        return;
    }

    eval {
        my $factory = dicty::Factory::Tabview::Section->new(
            -primary_id => $gene_id,
            -section    => $section,
            -tab        => $tab,
        );
        my $sec = $factory->instantiate;
        $js = $sec->process();
    };
    if ($@) {
        $c->res->code(404);
        $c->res->body($@);
        return;
    }

    $c->res->headers->content_type('application/json');
    $c->res->code(200);
    $c->res->body($js);
}

sub sub_section {
    my ( $self, $c ) = @_;

    my $tab     = $c->url_param('tab');
    my $id      = $c->url_param('subid');
    my $section = $c->url_param('section');
    my $js;

    eval {
        my $factory = dicty::Factory::Tabview::Section->new(
            -primary_id => $id,
            -section    => $section,
            -tab        => $tab,
        );
        my $sec = $factory->instantiate;
        $js = $sec->process();
    };
    if ($@) {
        $c->res->code(404);
        $c->res->body($@);
        return;
    }

    $c->res->headers->content_type('application/json');
    $c->res->code(200);
    $c->res->body($js);

}

1;

