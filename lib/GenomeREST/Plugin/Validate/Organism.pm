package GenomeREST::Plugin::Validate::Organism;

use strict;
use base qw/Mojolicious::Plugin/;
use Data::Dumper;

sub register {
    my ( $self, $app ) = @_;
    $app->helper(
        check_organism => sub {
            my ( $c, $species ) = @_;
            my $model        = $app->modware->handler;
            my $phylonode_rs = $model->resultset('Phylogeny::Phylonode');

            my $nodes_rs = $phylonode_rs->search(
                {   'label'     => { 'like', '%' . $species },
                    'type.name' => 'species'
                },
                { 'join' => 'type' }
            );

            if ( $nodes_rs->count > 1 ) {
                $c->app->log->warn(
                    "more than one species matching $species found in database"
                );
                return 0;
            }

            my $taxon    = $nodes_rs->single;
            my $genus    = $taxon->search_related('parent_phylonode')->single->label;
            my $child_rs = $phylonode_rs->search(
                {   left_idx => {
                        -between => [ $taxon->left_idx, $taxon->right_idx ]
                    }
                }
            );

            my $organism_rs = $child_rs->related_resultset('phylonode_organism')->related_resultset('organism');

            if ( !$organism_rs->count ) {
                $c->app->log->warn(
                    "no organism matching $species found in database");
                return 0;
            }

            $c->stash(
                organism_rs  => $organism_rs,
                genus        => $genus,
                abbreviation => substr( $genus, 0, 1 ) . '.' . $species,
            );

            1;
        }
    );
}

1;

=head1 NAME

GenomeRest::Plugin::Validate::Organism - organism name validation plugin

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

## in application
plugin "GenomeREST::Plugin::Validate::Organism"

## in controller
my $name       = $self->stash('name');
if ( !$self->check_organism($name) ) {
    $self->render(
        template => 'missing',
        message  => "organism $name not found",
        error    => 1,
        header   => 'Error page',
        title    => 'Error not found',
    );
    return;
}

## in template
Welcome to the <i><%= $genus %> <%= $species %></i> web portal!

=head1 DESCRIPTION

provides check_organism method for organism valdation. Checks if there is a match for provided 
name in CHADO Organism table (checks speces, abbreviation, genus and common_name fields)
returns true if finds matching recors and populates controller stash with speces, abbreviation, 
genus and common_name values. 

=head1 AUTHOR

I<Yulia Bushmanova> B<y-bushmanova@northwestern.edu>

    
