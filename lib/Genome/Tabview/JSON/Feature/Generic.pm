
=head1 NAME

B <Genome::Tabview::JSON::Feature::Generic> - Class for handling JSON representation of feature information

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::Feature::Generic> version 1.0.0

=head1 SYNOPSIS

    my $json_feature = Genome::Tabview::JSON::Feature::Generic->new( -primary_id => 'DDB0185055');
    my $curation_status =  = $json_feature->curation_status;
    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::Feature::Generic> is a proxy class that provides feature information 
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

package Genome::Tabview::JSON::Feature::Generic;

use strict;
use namespace::autoclean;
use Mouse;
use MouseX::Params::Validate;
use Carp;
use Genome::Tabview::Config::Panel::Item::JSON::Table;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::JSON::Feature::Protein;
use Genome::Tabview::JSON::Feature;
extends 'Genome::Tabview::JSON::Feature';

=head2 display_type

 Title    : display_type
 Function : returns a formatted display type for the feature
 Returns  : hash  
 Args     : none
 
=cut

has 'display_type' => (
    is      => 'ro',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my ($type) = map { $_->accession }
            grep { $_->db->name eq 'GFF_source' }
            $self->source_feature->secondary_dbxrefs;
        return $type;
    }
);

has '_exon_featureloc' => (
    isa     => 'DBIx::Class::ResultSet',
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $feat = $self->source_feature;
        return $feat->search_related(
            'feature_relationship_objects',
            { 'type.name' => 'part_of' },
            { join        => 'type' }
            )->search_related(
            'subject',
            { 'type_2.name' => 'exon' },
            { join          => 'type' }
            )->search_related( 'featureloc_features', {} );
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
            { 'type.name' => 'part_of' },
            { join        => 'type' }
            )->search_related(
            'object',
            { 'type_2.name' => 'gene' },
            { join          => 'type', prefetch => 'dbxref' }
            );
        my $row = $rs->first;
        return $row;
    }
);

=head2 protein

 Title    : protein
 Function : returns protein feature for Genome::Tabview::JSON::Feature::Generic features with
            dicty::Feature::mRNA source feature
 Usage    : $protein = $feature->protein;
 Returns  : Genome::Tabview::JSON::Feature::Protein
 Args     : none
 
=cut

has 'protein' => (
    is      => 'rw',
    isa     => 'Genome::Tabview::JSON::Feature::Protein',
    lazy    => 1,
    default => sub {
        my ($self)          = @_;
        my $feat            = $self->source_feature;
        my $polypeptide_row = $feat->search_related(
            'feature_relationship_objects',
            { 'type.name' => 'derives_from' },
            { join        => 'type' }
            )->search_related(
            'subject',
            { 'type_2.name' => 'polypeptide' },
            { join          => 'type', 'rows' => 1 }
            )->single;
        return Genome::Tabview::JSON::Feature::Protein->new(
            source_feature => $polypeptide_row,
            context        => $self->context
        );
    }
);

has 'gene_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $feat = $self->gene;
        return $self->context->url_for(
            $self->context->gene_url . '/' . $feat->dbxref->accession )
            ->to_string;
    }
);

has 'protein_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $feat = $self->protein->source_feature;
        return $self->context->url_for( $self->context->gene_url . '/'
                . $self->gene->dbxref->accession
                . '/protein/'
                . $feat->dbxref->accession )->to_string;
    }
);

has 'source_feature_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->context->url_for( $self->gene_url
                . '/feature/'
                . $self->source_feature->dbxref->accession )->to_string;
    }
);

=head2 gene_type

 Title    : gene_type
 Function : returns json gene type, that is "Protein Coding Gene" for mRNA features, 
            or feature display type for the rest.
 Usage    : my $status = $feature->gene_type;
 Returns  : hash
 Args     : none
 
=cut

sub gene_type {
    my ($self) = @_;
    my $feature = $self->source_feature;
    my $type
        = $feature->type->name =~ m{mRNA}ix
        ? 'Protein Coding Gene'
        : $feature->type->name;
    return $self->json->text($type);
}

=head2 feature_tab_link

 Title    : feature_tab_link
 Function : returns feature tab link 
 Usage    : my $link = $feature->feature_tab_link;
 Returns  : hash
 Args     : caption for the link (optional)
 
=cut

sub feature_tab_link {
    my $self = shift;
    my ( $caption, $base_url ) = validated_list(
        \@_,
        caption  => { isa => 'Str', optional => 1 },
        base_url => { isa => 'Str' }
    );
    my $primary_id = $self->source_feature->dbxref->accession;
    $caption = $caption || $primary_id;
    my $link = $self->json->link(
        caption => $caption,
        url     => $self->context->url_for(
                  $base_url . '/'
                . $self->gene->dbxref->accession
                . '/feature/'
                . $primary_id
            )->to_string,
        type => 'tab',
    );
    return $link;
}

sub genbank_link {
    my ( $self, $id ) = @_;
    my $link = $self->json->link(
        caption => $id,
        url     => 'http://www.ncbi.nlm.nih.gov/nuccore/' . $id,
        type    => 'outer',
    );
    return $link;

}

=head2 transcript

 Title    : transcript
 Function : returns true if feature has transcript
 Usage    : print $feature->transcript_length if $feature->transcript;
 Returns  : boolean
 Args     : none
 
=cut

sub transcript {
    my ($self) = @_;
    return if $self->source_feature->type->name =~ m{mRNA};
    return if $self->source_feature->type->name !~ m{RNA};
    return 1;
}

has 'is_protein_coding' => (
    is      => 'ro',
    isa     => 'Bool',
    default => sub {
        my ($self) = @_;
        return 1 if $self->source_feature->type->name eq 'mRNA';
        return 0;
    },
    lazy => 1
);

=head2 transcript_length

 Title    : transcript_length
 Function : returns transcript length for features with transcript
 Usage    : print $feature->transcript_length if $feature->transcript;
 Returns  : boolean
 Args     : none
 
=cut

sub transcript_length {
    my ($self) = @_;
    return if !$self->transcript;
    my $feature = $self->source_feature;
    return $self->json->text( $feature->seqlen . ' nt' );
    return 1;
}

=head2 pseudogene

 Title    : pseudogene
 Function : returns true if feature is pseudogene
 Usage    : my $length =  $feature->pseudogene_length if $feature->pseudogene;
 Returns  : boolean
 Args     : none
 
=cut

sub pseudogene {
    my ($self) = @_;
    return 1 if $self->source_feature->type->name =~ m{pseudogene}i;
}

=head2 pseudogene_length

 Title    : pseudogene_length
 Function : returns pseudogene length for pseudogene features
 Usage    : my $length = $feature->pseudogene_length if $feature->pseudogene;
 Returns  : hash
 Args     : none
 
=cut

sub pseudogene_length {
    my ($self) = @_;
    return if !$self->pseudogene;
    my $length = $self->source_feature->seqlen;
    return $self->json->text( $length . ' nt' );
    return 1;
}

=head2 accession_number

 Title    : accession_number
 Function : Returns json formatted accession number for the feature
 Returns  : hash  
 Args     : none
 
=cut

sub accession_number {
    my ($self)  = @_;
    my $feature = $self->source_feature();
    my $id      = $feature->external_ids->{'Accession Number'};
    return $self->json->text($id);
}

=head2 get_fasta_selection

 Title    : get_fasta_selection
 Function : returns json structure for sequence selection field tie with "Get Fasta" button
 Returns  : hash
 Args     : -caption : caption to display for the selector
            -base_url: URL to prepend for the link outs

=cut

sub get_fasta_selection {
    my $self = shift;
    my ( $caption, $base_url ) = validated_list(
        \@_,
        caption  => { isa => 'Str', optional => 1 },
        base_url => { isa => 'Str', optional => 1 }
    );

    $base_url ||= $self->base_url;
    my $feature   = $self->source_feature;
    my $sequences = $self->available_sequences;

    my $fasta_button = $self->json->link(
        caption => 'Get Fasta',
        type    => 'outer',
        url     => 'getfasta'
    );
    my $blast_button = $self->json->link(
        caption => 'BLAST',
        type    => 'tab',
        url     => $self->context->url_for(
                  $self->gene_url
                . '/blast?primary_id='
                . $feature->dbxref->accession
            )->to_string
    );

    my %params = (
        options     => $sequences,
        action_link => [ $fasta_button, $blast_button ],
        class       => 'sequence_selector',
    );
    $params{caption} = $caption if $caption;
    my $get_fasta = $self->json->selector(%params);
    return $get_fasta;
}

=head2 available_sequences

 Title    : available_sequences
 Function : returns available sequence types for gene
 Returns  : hash
 Args     : none

=cut

sub available_sequences {
    my ($self)  = @_;
    my $feature = $self->source_feature;
    my $type    = $feature->type->name;
    if ( $type eq 'mRNA' ) {
        return [
            [ 'Protein',             $self->protein_url . '.fasta' ],
            [ 'DNA coding sequence', $self->source_feature_url . '.fasta' ],
            [ 'Genomic',             $self->reference_feature_url . '.fasta' ]
        ];
    }
    return [
        [ 'Transcript', $self->source_feature_url . '.fasta' ],
        [ 'Genomic',    $self->reference_feature_url . '.fasta' ]
    ];
}

=head2 small_gbrowse_image

 Title    : small_gbrowse_image
 Function : returns a formatted link to gbrowse image for the feature
 Returns  : hash  
 Args     : none
 
=cut

sub small_gbrowse_image {
    my ($self)  = @_;
    my $feature = $self->source_feature;
    my $species = $feature->organism->common_name;
    my $track
        = $feature->type->name eq 'mRNA' ? 'Genemodel' : $feature->type->name;
    my $name     = $self->gbrowse_window($feature);
    my $base_url = $self->context->app->config->{gbrowse_url};
    my $image
        = "$base_url/gbrowse_img/$species?name=$name;width=150;type=$track;abs=1";

    my $link    = "$base_url/gbrowse/$species?name=$name";
    my $gbrowse = $self->json->link(
        caption => $image,
        url     => $link,
        type    => 'gbrowse',
    );
    return $gbrowse;
}

=head2 coordinate_table

 Title    : coordinate_table
 Function : Returns json formatted coordinate table for the feature
 Returns  : hash  
 Args     : none
 
=cut

sub coordinate_table {
    my ($self) = @_;
    my $feature = $self->source_feature();

    my $table = Genome::Tabview::Config::Panel::Item::JSON::Table->new();
    $table->add_column(
        key      => 'name',
        label    => 'Exon',
        sortable => 'true'
    );
    $table->add_column(
        key      => 'local',
        label    => 'Local coords.',
        sortable => 'true'
    );
    $table->add_column(
        key      => 'chrom',
        label    => 'Chrom. coords.',
        sortable => 'true'
    );

    my $floc   = $feature->featureloc_features->first;
    my $strand = $floc->strand eq '1';
    my $start  = $floc->fmin + 1;
    my $end    = $floc->fmax;
    my $offset = $strand == 1 ? $start : $end;

    my $exonfloc_rs = $self->_exon_featureloc;
    my @exon_parts
        = $strand == 1
        ? sort { $a->fmin <=> $b->fmin } $exonfloc_rs->all
        : sort { $b->fmin <=> $a->fmin } $exonfloc_rs->all;

    my $exoncount = 1;
    foreach my $part (@exon_parts) {
        my $start = $strand == 1 ? $part->fmin + 1 : $part->fmax;
        my $end   = $strand == 1 ? $part->fmax     : $part->fmin + 1;
        my $rel_start = abs( $offset - $start ) + 1;
        my $rel_end   = abs( $offset - $end ) + 1;

        my $data = {
            name  => [ $self->json->text( $exoncount++ ) ],
            local => [ $self->json->text( $rel_start . ' - ' . $rel_end ) ],
            chrom => [ $self->json->text( $start . ' - ' . $end ) ],
        };
        $table->add_record($data);
    }
    return $table->structure;
}

=head2 derived_from

 Title    : derived_from
 Function : returns json formatted derived_from data for the feature
 Returns  : hash  
 Args     : none
 
=cut

sub derived_from {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !@{ $feature->derived_from() };
    return $self->json->text( join( ", ", @{ $feature->derived_from() } ) );
}

1;
