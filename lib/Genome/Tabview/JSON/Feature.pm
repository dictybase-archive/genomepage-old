
=head1 NAME

    B <Genome::Tabview::JSON::Feature> - Class for handling JSON structure conversion for 
    dicty::Feature implementing objects

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::Feature> version 1.0.0

=head1 SYNOPSIS

    my $json_feature = Genome::Tabview::JSON::Feature->new( -primary_id => 'DDB0185055');
    my $curation_status =  = $json_feature->curation_status;
    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::Feature> is a proxy class that provides feature information 
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

package Genome::Tabview::JSON::Feature;

use namespace::autoclean;
use Moose;
use MooseX::Params::Validate;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::JSON::Reference;

=head2 json

 Title    : json
 Usage    : $feature->json->link(....);
 Function : gets/sets json handler. Uses Genome::Tabview::Config::Panel::Item::JSON as default one
 Returns  : nothing
 Args     : JSON handler

=cut

has 'json' => (
    is      => 'rw',
    isa     => 'Genome::Tabview::Config::Panel::Item::JSON',
    lazy    => 1,
    default => sub {
        Genome::Tabview::Config::Panel::Item::JSON->new;
    }
);

has 'context' => ( is => 'rw', isa => 'Mojolicious::Controller' );

=head2 source_feature

 Title    : source_feature
 Usage    : $feature->source_feature($feature);
 Function : gets/sets feature, that would be used as a source for all calls
 Returns  : dicty::Feature object
 Args     : dicty::Feature object

=cut

has 'source_feature' => (
    is       => 'rw',
    isa      => 'DBIx::Class::Row',
    required => 1
);

=head2 location

 Title    : location
 Function : returns json formatted location notes of a feature 
 Usage    : my $location = $feature->location();
 Returns  : hash
 Args     : none

=cut

sub location {
    my ($self) = @_;
    my $floc = $self->source_feature->featureloc_features->first;
    my $strand = $floc->strand eq '1' ? 'Watson' : 'Crick';
    my $start  = $floc->fmin + 1;
    my $end    = $floc->fmax;

    my $ref_feat = $floc->srcfeature;
    my $str
        = $ref_feat->type . "<b>"
        . $ref_feat->name
        . "</b> coordinates <b>$start</b> to <b>$end</b>, <b>$strand</b> strand";

    return $self->json->text($str);
}

=head2 name

 Title    : name
 Function : returns json formatted feature name
 Usage    : my $name = $feature->name();
 Returns  : hash
 Args     : none
 
=cut

sub name {
    my ($self) = @_;
    return $self->json->text( '<i>' . $self->source_feature->name . '</i>' );
}

=head2 primary_id

 Title    : primary_id
 Function : returns json formatted primary id of a feature 
 Usage    : my $primary_id = $feature->primary_id(); 
 Returns  : hash
 Args     : none

=cut

sub primary_id {
    my ($self) = @_;
    return $self->json->text( $self->source_feature->dbxref->accession );
}

=head2 external_link

 Title    : external_link
 Function : returns external_link for the provided id and type
 Usage    : my $link = $feature->external_link(
                -source => 'UniProt',
                -id    => 'O77203' 
            );
 Returns  : hash with json representetion of a link
 Args     : source : source of the link
            ids    : reference to an array of external ids
            type   : type of the link to be created ('tab'/'outer'). 
                      If not defined, 'outer' will be used as a default value;
=cut

sub external_link {
    my ( $self, $source, $id, $type ) = validated_list(
        \@_,
        source => { isa => 'Str' },
        id     => { isa => 'Str' },
        type   => { isa => 'Str', optional => 1, default => 'outer' }
    );

    my $json = $self->json;
    return $json->link(
        url     => $self->link( 'Entrez Nucleotide Multiple Entries', $id ),
        caption => 'Entrez Nucleotide',
        type    => $type
    ) if $source eq 'GI Number';

    return $json->link(
        url     => $self->link( 'Entrez Protein Multiple Entries', $id ),
        caption => 'Entrez Protein',
        type    => $type,
    ) if $source eq 'Protein GI Number';

    return $json->link(
        url     => $self->link( 'GenBank Protein', $id ),
        caption => 'GenBank Protein',
        type    => $type
    ) if $source eq 'Protein Accession Number';

    return $json->link(
        url     => $self->link( 'ENA', $id ),
        caption => 'ENA',
        type    => $type,
    ) if $source eq 'ENA';

    return $json->link(
        url     => $self->link( 'UniProt', $id ),
        caption => "UniProtKB: $id",
        type    => $type,
        )
        if ( $source eq 'UniProt'
        or $source eq 'Swissprot'
        or $source eq 'TrEMBL'
        or $source eq 'UniProt' );

    return $json->link(
        url     => $self->link( 'EC Number', $id ),
        caption => "EC: $id",
        type    => $type,

    ) if $source eq 'EC Number';

    return $json->link(
        url     => $self->link( 'RefSeq:Protein', $id ),
        caption => 'RefSeq Protein',
        type    => $type,
    ) if $source eq 'refseq:protein';

    return $json->link(
        url     => $self->link( $source, $id ),
        caption => 'Inparanoid',
        type    => $type,
    ) if $source eq 'Inparanoid v.7.0';

    return $json->link(
        url     => $self->link( 'dictyExpress', $id ),
        caption => 'dictyExpress (microarray)',
        type    => $type
    ) if $source eq 'dictyExpress';

    return $json->link(
        url     => $self->link( 'dictyExpress RNAseq', $id ),
        caption => 'dictyExpress (RNA-Seq)',
        type    => $type
    ) if $source eq 'dictyExpress RNAseq';

    return $json->link(
        url     => $self->link( 'JGI_DPUR', $id ),
        caption => "JGI: $id",
        type    => $type
    ) if $source eq 'JGI_DPUR';

}

=head2 description

 Title    : description
 Function : returns json formatted description for the feature
 Usage    : my $description = $feature->description(); 
 Returns  : hash  
 Args     : none
 
=cut

#sub description {
#    my ($self) = @_;
#    my $feature = $self->source_feature;
#    return if !$feature->description;
#    return $self->json->format_url( $feature->description );
#}

sub link {
    my $self = shift;
    my ( $source, $id )
        = pos_validated_list( \@_, { isa => 'Str' }, { isa => 'Str' } );
    my $db
        = $self->model->resultset('General::Db')->find( { name => $source } );
    return $db->urlprefix . '/' . $id if $db;
}

=head2 gbrowse_window

 Title    : gbrowse_window
 Function : returns gbrowse window start and end for the feature
 Returns  : string
 Args     : dicty::Feature object

=cut

sub gbrowse_window {
    my ( $self, $feature ) = @_;
    my $floc   = $feature->featureloc_features->single;
    my $start  = $floc->fmin;
    my $end    = $floc->fmax;
    my $length = $end - $start;

    my $window_ext = int( $length / 10 );
    $window_ext = $window_ext > 1000 ? 1000 : $window_ext;

    my $start = $start - $window_ext;
    my $end   = $end + $window_ext;
    my $chrom = $floc->srcfeature->name;

    my $name = "$chrom:$start..$end";
    return $name;
}

=head2 gene

 Title    : gene
 Function : returns gene for the feature
 Returns  : Genome::Tabview::JSON::Gene
 Args     : none

=cut

=head2 references

 Title    : references
 Function : returns gene references
 Usage    : @references = @{$gene->references()};
 Returns  : reference to an array of Genome::Tabview::JSON::Reference objects
 Args     : none
 
=cut

has '_reference_stack' => (
    is       => 'rw',
    isa      => 'ArrayRef',
    traits   => [qw/Array/],
    lazy     => 1,
    _builder => '_build_references',
    handles  => { 'references' => 'elements' }
);

sub _build_references {
    my ($self) = @_;
    my $pub_rs = $self->source_feature->search_related( 'feature_pubs', {},
        { order_by => { -desc => 'pyear' } } );
    return if !$pub_rs->count;

    while ( my $row = $pub_rs->next ) {
        my $json_reference = Genome::Tabview::JSON::Reference->new(
            pub_id => $row->uniquename );
        $json_reference->context( $self->context ) if $self->context;
        push @$references, $json_reference;
    }
    return $references;
}

1;
