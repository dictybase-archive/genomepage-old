package GenomeREST::Controller::Genepage::Protein;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $id     = $self->stash('gene_id');
    my $json = [
        {
            "name"   => "info",
            "source" => "/purpureum/gene/$id/protein/info",
            "label"  => "General Information"
        },
        {
            "name"   => "sequence",
            "source" => "/purpureum/gene/$id/protein/sequence",
            "label"  => "Protein Sequence"
        },
    ];
    $self->render_json($json) if ( $self->stash('format') eq 'json' );
    $self->stash( params => $json );
}

sub info {
    my ($self) = @_;
    $self->render_text('placeholder');
    my $json = [
        {   "layout" => "row",
            "items"  => [
                {   "content" => [
                        {   "layout" => "column",
                            "items"  => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                { "text" => "dictyBase ID" }
                                            ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                { "text" => "DPU0068769" }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                {   "content" => [
                        {   "layout" => "column",
                            "items"  => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "text" => "Protein Length"
                                                }
                                            ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items" =>
                                                [ { "text" => "392 aa" } ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                {   "content" => [
                        {   "layout" => "column",
                            "items"  => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "text" =>
                                                        "Molecular Weight"
                                                }
                                            ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                { "text" => "44,411.1 Da" }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                },
                {   "content" => [
                        {   "layout" => "column",
                            "items"  => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "text" => "AA Composition"
                                                }
                                            ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "caption" =>
                                                        "View Amino Acid Composition",
                                                    "url" =>
                                                        "\/db\/cgi-bin\/amino_acid_comp.pl?primary_id=DPU0068769",
                                                    "type" => "outer"
                                                }
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ];
#    $self->render_json($json);
}

sub sequence {
    my ($self) = @_;
    $self->render_text('placeholder');
}

1;