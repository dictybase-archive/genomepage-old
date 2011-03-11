package GenomeREST::Controller::Genepage::Protein;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $json = [
        {   "layout" => "accordion",
            "items"  => [
                {   "source" => "\/purpureum\/gene\/DPU_G0068768\/protein\/DPU0068769\/info.json",
                    "label"  => [ { "text" => "General Information" } ],
                    "key"    => "info"
                },
                {   "source" => "\/purpureum\/gene\/DPU_G0068768\/protein\/DPU0068769\/sequence.json",
                    "label"  => [ { "text" => "Protein Sequence" } ],
                    "key"    => "sequence"
                }
            ]
        }
    ];
    $self->render_json($json);
}

sub info {
    my ($self) = @_;
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
    $self->render_json($json);
}

1;