package GenomeREST::Plugin::Genome;

use strict;
use Mojo::Base -base;
use Mojo::Base 'Mojolicious::Plugin';
use GenomeREST::Organism;

has '_genomes';

sub register {
    my ( $self, $app ) = @_;
    if ( $app->can('modware') ) {
        $self->_genomes( $self->_genomes_from_db( $app->modware->handler ) );
    }
    $app->helper(
        loaded_genomes => sub {
            my ($c) = @_;
            if ( !$self->_genomes ) {
                $self->_genomes(
                    $self->_genomes_from_db( $app->modware->handler ) );
            }
            return $self->_genomes;
        }
    );
}

sub _genomes_from_db {
    my ( $self, $model ) = @_;

    my %common_name2org;
    my $rs = $model->resultset('Organism::Organism')->search(
        {   'type.name' => 'loaded_genome',
            'cv.name'   => 'genome_properties'
        },
        { join => [ { 'organismprops' => { 'type' => 'cv' } } ], }
    );

    while ( my $row = $rs->next ) {
        if ( not exists $common_name2org{ $row->common_name } ) {
            $common_name2org{ $row->common_name } = GenomeREST::Organism->new(
                common_name => $row->common_name,
                species     => $row->species,
                genus       => $row->genus
            );
        }
    }
    return values %common_name2org;
}
1;
