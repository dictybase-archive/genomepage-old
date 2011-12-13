package GenomeREST::Plugin::Genome;

use strict;
use Mojo::Base -base;
use Mojo::Base 'Mojolicious::Plugin';
use GenomeREST::Organism;
use GenomeREST::Feature::Source;
use Data::Dump qw/pp/;

has '_genomes';
has 'feat2seqtype' => sub {
    return {
        'gene'        => 'nucleotide',
        'polypeptide' => 'protein',
        'mRNA'        => 'nucleotide',
        'contig'      => 'nucleotide',
        'supercontig' => 'nucleotide',
        'chromosome'  => 'nucleotide'
    };
};

sub register {
    my ( $self, $app ) = @_;
    if ( $app->can('modware') ) {
        $self->_genomes(
            $self->_genomes_from_db( $app->modware->handler, $app ) );
    }
    $app->helper(
        loaded_genomes => sub {
            my ($c) = @_;
            if ( !$self->_genomes ) {
                $self->_genomes(
                    $self->_genomes_from_db( $app->modware->handler, $app ) );
            }
            my $genomes = $self->_genomes;
            return @$genomes;
        }
    );

    $app->helper(
        infer_seq_from_genome => sub {
            my ( $c, $floc ) = @_;
            my $start = $floc->first->fmin;
            my $end   = $floc->first->fmax;

            my $seqrow = $floc->search_related(
                'srcfeature',
                {},
                {   select =>
                        [ \"SUBSTR(srcfeature.residues, $start, $end )" ],
                    as => 'fseq'
                }
            );
            return $seqrow->first->get_column('fseq');
        }
    );

    $app->helper(
        feature_source => sub {
            my ( $c, $feature ) = @_;
            my ($dbxref)
                = grep { $_->db->name eq 'GFF_source' }
                $feature->secondary_dbxrefs;
            if ($dbxref) {
                my $name   = $dbxref->accession;
                my $schema = $feature->result_source->schema;
                my $dbrow  = $schema->resultset('General::Db')
                    ->find( { name => 'DB:' . $name } );
                if ($dbrow) {
                    return GenomeREST::Feature::Source->new(
                        name       => $name,
                        url        => $dbrow->urlprefix,
                        feature_id => $feature->uniquename
                    );
                }
                else {
                    my $hash    = $self->feat2seqtype;
                    my $seqtype = $hash->{ $feature->type->name };
                    $dbrow
                        = $schema->resultset('General::Db')
                        ->find(
                        { 'name' => 'DB:' . $name . ':' . $seqtype } );
                    return GenomeREST::Feature::Source->new(
                        name       => $name,
                        url        => $dbrow->urlprefix,
                        feature_id => $feature->uniquename
                    ) if $dbrow;
                }
            }
        }
    );
}

sub _genomes_from_db {
    my ( $self, $model, $app ) = @_;

    my $common_name2org;
    my $rs = $model->resultset('Organism::Organism')->search(
        {   'type.name' => 'loaded_genome',
            'cv.name'   => 'genome_properties'
        },
        { join => [ { 'organismprops' => { 'type' => 'cv' } } ], }
    );

    while ( my $row = $rs->next ) {
        if ( not exists $common_name2org->{ $row->common_name } ) {
            $common_name2org->{ $row->common_name }
                = GenomeREST::Organism->new(
                common_name => $row->common_name,
                species     => $row->species,
                genus       => $row->genus
                );
        }
    }
    $common_name2org->{discoideum} = GenomeREST::Organism->new(
        common_name => 'discoideum',
        species     => 'discoideum',
        genus       => 'Dictyostelium'
    ) if not exists $common_name2org->{discoideum};

    return [ values %$common_name2org ];
}
1;
