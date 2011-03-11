package GenomeREST::Controller::Genepage::Summary;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $json = [
        {
            "name" => "info",
            "source" => {
                "controller" => "genepage-summary",
                "action" => "info",
                "url" => "/purpureum/gene/DPU_G0068768/test/summary/info",
            },
            "label" => "General Information"      
        }    
    ];
    if ($self->stash('format') eq 'json'){
        $self->render_json($json);
        $self->rendered;
    };
    for ( my $i = 0; $i < @$json; $i++ ) {
        my $source = @$json->[$i]->{source};
        
#        @$json->[$i]->{content} = $self->render_partial( 
#            controller => $source->{controller}, 
#            action => $source->{action}
#        );

        @$json->[$i]->{content} = $self->client->get($source)->res->body;

#        $self->client->get( $self->req->url->base . $source->{url} => sub {
#            @$json->[$i]->{contentt} = shift->res->body;
#        })->start;
    }
    use Data::Dumper;
    $self->app->log->debug( Dumper $json );
    $self->stash( params => $json );
    $self->render('genepage/summary/index');
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
    if ($self->stash('format') eq 'json'){
        $self->render_json($json);
    }
}

1;
