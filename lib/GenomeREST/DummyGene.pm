package GenomeREST::DummyGene;

use strict;

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub has_blast   { 1; }
sub has_summary { 1; }
sub has_protein { 1; }

sub label_for_blast   { 'BLAST'; }
sub label_for_summary { 'Gene Summary'; }
sub label_for_protein { 'Protein Information'; }

1;
