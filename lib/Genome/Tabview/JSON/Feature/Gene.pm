
=head1 NAME

   B<Genome::Tabview::JSON::Feature::Gene> - Class for handling JSON representation of gene information

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::Feature::Gene> version 1.0.0

=head1 SYNOPSIS

    my $json_gene = Genome::Tabview::JSON::Feature::Gene->new( -primary_id => <GENE ID>);
    my $gene_name =  = json_gene->name;
    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::Feature::Gene> is a proxy class that provides gene information representation
    in a way suitable for furthure JSON convertion

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

package Genome::Tabview::JSON::Feature::Gene;

use strict;
use namespace::autoclean;
use Moose;
use Genome::Tabview::JSON::Feature::Generic;
extends 'Genome::Tabview::JSON::Feature';

=head2 wiki_links

 Title    : wiki_links
 Function : returns json formatted formatted gene wiki links
 Returns  : array
 Args     : none

=cut

sub wiki_links {
    my ($self)    = @_;
    my $gene      = $self->source_feature;
    my $gene_name = $gene->name;
    my $json      = $self->json;
    my $wiki_root = "http://wiki.dictybase.org/dictywiki/index.php/";
    my $wiki_links;

    my $count = $gene->search_related(
        'featureprops',
        {   'type.name' => 'wiki_annotation',
            'cv.name'   => 'annotation_properties'
        },
        { join => [ { 'type' => 'cv' } ] }
    )->count;

    if ($count) {
        my $view_link = $json->link(
            caption => "View annotation for $gene_name",
            url     => $wiki_root . $gene_name,
            type    => 'outer',
            style   => 'font-weight: bold; color: #CC0000',
        );
        push @$wiki_links, $view_link;
    }
    my $edit_link = $json->link(
        caption => "Add an annotation for $gene_name",
        url     => $wiki_root . $gene_name . "?action=edit",
        type    => 'outer'
    );
    my $help_link = $json->link(
        caption => "Community Annotations Help",
        url     => $wiki_root . "Community_Annotations",
        type    => 'outer',
    );
    push @$wiki_links, $edit_link, $help_link;
    return $wiki_links;
}

=head2 gene_products

 Title    : features
 Function : returns json formatted gene products
 Usage    : $gene_products = $gene->gene_products();
 Returns  : hash
 Args     : none
 
=cut

sub gene_products {
    my ($self)   = @_;
    my $gene     = $self->source_feature;
    my $trans_rs = $gene->search_related(
        'feature_relationship_objects',
        { 'type.name' => 'part_of', 'cv.name' => 'sequence' },
        { join        => [          { 'type'  => 'cv' } ] }
        )->search_related(
        'subject',
        { 'type_2.name' => 'mRNA' },
        { join          => 'type' }
        );
    return if !$trans_rs->count;

    my $product_rs = $trans_rs->search_related(
        'feature_relationship_objects',
        { 'type_3.name' => 'derived_from' },
        { join          => 'type' }
        )->search_related(
        'subject',
        { 'type_4.name' => 'polypeptide' },
        { join          => 'type' }
        )->search_related(
        'featureprops',
        {   'type_5.name' => 'product',
            'cv_2.name'   => 'feature_property'
        },
        { join => [ { 'type' => 'cv' } ] }
        );
    return if !$product_rs->count;

    #    my @gene_products_array = map {
    #        my $str = $_->product_name();
    #        $str .= " <font color='#CC0000'>(Automated)</font>"
    #            if $_->is_automated();
    #        $str;
    #    } @{ $gene->gene_products() };

    return $self->json->text( $product_rs->first->value );
}

=head2 features

 Title    : features
 Function : returns gene features
 Usage    : @features = @{$gene->features()};
 Returns  : reference to an array of Genome::Tabview::JSON::Feature::Generic objects
 Args     : none
 
=cut

has 'features' => (
    is         => 'ro',
    isa        => 'ArrayRef[DBIx::Class::Row]',
    lazy       => 1,
    auto_deref => 1,
    default    => sub {
        my ($self) = @_;
        return $self->transcripts;
    }
);

has 'transcripts' => (
    is         => 'ro',
    isa        => 'ArrayRef[Genome::Tabview::JSON::Feature]',
    lazy       => 1,
    auto_deref => 1,
    default    => sub {
        my ($self) = @_;
        my @rows = $self->source_feature->search_related(
            'feature_relation_objects',
            { 'type.name' => 'part_of' },
            { join        => 'type' }
        )->search_related( 'subject', {} )->all;
        return [
            map {
                Genome::Tabview::JSON::Feature::Generic->new(
                    source_feature => $_ )
                } @rows
        ];
    }
);

=head2 ests

 Title    : ests
 Function : returns json formatted gene ests links
 Returns  : hash
 Args     : none

=cut

sub ests {
    my ($self) = @_;

    my $gene  = $self->source_feature;
    my $start = $gene->featureloc_features->first->fmin;
    my $end   = $gene->featureloc_features->first->fmax;

    my $est_rs
        = $self->model->resultset('Sequence::Feature')
        ->search( { 'type.name' => 'EST' },
        { join => 'type', prefetch => 'dbxref' } )->search_related(
        'featureloc_features',
        {   fmin => { '<=', $end },
            fmax => { '>=', $start }
        }
        );
    my $count = $est_rs->count;
    return !$count;

    my $links;
    ## -- need to fix
    if ( $count == 6 ) {
        my $more_link = $self->json->link(
            caption => 'more..',
            url     => "/db/cgi-bin/more_est.pl?feature_id="
                . $gene->feature_id
                . "&gene_name="
                . $gene->name,
            type => 'outer',
        );
        push @$links, $more_link;
    }

    foreach my $est ( $est_rs->all ) {
        unshift @$links, $self->json->link(
            caption => $est->dbxref->accession,
            url     => $self->base_url . '/' . $est->dbxref->accession,
            type    => 'outer',
        );
    }
    return $links;
}

=head2 external_links

 Title    : external_links
 Function : returns json formatted gene external links 
 Returns  : hash
 Args     : none

=cut

sub external_links {
    my ($self) = @_;
    my $gene = $self->source_feature;

    ## -- get  transcript
    my $trans_rs = $gene->search_related(
        'feature_relationship_objects',
        { 'type.name' => 'part_of', },
        { join        => [ { 'type' => 'cv' } ] }
        )->search_related( 'subject',        {} )
        ->search_related( 'feature_dbxrefs', {} )
        ->search_related( 'dbxref', {}, { prefetch => 'db' } );
    return if !$trans_rs->count;

    my $external_links;
    foreach my $xref ( $trans_rs->all ) {
        push @$external_links,
            $self->external_link(
            source => $xref->db->name,
            id     => $xref->accession,
            );

  #        my $divider
  #            = ( scalar @external_links ) / 2 < scalar( keys(%linkage) ) - 1
  #            ? '&nbsp;|&nbsp;'
  #            : undef;
  #
  #        if (@link) {
  #            push @external_links, @link;
  #            push @external_links, $self->json->text($divider) if $divider;
  #        }
    }
    return $external_links;
}

=head2 gbrowse_link

 Title    : gbrowse_link
 Function : returns json formatted gbrowse link of a gene 
 Returns  : hash
 Args     : none

=cut

sub gbrowse_link {
    my ($self)  = @_;
    my $feature = $self->source_feature;
    my $json    = $self->json;

    my $name         = $self->gbrowse_window($feature);
    my $track        = "Gene+Gene_Model+tRNA+ncRNA";
    my $species      = $feature->organism->species;
    my $gbrowse_link = $json->link(
        caption =>
            "/db/cgi-bin/ggb/gbrowse_img/$species?name=${name}&width=500&type=${track}&keystyle=between&abs=1",
        url  => "/db/cgi-bin/ggb/gbrowse/$species?name=${name}",
        type => 'gbrowse',
    );
    return $gbrowse_link;
}

=head2 gene_link

 Title    : gene_link
 Function : returns link to gene page
 Usage    : $link = $gene->gene_link();
 Returns  : hash
 Args     : none
 
=cut

sub gene_link {
    my ($self) = @_;
    my $gene   = $self->source_feature;
    my $link   = $self->json->link(
        caption => $gene->name,
        url     => '/gene/' . $gene->dbxref->accession,
        type    => 'outer',
    );
}

sub orthologs {
    my ($self) = @_;
    return $self->source_feature->orthologs;
}

1;

=head2 expression

 Title    : expression
 Function : returns json formatted gene expression links
 Returns  : hash
 Args     : none

=cut

#sub expression {
#    my ($self) = @_;
#    my $gene = $self->source_feature;
#    my @expression_links;
#
#    my %hash    = $gene->get_expression_information();
#    my $in_situ = 'In situ Expression Pattern';
#
#    foreach my $source ( keys %hash ) {
#        my $link = $self->json->link(
#            -caption => $source,
#            -url     => $hash{$source},
#            -type    => 'outer',
#        );
#        my $divider = (scalar @expression_links)/2 < scalar( keys(%hash)) -1 ? '&nbsp;|&nbsp;' : undef;
#        push @expression_links, $link;
#        push @expression_links, $self->json->text($divider) if $divider;
#    }
#    if ( exists $hash{$in_situ} ) {
#        my $link = $self->json->link(
#            -caption => $in_situ,
#            -url     => $hash{$in_situ},
#            -type    => 'outer',
#        );
#        push @expression_links, $link;
#    }
#
#    my $dictyExpress       = $gene->external_ids->{dictyExpress};
#    my $dicty_express_link = $self->external_link(
#        -source => 'dictyExpress',
#        -ids    => [$dictyExpress]
#    ) if $dictyExpress;
#
#    my $rnaseq      = $gene->external_ids->{'dictyExpress RNAseq'};
#    my $rnaseq_link = $self->external_link(
#        -source => 'dictyExpress RNAseq',
#        -ids    => [$rnaseq]
#    ) if $rnaseq;
#
#    if ($dicty_express_link) {
#        push @expression_links, $self->json->text('&nbsp;|&nbsp;')
#            if scalar @expression_links > 0;
#        push @expression_links, $dicty_express_link;
#    }
#
#    if ($rnaseq_link) {
#        push @expression_links, $self->json->text('&nbsp;|&nbsp;')
#            if scalar @expression_links > 0;
#        push @expression_links, $rnaseq_link;
#    }
#    return if !@expression_links;
#    return \@expression_links;
#}

