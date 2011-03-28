package GenomeREST::Controller::Genepage;

use strict;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $id = $self->stash('gene_id');
    my $self_route = $self->stash('resource') || '/';
    my $resources  = $self->stash('resources');
    my $gene       = $self->gene;
    
    use Data::Dumper;
    $self->app->log->debug(Dumper $self->match);

    my %subs =
        map { $_ => $resources->{$_} }
        grep { $_ =~ m{^$self_route\w+$} }
        keys %$resources;
        
    my $params;
    foreach my $sub ( keys %subs ) {
        my $action = $subs{$sub}->{action};

        my $has   = 'has_' . $action;
        my $label = 'label_for_' . $action;

        next if !$gene->$has();

        my $param;
        $param->{name}   = $action;
        $param->{label}  = $gene->$label();
        $param->{source} = $self->base_url . $sub;

        push @$params, $param;    ## pam-pam
    }

#    my $json   = [
#        {   "name"   => "summary",
#            "source" => "/purpureum/gene/$id/summary",
#            "label"  => "Gene Summary",
#            "active" => "true"
#        },
#        {   "name"   => "protein",
#            "source" => "/purpureum/gene/$id/protein",
#            "label"  => "Protein Information",
#        },
#        {   "name" => "blast",
#            "content" =>
#                "<iframe style=\"height:750px;width:100%;\" src=\"/tools/blast?noheader=1&primary_id=$id\"></iframe>",
#            "label" => "BLAST"
#        }
#    ];
    $self->render_json($params) if $self->stash('format') eq 'json';
    $self->stash( params => $params );
}

1;

