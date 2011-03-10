package GenomeREST::Controller::Genepage;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $json = [
        {   "name" => "summary",
            "source" => {
                "controller" => "genepage-summary",
                "action" => "index",
                "url" => "/purpureum/gene/DPU_G0068768/test/summary",
            },
            "label"   => "Gene Summary",
            "active" => "true"
        },
        {   "name" => "protein",
            "source" => {
                "controller" => "genepage-protein",
                "action" => "index",
                "url" => "/purpureum/gene/DPU_G0068768/test/protein",
            },
            "label"   => "Protein Information",
        },
#        {   "name" => "blast",
#            "source" => "/tools/blast?noheader=1&primary_id=DPU_G0068768",
#            "label"   => "BLAST"
#        }
    ];
    $self->render_json($json) if $self->stash('format') eq 'json';
    
    for ( my $i = 0; $i < @$json; $i++ ) {
        my $source = @$json->[$i]->{source};
        $source = $self->req->url->base . $source if $source =~ m{^\/};

#        @$json->[$i]->{content} = $self->render_partial( 
#            controller => $source->{controller}, 
#            action => $source->{action}
#        );
        
#        @$json->[$i]->{content} = $self->client->get($source)->res->body;

        $self->client->get( $source => sub {
            @$json->[$i]->{content} = shift->res->body;
        })->start;
    }
    use Data::Dumper;
    $self->app->log->debug( Dumper $json );
    $self->stash( params => $json );
}

1;
