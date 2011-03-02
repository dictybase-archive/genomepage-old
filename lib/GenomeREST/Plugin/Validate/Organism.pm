package GenomeREST::Plugin::Validate::Organism;

use strict;
use base qw/Mojolicious::Plugin/;

sub register {
    my ( $self, $app ) = @_;
    $app->helper(
        check_organism => sub {
            my ( $c, $name ) = @_;
            my $model = $app->modware->handler;

            my ($organism) = $model->resultset('Organism::Organism')->search(
                {   -or => [
                        { common_name  => $name },
                        { abbreviation => $name },
                        { species      => $name },
                    ]
                }
            );
            return if !$organism;

            $c->stash(
                species      => $organism->species,
                abbreviation => $organism->abbreviation,
                genus        => $organism->genus,
                common_name  => $organism->common_name,
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

    
