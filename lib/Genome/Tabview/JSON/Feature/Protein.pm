
=head1 NAME

   B<Genome::Tabview::JSON::Feature::Protein> - Class for handling JSON representation of protein information

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::Feature::Protein> version 1.0.0

=head1 SYNOPSIS

    my $json_protein = Genome::Tabview::JSON::Feature::Protein->new( -primary_id => 'DDB0185055');
    my $molecular_weight = $json_protein->molecular_weight;
    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::Feature::Protein> is a proxy class that provides protein information 
    representation in a way suitable for furthure JSON convertion

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported. Please report any bugs or feature requests to B<dictybase@northwestern.edu>

=head1 TODO

=head1 AUTHOR

I<Yulia Bushmanova> B<y-bushmanova@northwestern.edu>
I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) B<2007>, Dictybase C<<dictybase@northwestern.edu>>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=head1 APPENDIX

   The rest of the documentation details each of the object
   methods. Internal methods are usually preceded with a _

=cut

package Genome::Tabview::JSON::Feature::Protein;

use strict;
use namespace::autoclean;
use Bio::Tools::SeqStats;
use Bio::PrimarySeq;
use Carp;
use Moose;
extends 'Genome::Tabview::JSON::Feature';

has 'transcript' => (
    isa     => 'DBIx::Class::Row',
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $rs = $self->source_feature->search_related(
            'feature_relationship_subjects',
            { 'type' => 'derived_from' },
            { join   => 'type' }
            )->search(
            'object',
            { 'type_2.name' => 'mRNA' },
            { join          => 'type', 'prefetch' => 'dbxref' }
            );
        return $rs->first;
    }
);

has 'gene' => (
    isa     => 'DBIx::Class::Row',
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $rs = $self->source_feature->search_related(
            'feature_relationship_subjects',
            { 'type.name' => 'derived_from' },
            { join   => 'type' }
            )->search_related(
            'object',
            { 'type_2.name' => 'mRNA' },
            { join          => 'type' }
            )->search_related(
            'feature_relationship_subjects',
            { 'type_3.name' => 'part_of' },
            { join          => 'type' }
            )->search_related(
            'object',
            { 'type_4.name' => 'gene' },
            { join         => 'type', prefetch => 'dbxref' }
            );
        return $rs->first;
    }
);

=head2 length

 Title    : length
 Function : returns json formatted protein length 
 Returns  : hash  
 Args     : none
 
=cut

has 'length' => (
    is   => 'ro',
    isa  => 'HashRef',
    lazy => 1,
    default => sub {
        my ($self) = @_;
        my $length = $self->source_feature->seqlen;
        return $self->json->text( $length . ' aa' );
    }
);

=head2 description

 Title    : description
 Function : returns json formatted protein molecular weight
 Returns  : hash  
 Args     : none
 
=cut

has 'molecular_weight' => (
    is   => 'ro',
    isa  => 'HashRef',
    lazy => 1,
    default => sub {
        my ($self)  = @_;
        my $feature = $self->source_feature;
        my $weight  = Bio::Tools::SeqStats->get_mol_wt(
            Bio::PrimarySeq->new(
                -seq      => $feature->residues,
                -alphabet => 'protein',
                -id       => $feature->uniquename
            )
        );
        return $self->json->text( $weight . ' Da' );
    }
);

=head2 protein_tab_link

 Title    : protein_tab_link
 Function : returns protein tab link 
 Usage    : my $link = $protein->protein_tab_link;
 Returns  : hash
 Args     : base_url - string to prepend protein tab url
 
=cut

sub protein_tab_link {
    my ( $self, $base_url ) = @_;
    my $feature = $self->source_feature;
    my $ctx     = $self->context;
    my $link    = $self->json->link(
        caption => 'Protein sequence, domains and much more...',
        url     => $ctx->url_to(
            $base_url, $self->gene->dbxref->accession,
            'protein', $feature->dbxref->accession
        ),
        type => 'tab',
    );
    return $link;
}

=head2 aa_composition

 Title    : aa_composition
 Function : returns json formatted aa_composition link
 Returns  : hash  
 Args     : none
 
=cut

sub aa_composition {
    my ($self)  = @_;
    my $feature = $self->source_feature;
    my $link    = $self->json->link(
        caption => 'View Amino Acid Composition',
        url     => $self->context->url_to(
            $self->base_url, $self->gene->dbxref->accession,
            'protein', $feature->dbxref->accession,
            'statistics'
        ),
        type => 'outer',
    );
    return $link;
}

=head2 protein_existence

 Title    : protein_existence
 Function : returns json formatted protein existence data
 Returns  : hash  
 Args     : none
 
=cut

=head2 sequence

 Title    : sequence
 Function : Returns json formatted protein sequence
 Returns  : hash  
 Args     : none
 
=cut

sub sequence {
    my ($self) = @_;
    my $feature = $self->source_feature();

    my $ref       = $self->reference_feature;
    my $ref_name  = $ref->name ? $ref->name : $ref->uniquename;
    my $ref_start = $ref->featureloc_features->first->fmin + 1;
    my $ref_end   = $ref->featureloc_features->first->fmax;

    my $transcript_id = $self->transcript->dbxref->accession;
    my $gene_id       = $self->gene->dbxref->accession;

    my $header = ">$transcript_id|$gene_id|Protein|gene: ";
    $header .= "on supercontig: $ref_name position $ref_start to $ref_end\n";
    my $seq = $self->source_feature->residues;
    $seq =~ s/(.{1, 60})/$1\n/g;
    return $self->json->text("$header\n$seq");
}


1;
