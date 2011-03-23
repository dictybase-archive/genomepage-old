package GenomeREST::Controller::Genepage;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $id     = $self->stash('gene_id');
    my $json   = [
        {   "name"   => "summary",
            "source" => "/purpureum/gene/$id/test/summary",
            "label"  => "Gene Summary",
            "active" => "true"
        },
        {   "name"   => "protein",
            "source" => "/purpureum/gene/$id/test/protein",
            "label"  => "Protein Information",
        },
        {   "name" => "blast",
            "content" =>
                "<iframe style=\"height:750px;width:100%;\" src=\"/tools/blast?noheader=1&primary_id=$id\"></iframe>",
            "label" => "BLAST"
        }
    ];
    $self->render_json($json) if $self->stash('format') eq 'json';
    $self->stash( params => $json );
}

1;

