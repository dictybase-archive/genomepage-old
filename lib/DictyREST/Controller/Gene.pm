package DictyREST::Controller::Gene;

use strict;
use warnings;
use base qw/Mojolicious::Controller/;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use dicty::Gene;

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

sub id {
    my ( $self, $c ) = @_;
    my $id      = $c->stash('id');
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

    my $db = dicty::UI::Tabview::Page::Gene->new(
        -primary_id => $gene_id,
        -active_tab => 'gene',
    );

    my $format = $c->stash('format');
    if ( !$format or $format eq 'html' ) {
        $c->stash( $db->result() );
        $self->render(
            template => $self->app->config->param('genepage.template') );
    }
    elsif ( $format eq 'json' ) {
        $self->app->static->serve_404( $c, '404_nr.html' );
    }
    else {    #unsupported format handle it here
        $self->app->static->serve_404( $c, '404_nf.html' );
    }

}

sub absent {
    my ( $self, $c ) = @_;
    $c->res->code(404);
    $c->res->body("Resource Not Implemented");
    return;
}

sub tab {
    my ( $self, $c ) = @_;
    my $id  = $c->url_param('id');
    my $tab = $c->url_param('tab');

    my $gene_id;
    if ( $id =~ $GENE_ID_RGX ) {
        $gene_id = $id;
    }
    else {
        my $feat;
        eval { $feat = dicty::Gene->new( -name => $id ); };
        if ($@) {
            $c->res->code(404);
            $c->res->body($@);
            return;
        }
        $gene_id = $feat->primary_id();
    }

    if ( $id and $tab ) {
        my $js;

        eval {
            my $factory = dicty::Factory::Tabview::Tab->new(
                -tab        => $tab,
                -primary_id => $gene_id,
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

    }
    elsif ($id) {

        my $page = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => 'gene',
            -template   => $self->app->config->param("genepage.template")
        );

        $c->res->headers->content_type('text/html');
        $c->res->code(200);
        $c->res->body( $page->process() );

    }
    else {
        $c->res->headers->content_type('text/html');
        $c->res->body("nothing for you");
    }
}

sub section {
    my ( $self, $c ) = @_;

    my $id      = $c->url_param('id');
    my $tab     = $c->url_param('tab');
    my $section = $c->url_param('section');
    my $gene_id;
    if ( $id =~ $GENE_ID_RGX ) {
        $gene_id = $id;
    }
    else {
        my $feat;
        eval { $feat = dicty::Gene->new( -name => $id ); };
        if ($@) {
            $c->res->code(404);
            $c->res->body($@);
            return;
        }
        $gene_id = $feat->primary_id();
    }

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

