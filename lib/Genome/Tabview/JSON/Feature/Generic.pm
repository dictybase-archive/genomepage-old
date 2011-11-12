
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
use Moose;
use Carp;
use Genome::Tabview::Config::Panel::Item::JSON::Table;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::JSON::Feature::Protein;
use Genome::Tabview::JSON::Feature;
extends 'Genome::Tabview::JSON::Feature';

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
    my $type =
        $feature->type->name =~ m{mRNA}ix
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
    my ( $self, @args ) = @_;
    my $feature = $self->source_feature;

    my $arglist = [qw/CAPTION BASE_URL/];
    my ( $caption, $base_url ) = $self->{root}->_rearrange( $arglist, @args );

    $base_url ||= '';
    $caption = $caption || $feature->primary_id;
    my $link = $self->json->link(
        -caption => $caption,
        -url     => $base_url . '/'
            . $feature->gene->primary_id
            . "/feature/"
            . $feature->primary_id,
        -type => 'tab',
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

=head2 protein

 Title    : protein
 Function : returns protein feature for Genome::Tabview::JSON::Feature::Generic features with
            dicty::Feature::mRNA source feature
 Usage    : $protein = $feature->protein;
 Returns  : Genome::Tabview::JSON::Feature::Protein
 Args     : none
 
=cut

sub protein {
    my ($self) = @_;
    return
        if $self->source_feature->type !~ m{mRNA|databank_entry|cDNA_clone};
    return Genome::Tabview::JSON::Feature::Protein->new(
        -primary_id => $self->source_feature->primary_id );
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
    return if $self->source_feature->type =~ m{mRNA};
    return if $self->source_feature->type !~ m{RNA};
    return 1;
}

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
    my $length  = dicty::MiscUtility::commify(
        length( $feature->sequence( -type => 'Spliced transcript' ) ) );
    return $self->json->text( $length . ' nt' );
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
    return if $self->source_feature->type !~ m{pseudogene}i;
    return 1;
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
    my $feature = $self->source_feature;
    my $length  = dicty::MiscUtility::commify(
        length( $feature->sequence( -type => 'Pseudogene' ) ) );
    return $self->json->text( $length . ' nt' );
    return 1;
}

=head2 display_type

 Title    : display_type
 Function : returns a formatted display type for the feature
 Returns  : hash  
 Args     : none
 
=cut

sub display_type {
    my ($self) = @_;
    my $feature = $self->source_feature;
    my $type = $feature->display_type || $feature->type;
    return $self->json->text($type);
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

=head2 external_links

 Title    : external_links
 Function : Returns json formatted external links array for the feature
 Returns  : array  
 Args     : none
 
=cut

sub external_links {
    my ($self)           = @_;
    my $feature          = $self->source_feature;
    my $external_id_hash = $feature->external_ids;

    return if !( keys %$external_id_hash );

    my @links;
    foreach my $key ( keys %$external_id_hash ) {
        my $link = $self->external_link(
            -source => $key,
            -ids    => [ $external_id_hash->{$key} ],
        );

        push @links, $link if $link;
    }
    return @links ? \@links : undef;
}

=head2 get_fasta_selection

 Title    : get_fasta_selection
 Function : returns json structure for sequence selection field tie with "Get Fasta" button
 Returns  : hash
 Args     : -caption : caption to display for the selector
            -base_url: URL to prepend for the link outs

=cut

sub get_fasta_selection {
    my ( $self, @args ) = @_;

    my $arglist = [qw/CAPTION BASE_URL/];
    my ( $caption, $base_url ) = $self->{root}->_rearrange( $arglist, @args );

    $base_url ||= '';
    my $feature      = $self->source_feature;
    my $sequences    = $self->available_sequences;
    my $fasta_button = $self->json->link(
        -caption => 'Get Fasta',
        -type    => 'outer',
        -url =>
            "/db/cgi-bin/$ENV{'SITE_NAME'}/yui/get_fasta.pl?decor=1&primary_id="
            . $feature->primary_id,
    );
    my $blast_button = $self->json->link(
        -caption => 'BLAST',
        -type    => 'tab',

        #-url     => "/tools/blast?&primary_id=" . $feature->primary_id,
        -url => $base_url . '/'
            . $feature->gene->primary_id
            . "/blast?&primary_id="
            . $feature->primary_id
    );
    my $get_fasta = $self->json->selector(
        -options     => $sequences,
        -action_link => [ $fasta_button, $blast_button ],
        -class       => 'sequence_selector',
        -caption     => $caption,
    );
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
    my $type    = $feature->type;
    my $sequences =
        $type =~ m{mRNA}i
        ? [ 'Protein', 'DNA coding sequence', 'Genomic DNA' ]
        : $type =~ m{Pseudo}i ? [ 'Pseudogene',         'Genomic' ]
        : $type =~ m{RNA}i    ? [ 'Spliced transcript', 'Genomic' ]
        :                       undef;
    if ( $type =~ m{cDNA_clone|databank_entry} ) {
        my @seqtypes = (
            'mRNA Sequence',
            'Protein',
            'DNA coding sequence',
            'Genomic DNA'
        );
        @seqtypes = grep {
                   exists $feature->cached_sequences->{ lc($_) }
                || exists $feature->cached_sequences->{$_}
        } @seqtypes;
        return \@seqtypes;
    }
    return $sequences;
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
    my $type    = $feature->type;
    my $source  = $feature->source;

    my $track =
        $type eq "mRNA" && $source eq "geneID reprediction" ? "Repredictions"
        : $type =~ m{[mRNA|pseudogene]}ix
        && $source eq "$ENV{'SITE_NAME'} Curator" ? $ENV{'SITE_NAME'}
        : $type eq "mRNA" && $source =~ m{JGI}ix ? "JGImodel"
        : $type eq "mRNA" && $source !~ m{curator}ix ? "Predictions"
        : $type =~ m{[^t]RNA}ix ? "ncRNA"
        :                         $type;

    my $name    = $self->gbrowse_window($feature);
    my $species = $feature->organism->species;
    my $image =
        "/db/cgi-bin/ggb/gbrowse_img/$species?name=${name}&width=250&type=${track}&keystyle=none&abs=1";

    my $link    = "/db/cgi-bin/ggb/gbrowse/$species?name=${name}";
    my $gbrowse = $self->json->link(
        -caption => $image,
        -url     => $link,
        -type    => 'gbrowse',
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
        -key      => 'name',
        -label    => 'Exon',
        -sortable => 'true'
    );
    $table->add_column(
        -key      => 'local',
        -label    => 'Local coords.',
        -sortable => 'true'
    );
    $table->add_column(
        -key      => 'chrom',
        -label    => 'Chrom. coords.',
        -sortable => 'true'
    );
    my $bioperl = $feature->bioperl;
    my @feature_parts =
        $feature->type =~ m{mRNA}i
        ? ( $bioperl->exons )
        : ( $bioperl->get_SeqFeatures() );

    @feature_parts = sort {
              $feature->strand eq '1'
            ? $a->start <=> $b->start
            : $b->start <=> $a->start
    } @feature_parts;
    my $exoncount = 0;
    foreach my $part (@feature_parts) {
        my $label = ++$exoncount;

        my $start = $feature->strand eq "1" ? $part->start() : $part->end();
        my $end   = $feature->strand eq "1" ? $part->end()   : $part->start();
        my $offset =
            $feature->strand eq "1" ? $feature->start() : $feature->end();
        my $rel_start = abs( $offset - $start ) + 1;
        my $rel_end   = abs( $offset - $end ) + 1;

        my $data = {
            name  => [ $self->json->text($label) ],
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

=head2 supported_by

 Title    : supported_by
 Function : returns json formatted supported_by data for the feature
 Returns  : hash  
 Args     : none
 
=cut

sub supported_by {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !@{ $feature->supported_by() };
    return $self->json->text( join( ", ", @{ $feature->supported_by() } ) );
}

1;
