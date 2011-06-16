package GenomeREST::Plugin::Validate::Organism;

use strict;
use base qw/Mojolicious::Plugin/;
use Data::Dumper;
sub register {
    my ( $self, $app ) = @_;
    $app->helper(
        check_organism => sub {
            my ( $c, $species ) = @_;
            my $model = $app->modware->handler;

            my $organism_rs = $model->resultset('Organism::Organism')->search(
                {   -or => [
                        { common_name  => $species },
                        { abbreviation => $species },
                        { species => { 'like' , $species . '%' } },
                    ]
                }
            );

            if (!$organism_rs->count){
                $c->app->log->warn("no organism matching $species found in database");
                return 0;
            };
            
            my $genus_rs = $organism_rs->search(
                {},
                {   columns  => [qw/genus/],
                    group_by => [qw/genus/],
                }
            );            
            if ($genus_rs->count > 1){
                $c->app->log->warn("looks like $species belongs to different organisms (genuses)");
                return 0;                
            };
            my $genus = $genus_rs->single->genus;
            $c->stash(
                organism_rs  => $organism_rs,
                genus        => $genus,
                abbreviation => substr( $genus, 0, 1 ) . '.' . $species,
#                common_name  => $organism->common_name,
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

    
