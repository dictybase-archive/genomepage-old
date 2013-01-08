
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
use Mouse;
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
        { 'type.name' => 'part_of' },
        { join        => 'type' }
        )->search_related(
        'subject',
        { 'type_2.name' => 'mRNA' },
        { join          => 'type' }
        );
    return if !$trans_rs->count;

    my $product_rs = $trans_rs->search_related(
        'feature_relationship_objects',
        { 'type_3.name' => 'derives_from' },
        { join          => 'type' }
        )->search_related(
        'subject',
        { 'type_4.name' => 'polypeptide' },
        { join          => 'type' }
        )->search_related(
        'featureprops',
        {   'type_5.name' => 'product',
            'cv.name'     => 'feature_property'
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
    isa        => 'ArrayRef',
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
            'feature_relationship_objects',
            { 'type.name' => 'part_of' },
            { join        => 'type' }
            )->search_related(
            'subject',
            { 'type_2.name' => { 'like', '%RNA' } },
            { join          => 'type' }
            )->all;
        return [
            map {
                Genome::Tabview::JSON::Feature::Generic->new(
                    source_feature => $_,
                    context        => $self->context,
                    base_url       => $self->base_url
                    )
                } @rows
        ];
    }
);

has 'coding_transcripts' => (
    is         => 'ro',
    isa        => 'ArrayRef[Genome::Tabview::JSON::Feature]',
    lazy       => 1,
    auto_deref => 1,
    default    => sub {
        my ($self) = @_;
        my @rows = $self->source_feature->search_related(
            'feature_relationship_objects',
            { 'type.name' => 'part_of' },
            { join        => 'type' }
            )->search_related(
            'subject',
            { 'type_2.name' => 'mRNA' },
            { join          => 'type' }
            )->all;
        return [
            map {
                Genome::Tabview::JSON::Feature::Generic->new(
                    source_feature => $_,
                    context        => $self->context,
                    base_url       => $self->base_url
                    )
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
        = $gene->result_source->schema->resultset('Sequence::Feature')
        ->search(
        {   'type.name'                => 'EST',
            'featureloc_features.fmin' => { '<=', $end },
            'featureloc_features.fmax' => { '>=', $start },
            'featureloc_features.srcfeature_id' =>
                $self->reference_feature->feature_id
        },
        { join => [qw/featureloc_features type/], prefetch => 'dbxref' }
        );
    my $count = $est_rs->count;
    return if !$count;

    my $links;
    my $ctx = $self->context;
    ## -- need to fix
    if ( $count >= 6 ) {
        my $more_link = $self->json->link(
            caption => 'more..',
            url     => $ctx->url_for(
                      '/'
                    . $ctx->stash('common_name') . '/'
                    . 'est?gene='
                    . $gene->dbxref->accession
                )->to_string,
            type => 'outer',
        );
        push @$links, $more_link;
    }

    foreach my $est ( $est_rs->search( {}, { rows => 6 } ) ) {
        unshift @$links, $self->json->link(
            caption => $est->dbxref->accession,
            url     => $ctx->url_for(
                      '/'
                    . $ctx->stash('common_name') . '/' . 'est' . '/'
                    . $est->dbxref->accession
                )->to_string,
            type => 'outer',
        );
    }
    return $links;
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

	my $ctx = $self->context;
    my $name         = $self->gbrowse_window($feature);
    my $track        = "Gene+Genemodel+tRNA+rRNA";
    my $species      = $ctx->stash('common_name');
    my $base_url = $ctx->app->config->{gbrowse_url};
    my $gbrowse_link = $json->link(
        caption =>
            "$base_url/gbrowse_img/$species?q=${name};width=400;t=${track};b=1",
        url  => "$base_url/gbrowse/$species?name=${name}",
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

has 'orthologs' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    builder => '_build_orthologs', 
);

sub _build_orthologs {
    my ($self) = @_;
    my $feature = $self->source_feature;
    my $orthologs = [];
    if ( my $group = $self->ortholog_group ) {
        my $rs = $group->search_related(
            'feature_relationship_objects',
            { 'type.name' => 'member_of' },
            { join        => 'type' }
            )->search_related(
            'subject',
            {   'organism.common_name' =>
                    { '!=', $feature->organism->common_name }
            },
            { join => 'organism', prefetch => [qw/dbxref feature_dbxrefs/] }
            );
        push @$orthologs, $rs->all;
    }
    return $orthologs;
}

has 'ortholog_group' => (
    is      => 'ro',
    isa     => 'Maybe[DBIx::Class::Row]',
    lazy    => 1,
    builder => '_build_ortholog_group'
);

sub _build_ortholog_group {
    my ($self)  = @_;
    my $feature = $self->source_feature;
    my $rs      = $feature->search_related(
        'feature_relationship_subjects',
        { 'type.name' => 'member_of' },
        { join        => 'type' }
        )->search_related(
        'object',
        { 'type_2.name' => 'gene_group' },
        { join          => 'type' }
        );
    return $rs->first;
}

__PACKAGE__->meta->make_immutable;

1;

