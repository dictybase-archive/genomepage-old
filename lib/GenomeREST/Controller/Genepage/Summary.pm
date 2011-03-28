package GenomeREST::Controller::Genepage::Summary;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $id     = $self->stash('gene_id');
    my $json   = [
        {   "name"   => "info",
            "source" => "/purpureum/gene/$id/summary/info",
            "label"  => "General Information"
        },
        {   "name"   => "genomic_info",
            "source" => "/purpureum/gene/$id/summary/genomic_info",
            "label"  => "Genomic Information"
        },
        {   "name"   => "product",
            "source" => "/purpureum/gene/$id/summary/product",
            "label"  => "Gene Product Information"
        }
    ];
    $self->render_json($json) if ( $self->stash('format') eq 'json' );
    $self->stash( params => $json );
}

sub info {
    my ($self) = @_;
    my $id     = $self->stash('gene_id');
    my $json   = [
        {   "label"   => "Gene Name",
            "content" => "<i>$id</i>"
        },
        {   "label"   => "Gene ID",
            "content" => "$id"
        },
        {   "label"   => "Community Annotations",
            "content" => qq{
                <a class="outer_link" href="http://wiki.dictybase.org/dictywiki/index.php/$id?action=edit">Add an annotation for $id</a>
                <a class="outer_link" href="http://wiki.dictybase.org/dictywiki/Community_Annotations">Community Annotations Help</a>   
            }
        }
    ];
    $self->render_json($json) if ( $self->stash('format') eq 'json' );
    $self->stash( params => $json );
}

sub genomic_info {
    my ($self) = @_;
    my $id     = $self->stash('gene_id');
    my $json   = [
        {   "label" => "Location",
            "content" =>
                "Supercontig <b>scaffold_48</b> coordinates <b>59804</b> to <b>61242</b>, <b>Watson</b> strand"
        },
        {   "label"   => "Genomic Map",
            "content" => qq{
                [Click on the map to browse the genome from this location]<br>
                <a href="/db/cgi-bin/ggb/gbrowse/purpureum?name=scaffold_48:59661..61385">
                    <img src="/db/cgi-bin/ggb/gbrowse_img/purpureum?name=scaffold_48:59661..61385&width=500&type=Gene+Gene_Model+tRNA+ncRNA&keystyle=between&abs=1">
                </a>
            }
        }
    ];
    $self->render_json($json) if ( $self->stash('format') eq 'json' );
    $self->stash( params => $json );
}

sub product {
    my ($self) = @_;
    my $id     = $self->stash('gene_id');
    my $json   = [
        {   "label"   => "Protein Coding Gene",
            "content" => "DPU0068769",
        },
        {   "label"   => "Genomic Coordinates",
            "content" => [
                {   "local"  => '1 - 42',
                    "global" => "59804 - 59845"
                },
                {   "local"  => "303 - 1439",
                    "global" => "60106 - 61242"
                }
            ],
        },
        {   "label"   => "Protein Length",
            "content" => "392 aa",
        },
        {   "label"   => "Protein Molecular Weight",
            "content" => "44,411.1 Da",
        },
        {   "label" => "More Protein Data",
            "content" =>
                '<a href="/purpureum/gene/DPU_G0068768/protein/DPU0068769" class="tab_link" style="">Protein sequence, domains and much more...</a>',
        },
        {   "label"   => "Sequence",
            "content" => [ 'Protein', 'DNA coding sequence', 'Genomic DNA' ],
        }
    ];
    $self->render_json($json) if ( $self->stash('format') eq 'json' );
    $self->stash( params => $json );
}

1;
