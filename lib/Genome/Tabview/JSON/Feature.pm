
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

use strict;
use Bio::Root::Root;
use dicty::Feature;
use dicty::Link;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::JSON::Reference;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::JSON::Feature> object. 
 Usage    : my $page = Genome::Tabview::JSON::Feature->new( -primary_id => 'DDB0185055' );
 Returns  : Genome::Tabview::JSON::Feature object with default configuration.     
 Args     : -primary_id   - feature primary id.
 
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/PRIMARY_ID/];
    $self->{root} = Bio::Root::Root->new();
    my ($primary_id) = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;
    my $feature = dicty::Feature->new( -primary_id => $primary_id );
    $self->source_feature($feature);
    return $self;
}

=head2 json

 Title    : json
 Usage    : $feature->json->link(....);
 Function : gets/sets json handler. Uses Genome::Tabview::Config::Panel::Item::JSON as default one
 Returns  : nothing
 Args     : JSON handler

=cut

sub json {
    my ( $self, $arg ) = @_;
    $self->{json} = $arg if $arg;
    $self->{json} = Genome::Tabview::Config::Panel::Item::JSON->new()
        if !$self->{json};
    return $self->{json};
}

sub context {
    my ( $self, $arg ) = @_;
    $self->{context} = $arg if defined $arg;
    return $self->{context} if defined $self->{context};
}

=head2 source_feature

 Title    : source_feature
 Usage    : $feature->source_feature($feature);
 Function : gets/sets feature, that would be used as a source for all calls
 Returns  : dicty::Feature object
 Args     : dicty::Feature object

=cut

sub source_feature {
    my ( $self, $arg ) = @_;
    $self->{source_feature} = $arg if defined $arg;
    $self->{root}->throw('Feature is not defined')
        if not defined $self->{source_feature};
    $self->{root}->throw('Feature should be dicty::Feature')
        if ref( $self->{source_feature} ) !~ m{dicty::Feature}x;
    return $self->{source_feature};
}

=head2 alert

 Title    : alert
 Function : returns alert for features on chromosome 2 repeat
 Usage    : my $alert = $feature->alert();
 Returns  : hash
 Args     : none
 
=cut

sub alert {
    my ($self) = @_;

    return $self->{alert} if $self->{alert};

    my $json      = $self->json;
    my $feature   = $self->source_feature;
    my $reference = $feature->reference_feature;

    return if !$reference;
    return
        if $ENV{'SITE_NAME'} ne 'dictyBase'
            || $reference->type ne 'chromosome'
            || $reference->name ne '2';
    my $first_repeat =
        'Note that there is a second copy of this gene in the genome. The region on Chromosome 2 from bases 2249563 to 3002134 is repeated between bases 3002337 and 3755085 in strains AX3 and AX4 (but not AX2).';
    my $second_repeat =
        'Note that there are two copies of this gene in the genome. The region on Chromosome 2 from bases 2249563 to 3002134 is repeated between bases 3002337 and 3755085 in strains AX3 and AX4 (but not AX2). This gene is on the second repeat of the duplication.';

    my $alert =
          $feature->start > 2263132 && $feature->end < 3015703
        ? $json->text( '<b>' . $first_repeat . '</b>' )
        : $feature->start > 3016083 && $feature->end < 3768654
        ? $json->text( '<b>' . $second_repeat . '</b>' )
        : undef;
    $self->{alert} = $alert;
    return $alert;
}

=head2 location

 Title    : location
 Function : returns json formatted location notes of a feature 
 Usage    : my $location = $feature->location();
 Returns  : hash
 Args     : none

=cut

sub location {
    my ($self) = @_;
    my $feature = $self->source_feature;
    my $strand   = $feature->strand eq '1' ? 'Watson' : 'Crick';
    my $start    = $feature->start();
    my $end      = $feature->end();
    my $ref_feat = $feature->reference_feature()->name();
    my $ref_type = $feature->reference_feature()->display_type();

    my $str =
        "$ref_type <b>$ref_feat</b> coordinates <b>$start</b> to <b>$end</b>, <b>$strand</b> strand";

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
    return $self->json->text( $self->source_feature->primary_id );
}

=head2 description

 Title    : description
 Function : returns json formatted description for the feature
 Usage    : my $description = $feature->description(); 
 Returns  : hash  
 Args     : none
 
=cut

sub description {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->description;
    return $self->json->format_url( $feature->description );
}

=head2 external_link

 Title    : external_link
 Function : returns external_link for the provided id and type
 Usage    : my $link = $feature->external_link(
                -source => 'UniProt',
                -ids    => [ 'O77203' ]
            );
 Returns  : hash with json representetion of a link
 Args     : -source : source of the link
            -ids    : reference to an array of external ids
            -type   : type of the link to be created ('tab'/'outer'). 
                      If not defined, 'outer' will be used as a default value;
=cut

sub external_link {
    my ( $self, @args ) = @_;
    my $json = $self->json;

    my $arglist = [qw/SOURCE IDS TYPE/];
    my ( $source, $ids, $type ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('source not provided')  if !$source;
    $self->{root}->throw('ids are not provided') if !$ids;
    $type = 'outer' if !$type;

    return $json->link(
        -url => $self->link('Entrez Nucleotide Multiple Entries')
            ->get_links( join( ',', @$ids ) ),
        -caption => 'Entrez Nucleotide',
        -type    => $type
    ) if $source eq 'GI Number';

    return $json->link(
        -url => $self->link('Entrez Protein Multiple Entries')
            ->get_links( join( ',', @$ids ) ),
        -caption => 'Entrez Protein',
        -type    => $type,
    ) if $source eq 'Protein GI Number' && @$ids > 1;

    return $json->link(
        -url => $self->link('GenBank Protein')
            ->get_links( join( ',', @$ids ) ),
        -caption => 'GenBank Protein',
        -type    => $type
    ) if $source eq 'Protein Accession Number';

    return $json->link(
        -url     => $self->link('ENA')->get_links( join( ',', @$ids ) ),
        -caption => 'ENA',
        -type    => $type,
    ) if $source eq 'ENA';

    return $json->link(
        -url => $self->link('UniProt')
            ->get_links( '?query=' . join( '+or+', @$ids ) ),
        -caption => 'UniProtKB: ' . join( '&nbsp;|&nbsp;', @$ids ),
        -type    => $type,
        )
        if ( $source eq 'UniProt'
        or $source eq 'Swissprot'
        or $source eq 'TrEMBL' );

    return $json->link(
        -url => $self->link('UniProt')
            ->get_links( '?query=' . join( '+or+', @$ids ) ),
        -caption => join( '&nbsp;|&nbsp;', @$ids ),
        -type    => $type,
    ) if $source eq 'UniProtKB';

    return $json->link(
        -url     => $self->link('EC Number')->get_links( join( ',', @$ids ) ),
        -caption => 'EC: ' . join( ', ',                            @$ids ),
        -type    => $type,

    ) if $source eq 'EC Number';

    return $json->link(
        -url     => $self->link('STKE')->get_links( join( ',', @$ids ) ),
        -caption => 'STKE',
        -type    => $type,
    ) if $source eq 'STKE';

    return $json->link(
        -url =>
            $self->link('RefSeq:Protein')->get_links( join( ',', @$ids ) ),
        -caption => 'RefSeq Protein',
        -type    => $type,
    ) if $source eq 'refseq:protein';

    return $json->link(
        -url     => $self->link($source)->get_links( join( ',', @$ids ) ),
        -caption => 'Inparanoid',
        -type    => $type,
    ) if $source eq 'Inparanoid v.7.0';

    return $json->link(
        -url     => $self->link('Kinase')->get_links( join( ',', @$ids ) ),
        -caption => 'Kinase.com',
        -type    => $type,
    ) if $source eq 'Kinase';

    return $json->link(
        -url     => $self->link('GeneDB')->get_links( join( ',', @$ids ) ),
        -caption => 'GeneDB',
        -type    => $type,
    ) if $source eq 'GeneDB';

    return $json->link(
        -url => $self->link('dictyExpress')->get_links( join( ',', @$ids ) ),
        -caption => 'dictyExpress (microarray)',
        -type    => $type
    ) if $source eq 'dictyExpress';

    return $json->link(
        -url => $self->link('dictyExpress RNAseq')
            ->get_links( join( ',', @$ids ) ),
        -caption => 'dictyExpress (RNA-Seq)',
        -type    => $type
    ) if $source eq 'dictyExpress RNAseq';

    return $json->link(
        -url     => $self->link('JGI_DPUR')->get_links( join( ',', @$ids ) ),
        -caption => 'JGI: ' . join( '&nbsp;|&nbsp;',               @$ids ),
        -type    => $type
    ) if $source eq 'JGI_DPUR';

    return $json->link(
        -url =>
            $self->link('EnsemblProtists')->get_links( join( ',', @$ids ) ),
        -caption => 'Ensembl',
        -type    => $type
    ) if $source eq 'EnsemblProtists';

    return;
}

=head2 link

 Title    : link
 Function : returns link object for provided source
 Returns  : dicty::Link
 Usage    : $self->link('UniProt')->get_links('O77203')
 Args     : string

=cut

sub link {
    my ( $self, $source ) = @_;
    $self->throw('source not provided') if !$source;
    return dicty::Link->new( -SOURCE => $source );
}

=head2 gbrowse_window

 Title    : gbrowse_window
 Function : returns gbrowse window start and end for the feature
 Returns  : string
 Args     : dicty::Feature object

=cut

sub gbrowse_window {
    my ( $self, $feature ) = @_;
    my $length = $feature->end() - $feature->start;

    my $window_ext = int( $length / 10 );
    $window_ext = $window_ext > 1000 ? 1000 : $window_ext;

    my $start = $feature->start - $window_ext;
    my $end   = $feature->end + $window_ext;
    my $chrom = $feature->reference_feature->name();

    my $name = "$chrom:$start..$end";
    return $name;
}

=head2 gene

 Title    : gene
 Function : returns gene for the feature
 Returns  : Genome::Tabview::JSON::Gene
 Args     : none

=cut

sub gene {
    my ($self) = @_;
    my $feature = $self->source_feature;
    return if !$feature->gene;
    return $self->{gene} if $self->{gene};

    my $gene = Genome::Tabview::JSON::Feature::Gene->new(
        -primary_id => $feature->gene->primary_id );
    $self->{gene} = $gene;
    return $self->{gene};
}

=head2 references

 Title    : references
 Function : returns gene references
 Usage    : @references = @{$gene->references()};
 Returns  : reference to an array of Genome::Tabview::JSON::Reference objects
 Args     : none
 
=cut

sub references {
    my ($self) = @_;

    return if !$self->source_feature->references;
    return $self->{references} if $self->{references};
    my $references;
    foreach my $reference ( sort { $b->year <=> $a->year }
        @{ $self->source_feature->references } ) {
        my $json_reference = Genome::Tabview::JSON::Reference->new(
            -pub_id => $reference->pub_id );
        $json_reference->context( $self->context ) if $self->context;
        push @$references, $json_reference;
    }
    $self->{references} = $references;
    return $self->{references};
}


1;
