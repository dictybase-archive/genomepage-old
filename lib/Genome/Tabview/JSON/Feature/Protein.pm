
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
use Carp;
use Moose;
extends 'Genome::Tabview::JSON::Feature';

=head2 length

 Title    : length
 Function : returns json formatted protein length 
 Returns  : hash  
 Args     : none
 
=cut

has 'length' => (
    is   => 'ro',
    isa  => 'Str',
    lazy => 1,
    sub {
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

sub molecular_weight {
    my ($self)  = @_;
    my $feature = $self->source_feature;
    my $weight  = dicty::MiscUtility::commify(
        $feature->protein_info->molecular_weight );
    return $self->json->text( $weight . ' Da' );
}

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
    $base_url ||= '';
    my $link = $self->json->link(
        -caption => 'Protein sequence, domains and much more...',
        -url     => $base_url . '/'
            . $feature->gene->primary_id
            . "/protein/"
            . $feature->primary_id,
        -type => 'tab',
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
        -caption => 'View Amino Acid Composition',
        -url     => "/db/cgi-bin/amino_acid_comp.pl?primary_id="
            . $feature->primary_id,
        -type => 'outer',
    );
    return $link;
}

=head2 sequence_processing

 Title    : sequence_processing
 Function : returns json formatted sequence processing data
 Returns  : hash  
 Args     : none
 
=cut

sub sequence_processing {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->polypeptide->properties->{'Sequence Processing'};
    return $self->json->text(
        $feature->polypeptide->properties->{'Sequence Processing'} );
}

=head2 protein_existence

 Title    : protein_existence
 Function : returns json formatted protein existence data
 Returns  : hash  
 Args     : none
 
=cut

sub protein_existence {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->polypeptide->properties->{'Evidence'};
    return $self->json->text(
        $feature->polypeptide->properties->{'Evidence'} );
}

=head2 subunit_structure

 Title    : subunit_structure
 Function : returns json formatted subunit structure data
 Returns  : hash  
 Args     : none
 
=cut

sub subunit_structure {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->polypeptide->properties->{'Subunit Structure'};
    return $self->json->text(
        $feature->polypeptide->properties->{'Subunit Structure'} );
}

=head2 subcellular_location

 Title    : subcellular_location
 Function : returns json formatted subcellular location data
 Returns  : hash  
 Args     : none
 
=cut

sub subcellular_location {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->polypeptide->properties->{'Subcellular Location'};
    return $self->json->text(
        $feature->polypeptide->properties->{'Subcellular Location'} );
}

=head2 post_modification

 Title    : post_modification
 Function : returns json formatted post-translational modification data
 Returns  : hash  
 Args     : none
 
=cut

sub post_modification {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->polypeptide->properties->{'PTM'};
    return $self->json->text( $feature->polypeptide->properties->{'PTM'} );
}

=head2 cofactor

 Title    : cofactor
 Function : returns json formatted cofactor data
 Returns  : hash  
 Args     : none
 
=cut

sub cofactor {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->polypeptide->properties->{'Cofactor'};
    return $self->json->text(
        $feature->polypeptide->properties->{'Cofactor'} );
}

=head2 domain

 Title    : domain
 Function : returns json formatted domain data
 Returns  : hash  
 Args     : none
 
=cut

sub domain {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->polypeptide->properties->{'Domain'};
    return $self->json->text( $feature->polypeptide->properties->{'Domain'} );
}

=head2 catalityc_activity

 Title    : catalityc_activity
 Function : returns json formatted catalityc activity data
 Returns  : hash  
 Args     : none
 
=cut

sub catalityc_activity {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->polypeptide->properties->{'Catalityc Activity'};
    return $self->json->text(
        $feature->polypeptide->properties->{'Catalityc Activity'} );
}

=head2 domains_image

 Title    : domains_image
 Function : returns a formatted link to gbrowse domain display for the protein
 Returns  : hash  
 Args     : none
 
=cut

sub domains_image {
    my ($self)  = @_;
    my $feature = $self->source_feature;
    my $name    = $feature->polypeptide->primary_id;
    my $species = $feature->organism->species;
    my $embed
        = "/db/cgi-bin/ggb/gbrowse_img/$species\_protein?name=$name&width=575&keystyle=left&abs=1&grid=0&embed=1";

    my $domains_gbrowse = $self->json->link(
        -url  => $embed,
        -type => 'gbrowse_domain',
    );
    return $domains_gbrowse;
}

=head2 domains_table_link

 Title    : domains_table_link
 Function : returns a formatted link to gbrowse domain display for the protein
 Returns  : hash  
 Args     : none
 
=cut

sub domains_table_link {
    my ($self) = @_;
    my $feature = $self->source_feature;

    my $domains_table = $self->json->link(
        -caption => 'Table view',
        -url     => '/db/cgi-bin/'
            . $config->value('SITE_NAME')
            . '/service/polypeptide_domains.pl?ref='
            . $feature->polypeptide->primary_id,
        -type => 'outer',
    );

    return $domains_table;
}

=head2 sequence

 Title    : sequence
 Function : Returns json formatted protein sequence
 Returns  : hash  
 Args     : none
 
=cut

sub sequence {
    my ($self)  = @_;
    my $feature = $self->source_feature();
    my $fasta   = CGI->pre(
        $feature->sequence( -type => 'Protein', -format => 'fasta' ) );
    return $self->json->text($fasta);
}

=head2 external_links

 Title    : external_links
 Function : Returns json formatted external links array for the feature
 Returns  : array  
 Args     : none
 
=cut

sub external_links {
    my ($self)           = @_;
    my $feature          = $self->source_feature();
    my $external_id_hash = $feature->external_ids();

    return if !( keys %$external_id_hash );

    my @links;
    foreach my $key ( keys %$external_id_hash ) {
        next if $key !~ m{protein|uniprot|swissprot|trembl|ec}i;
        my $link = $self->external_link(
            -source => $key,
            -ids    => [ $external_id_hash->{$key} ],
        );

        push @links, $link if $link;
    }
    return if !@links;
    return \@links;
}

=head2 primary_id

 Title    : primary_id
 Function : Returns json formatted primary_id
 Returns  : hash  
 Args     : none
 
=cut

sub primary_id {
    my ($self) = @_;
    my $feature = $self->source_feature();
    return $self->json->text( $feature->primary_id );
}

1;
