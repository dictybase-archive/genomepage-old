package GenomeREST::Controller::Genepage::Summary;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $json = [
        "info" => {
            "source" => "\/purpureum\/gene\/DPU_G0068768\/gene\/info.json",
            "name" => "General Information"      
        },
        "genomic_info" => {
            "source" => "\/purpureum\/gene\/DPU_G0068768\/gene\/genomic_info.json",
            "name" => "Genomic Information"
        },
        "product" => {
            "source" => "\/purpureum\/gene\/DPU_G0068768\/gene\/product.json",
            "name" => "Gene Product Information"
        },
        "sequences" => {
            "source" => "\/purpureum\/gene\/DPU_G0068768\/gene\/sequences.json",
            "name" => "Associated Sequences"
        },   
        "links" => {
            "source" => "\/purpureum\/gene\/DPU_G0068768\/gene\/links.json",
            "name" => "Links"
        }   
    ];
    $self->render_json($json);
}

sub info {
    my ($self) = @_;
    my $json = [
        {   "layout" => "row",
            "items" => [
                {   "content" => [
                        {   "layout" => "column",
                            "items" => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"
                                                => [ { "text" => "Gene Name" } ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items" => [
                                                {   "text" => "<i>DPU_G0068768<\/i>"
                                                }
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
                            "items" => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"
                                                => [ { "text" => "Gene ID" } ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items" => [
                                                { "text" => "DPU_G0068768" }
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
                            "items" => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items" => [
                                                {   "text" => "Community Annotations"
                                                }
                                            ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items" => [
                                                {   "caption" => "Add an annotation for DPU_G0068768",
                                                    "url" => "http:\/\/wiki.dictybase.org\/dictywiki\/index.php\/DPU_G0068768?action=edit",
                                                    "type" => "outer"
                                                },
                                                {   "caption" => "Community Annotations Help",
                                                    "url" => "http:\/\/wiki.dictybase.org\/dictywiki\/index.php\/Community_Annotations",
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

sub genomic_info {
    my ($self) = @_;
    my $json = [
        {   "layout" => "row",
            "items" => [
                {   "content" => [
                        {   "layout" => "column",
                            "items" => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [ { "text" => "Location" } ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "text" => "Supercontig <b>scaffold_48<\/b> coordinates <b>59804<\/b> to <b>61242<\/b>, <b>Watson<\/b> strand"
                                                }
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
                            "items" => [
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items" => [
                                                { "text" => "Genomic Map" }
                                            ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items" => [
                                                {   "text" => "[Click on the map to browse the genome from this location]<br>"
                                                },
                                                {   "caption" => "\/db\/cgi-bin\/ggb\/gbrowse_img\/purpureum?name=scaffold_48:59661..61385&width=500&type=Gene+Gene_Model+tRNA+ncRNA&keystyle=between&abs=1",
                                                    "url" => "\/db\/cgi-bin\/ggb\/gbrowse\/purpureum?name=scaffold_48:59661..61385",
                                                    "type" => "gbrowse"
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

sub product {
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
                                                {   "text" =>
                                                        "Protein Coding Gene"
                                                }
                                            ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "caption" => "DPU0068769",
                                                    "url" =>
                                                        "\/purpureum\/gene\/DPU_G0068768\/feature\/DPU0068769",
                                                    "type" => "tab"
                                                }
                                            ]
                                        }
                                    ]
                                },
                                {   "rowspan" => 5,
                                    "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "text" =>
                                                        "Genomic Coordinates"
                                                }
                                            ]
                                        }
                                    ],
                                    "type" => "content_table_second_title"
                                },
                                {   "rowspan" => 5,
                                    "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "table_class" => "null",
                                                    "records" => [
                                                        {   "name" => [
                                                                {   "text" => 1
                                                                }
                                                            ],
                                                            "chrom" => [
                                                                {   "text" =>
                                                                        "59804 - 59845"
                                                                }
                                                            ],
                                                            "local" => [
                                                                {   "text" =>
                                                                        "1 - 42"
                                                                }
                                                            ]
                                                        },
                                                        {   "name" => [
                                                                {   "text" => 2
                                                                }
                                                            ],
                                                            "chrom" => [
                                                                {   "text" =>
                                                                        "60106 - 61242"
                                                                }
                                                            ],
                                                            "local" => [
                                                                {   "text" =>
                                                                        "303 - 1439"
                                                                }
                                                            ]
                                                        }
                                                    ],
                                                    "columns" => [
                                                        {   "label" => "Exon",
                                                            "sortable" =>
                                                                "true",
                                                            "key" => "name"
                                                        },
                                                        {   "label" =>
                                                                "Local coords.",
                                                            "sortable" =>
                                                                "true",
                                                            "key" => "local"
                                                        },
                                                        {   "label" =>
                                                                "Chrom. coords.",
                                                            "sortable" =>
                                                                "true",
                                                            "key" => "chrom"
                                                        }
                                                    ],
                                                    "type" => "table"
                                                }
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
                                                        "Protein Molecular Weight"
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
                                                {   "text" =>
                                                        "More Protein Data"
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
                                                        "Protein sequence, domains and much more...",
                                                    "url" =>
                                                        "\/purpureum\/gene\/DPU_G0068768\/protein\/DPU0068769",
                                                    "type" => "tab"
                                                }
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
                                            "items" =>
                                                [ { "text" => "Sequence" } ]
                                        }
                                    ],
                                    "type" => "content_table_title"
                                },
                                {   "content" => [
                                        {   "layout" => "json",
                                            "items"  => [
                                                {   "selector_class" =>
                                                        "sequence_selector",
                                                    "options" => [
                                                        "Protein",
                                                        "DNA coding sequence",
                                                        "Genomic DNA"
                                                    ],
                                                    "action_link" => [
                                                        {   "caption" =>
                                                                "Get Fasta",
                                                            "url" =>
                                                                "\/db\/cgi-bin\/dictyBaseDP\/yui\/get_fasta.pl?decor=1&primary_id=DPU0068769",
                                                            "type" => "outer"
                                                        },
                                                        {   "caption" =>
                                                                "BLAST",
                                                            "url" =>
                                                                "\/purpureum\/gene\/DPU_G0068768\/blast?&primary_id=DPU0068769",
                                                            "type" => "tab"
                                                        }
                                                    ],
                                                    "type" => "selector"
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
