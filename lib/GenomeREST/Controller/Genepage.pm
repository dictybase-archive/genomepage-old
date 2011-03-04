package GenomeREST::Controller::Genepage;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $json = [
        "summary" => {
            "source" => "/purpureum/gene/DPU_G0068768/summary.json",
            "name"   => "Gene Summary",
        },
        "protein" => {
            "source" => "/purpureum/gene/DPU_G0068768/protein.json",
            "name"   => "Protein Information",
        },
        "blast" => {
            "source" => "/tools/blast?noheader=1&primary_id=DPU_G0068768",
            "name"    => "BLAST"
        }
    ];
    $self->render_json($json) if $self->stash('format') eq 'json';
    $self->stash( genepage => $json );
}

1;
