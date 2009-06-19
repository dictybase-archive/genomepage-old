package DictyREST::Controller::Gene;

use strict;
use warnings;
use base qw/DictyREST::Controller/;
use Config::Simple;
use File::Spec::Functions;
use dicty::UI::Tabview::Page::Gene;
use dicty::Factory::Tabview::Tab;
use dicty::Factory::Tabview::Section;
use dicty::Gene;

my $GENE_ID_RGX = qr/^DDB_G\d{6,}/;

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
        if ($c->app->mode =~ /production/i) {
        	 $c->app->log->info($js);
				}
				$c->res->code(200);
        $c->res->body($js);

    }
    elsif ($id) {

        my $file = catfile( $ENV{DICTY_DIR_ROOT}, 'modwareconf.ini' );
        my $conf = Config::Simple->new($file);

        my $page = dicty::UI::Tabview::Page::Gene->new(
            -primary_id => $gene_id,
            -active_tab => 'gene',
            -template   => $conf->param("genepage.template")
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

1;

