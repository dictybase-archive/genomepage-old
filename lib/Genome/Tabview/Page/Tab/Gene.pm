
=head1 NAME

   B<Genome::Tabview::Page::Tab::Gene> - Class for handling gene tab configuration 

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Tab::Gene> version 1.0.0

=head1 SYNOPSIS

    my $tab = Genome::Tabview::Page::Tab::Gene->new( -primary_id => <GENE ID> );
    my $json = $tab->configure();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Tab::Gene> handles gene tab configuration, determines which sections are 
    available for the tab. For reserved genes, such as actin, shows only General Information section

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.Please report any bugs or feature requests to

B<dictybase@northwestern.edu>

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

package Genome::Tabview::Page::Tab::Gene;

use namespace::autoclean;
use Moose;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::Config::Panel::Item::Accordion;
use Genome::Tabview::JSON::Feature::Gene;

#use Genome::Tabview::JSON::GO;
extends 'Genome::Tabview::Page::Tab';

sub _build_base_url {
    my ($self) = @_;
    my $ctx = $self->context;
    return $ctx->url_to( $ctx->stash('common_name'), 'gene',
        $self->primary_id );
}

has 'primary_id' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

before 'feature' => sub {
    my ($self) = @_;
    croak "Need to set the model attribute\n" if !$self->has_model;
};
has '+feature' => (
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $row = $self->model->resultset('Sequence::Feature')->search(
            {   'dbxref.accession' => $self->primary_id,
                'type.name'        => 'gene'
            },
            { join     => [qw/dbxref type/], 'rows' => 1 },
            { prefetch => [qw/featureloc_features organism/] }
        )->single;
        croak $self->primary_id, " is not a gene\n" if !$row;
        return $row;
    }
);

=head2 init

 Title    : init
 Function : initializes the tab. Sets tab configuration parameters
 Usage    : $tab->init();
 Returns  : nothing
 Args     : none
 
=cut

sub init {
    my ($self) = @_;
    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( layout => 'accordion' );
    my $items;
    push @$items,
        $self->accordion(
        key   => 'info',
        label => $self->simple_label("General Information")
        );
    push @$items,
        $self->accordion(
        key   => 'genomic_info',
        label => $self->simple_label("Genomic Information"),
        ) if $self->show_genomic_info;
    push @$items,
        $self->accordion(
        key   => 'product',
        label => $self->simple_label("Gene Product Information"),
        ) if $self->show_product;
    push @$items,
        $self->accordion(
        key   => 'sequences',
        label => $self->simple_label("Associated Sequences"),
        ) if $self->show_sequences;
    push @$items,
        $self->accordion(
        key   => 'links',
        label => $self->simple_label("Links"),
        ) if $self->show_links;

        push @$items,
        $self->accordion(
        key   => 'references',
        label => $self->references_label,
        ) if $self->show_references;

    $panel->items($items);
    $config->add_panel($panel);
    $self->config($config);

}

=head2 show_genomic_info

 Title    : show_genomic_info
 Function : defines if to show gene genomic information section
 Usage    : $show = $tab->show_genomic_info();
 Returns  : boolean
 Args     : none
 
=cut

sub show_genomic_info {
    my ($self) = @_;
    my $gene = $self->feature;

    my $primary_feat_rs = $gene->search_related(
        'feature_relationship_objects',
        { 'type.name' => 'part_of' },
        { join        => 'type' }
    )->search_related( 'subject', {}, { prefetch => 'type' } );

    return if !$primary_feature_rs->count;

    ## --show the gbrowse map for RNA features (right now tRNA, ncRNA, mRNA) and pseudogenes
    return $primary_feature_rs->first->type() =~ m{RNA|pseudogene}ix ? 1 : 0;
}

=head2 show_product

 Title    : show_product
 Function : defines if to show gene product section
 Usage    : $show = $tab->show_product();
 Returns  : boolean
 Args     : none
 
=cut

sub show_product {
    my ($self) = @_;
    return $self->show_genomic_info;
}

=head2 show_sequences

 Title    : show_sequences
 Function : defines if to show associated sequences section
 Usage    : $show = $tab->show_sequences();
 Returns  : boolean
 Args     : none
 
=cut

sub show_sequences {
    my ($self) = @_;
    my $gene   = $self->feature;
    my $start  = $gene->featureloc_features->first->fmin;
    my $end    = $gene->featureloc_features->first->fmax;
    return $self->model->resultset('Sequence::Featureloc')->count(
        {   'fmin'                => { '<=', $end },
            'fmax'                => { '=>', $start },
            'feature.organism_id' => $gene->organism_id
        },
        { join => 'feature' }
    );
}

=head2 show_links

 Title    : show_links
 Function : defines if to show gene external links section
 Usage    : $show = $tab->show_links();
 Returns  : boolean
 Args     : none
 
=cut

sub show_links {
    my ($self)  = @_;
    my $gene    = $self->feature;
    my $ui_gene = Genome::Tabview::JSON::Feature::Gene->new(
        source_feature => $self->feature );
    return $ui_gene->external_links ? 1 : 0;
}

=head2 show_references

 Title    : show_references
 Function : defines if to show gene latest references section
 Usage    : $show = $tab->show_references();
 Returns  : boolean
 Args     : none
 
=cut

sub show_references {
    my ($self) = @_;
    my $gene = $self->feature;
    return $gene->search_related( 'feature_pubs', {} )->count;
}

=head2 references_label

 Title    : references_label
 Function : returns label for references section
 Usage    : $label = $tab->references_label();
 Returns  : array reference
 Args     : none
 
=cut

sub references_label {
    my ($self) = @_;
    my $count = $self->show_references;
    return if !$count;

    my $references_link = $self->json->link(
        caption => 'View complete list of references (' . $count . ' papers)',
        url     => $self->context->url_for(
            $self->base_url, $self->primary_id, 'references'
        ),
        type => 'tab',
    );
    my $text = $self->json->text("Latest References");
    return [ $text, $references_link ];
}

=head2 phenotypes_label

 Title    : phenotypes_label
 Function : returns label for phenotypes section
 Usage    : $label = $tab->phenotypes_label();
 Returns  : array reference
 Args     : none
 
=cut

#sub phenotypes_label {
#    my ($self) = @_;
#    my $gene = $self->feature;
#    my $base_url = $self->base_url || '';
#
#    my $pheno_link = $self->json->link(
#        -caption => 'View Phenotype Information',
#        -url     => $base_url . '/' . $gene->primary_id . "/phenotypes",
#        -type    => 'tab',
#    );
#    my $text = $self->json->text("Strains and Phenotypes");
#    return [ $text, $pheno_link ];
#}

=head2 show_promoters

 Title    : show_promoters
 Function : defines if to show gene associated promoters
 Usage    : $show = $tab->show_promoters();
 Returns  : boolean
 Args     : none
 
=cut

#sub show_promoters {
#    my ($self) = @_;
#    my $gene = $self->feature;
#    return @{ $gene->promoters() } ? 1 : 0;
#}

=head2 show_go

 Title    : show_go
 Function : defines if to show gene GO information
 Usage    : $show = $tab->show_go();
 Returns  : boolean
 Args     : none
 
=cut

#sub show_go {
#    my ($self) = @_;
#    my $go = Genome::Tabview::JSON::GO->new(
#        -primary_id => $self->feature->primary_id );
#    return $go->{has_annotations} ? 1 : 0;
#}

=head2 go_label

 Title    : go_label
 Function : returns label for GO section
 Usage    : $label = $tab->go_label();
 Returns  : array reference
 Args     : none
 
=cut

#sub go_label {
#    my ($self) = @_;
#    my $gene = $self->feature;
#    my $base_url = $self->base_url || '';
#    my $go_link = $self->json->link(
#        -caption => 'View evidence and references',
#        -url     => $base_url . '/' . $gene->primary_id . "/go",
#        -type    => 'tab',
#    );
#    my $text = $self->json->text("Gene Ontology Annotations");
#    return [ $text, $go_link ];
#}

=head2 show_phenotypes

 Title    : show_phenotypes
 Function : defines if to show gene phenotypes section
 Usage    : $show = $tab->show_phenotypes();
 Returns  : boolean
 Args     : none
 
=cut

#sub show_phenotypes {
#    my ($self) = @_;
#    my $gene = $self->feature;
#    return if !@{ $gene->features };
#
#    my $count
#        = dicty::Search::Genotype->count_by_feature_id( $gene->feature_id );
#    my @urls = $gene->get_insertional_mutants_urls();
#    return $count || @urls || $gene->plasmids ? 1 : 0;
#}

=head2 show_summary

 Title    : show_summary
 Function : defines if to show gene summary section
 Usage    : $show = $tab->show_summary();
 Returns  : boolean
 Args     : none
 
=cut

#sub show_summary {
#    my ($self) = @_;
#    my $gene = $self->feature;
#    return $gene->has_paragraph ? 1 : 0;
#}





1;

