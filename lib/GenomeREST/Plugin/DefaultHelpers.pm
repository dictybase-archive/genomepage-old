package GenomeREST::Plugin::DefaultHelpers;

use strict;
use base qw/Mojolicious::Plugin/;

sub register {
    my ( $self, $app ) = @_;
    $app->helper( is_ddb => sub { $_[1] =~ m{^[A-Z]{3}\d+$} } );
    $app->helper(
        base_url => sub {
            my $c = shift;
                $c->app->log->debug($c->req->url->path);
            $c->req->url->path =~ m{^((\/.+?)\/gene)} ? $1 : '';
        }
    );
    $app->helper(
        render_format => sub {
            my $c      = shift;
            my $format = $c->stash('format') || 'html';
            my $method = $c->stash('action') . '_' . $format;
            $c->$method;
        }
    );
    $app->helper(
        panel_to_json => sub {
            my $obj = $_[1]->instantiate;
            $obj->init();
            my $conf = $obj->config();
            [ map { $_->to_json } @{ $conf->panels } ];
        }
    );
}
1;
