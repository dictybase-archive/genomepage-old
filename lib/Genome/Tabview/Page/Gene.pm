
=head1 NAME

   B<Genome::Tabview::Page::Gene> - Class for handling tabbed gene page configuration

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Gene> version 1.0.0

=head1 SYNOPSIS

    my $page = Genome::Tabview::Page::Gene->new( 
        primary_id => <GENE ID>, 
    );
    my $output = $page->process();
    print $cgi->header(), $output;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Gene> handles tabbed gene page configuration. It allows to set up
    tabs to show, their order and provides functionality to checks aviability of each tab for the 
    particular gene. Expects gene primary id to be passed. Uses gene_tabview.tt and error.tt 
    templates as default page and error templates respectively. For reserved genes, such as actin, 
    only gene summary tab  will be displayed. Sets Gene Summary Tab as active if active tab parameter 
    is not passed.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.Please report any bugs or feature requests to B<dictybase@northwestern.edu>

=head1 TODO

=head1 AUTHOR

I<Yulia Bushmanova> B<y-bushmanova@northwestern.edu>
I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) B<2007>, dictyBase <<dictybase@northwestern.edu>>. All rights reserved.

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

package Genome::Tabview::Page::Gene;

use strict;
use namespace::autoclean;
use Carp;
use Moose;
use MooseX::Params::Validate;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::Config::Panel::Item::Tab;

extends 'Genome::Tabview::Page';

has 'primary_id' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);
has 'sub_id' => ( isa => 'Str', is => 'rw' );
has 'active_tab' =>
    ( isa => 'Str', is => 'rw', default => 'gene', lazy => 1 );

=head2 init

 Title    : init
 Function : initializes the page. Sets page configuration parameters
 Usage    : $self->init();
 Returns  : nothing
 Args     : none
 
=cut

sub init {
    my ($self) = @_;
    my $primary_id = $self->primary_id;

    ## -- page configuration
    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( layout => 'tabview' );

    my $ctx       = $self->context;
    my $prepender = $ctx->url_to($self->base_url, $self->primary_id);
    $panel->add_item(
        $self->tab(
            key   => 'gene',
            label => 'Gene Summary',
            href  => $prepender
        )
    );
    $panel->add_item( $self->protein_tab ) if $self->show_protein;

    $panel->add_item(
        $self->tab(
            key   => 'orthologs',
            label => 'Orthologs',
            href  => $ctx->url_to( $prepender, 'orthologs' )
        )
    ) if $self->show_orthologs;

    $panel->add_item(
        $self->tab(
            key   => 'references',
            label => 'References',
            href  => $ctx->url_to( $prepender, 'references' )
        )
    ) if $self->show_refs;
    $panel->add_item(
        $self->tab(
            key      => 'blast',
            label    => 'BLAST',
            source   => '/tools/blast?noheader=1&primary_id=' . $primary_id,
            dispatch => 'true',
            href     => $ctx->url_to( $prepender, 'blast' )
        )
    );

    if ( $self->active_tab && $self->active_tab eq 'feature' ) {
        $panel->add_item(
            $self->tab(
                key        => 'feature',
                label      => $self->sub_id,
                primary_id => $self->sub_id,
                href => $ctx->url_to( $prepender, 'feature', $self->sub_id )
            )
        );
    }

    $config->add_panel($panel);
    $self->config($config);
    return $self;

    #   $panel->add_item(
    #        $self->tab(
    #            -key   => 'go',
    #            -label => 'Gene Ontology',
    #            -href  => "$prepender/go"
    #        )
    #    ) if $self->show_go;

    #    $panel->add_item(
    #        $self->tab(
    #            -key   => 'phenotypes',
    #            -label => 'Phenotypes',
    #            -href  => "$prepender/phenotypes"
    #        )
    #    ) if $self->show_phenotypes;

}

=head2 protein_tab

 Title    : protein_tab
 Function : composes protein tab for the protein coding genes
 Usage    : $tab = $self->protein_tab();
 Returns  : Genome::Tabview::Config::Panel::Item::Tab object
 Args     : none

=cut

sub protein_tab {
    my ($self)      = @_;
    my $gene        = $self->feature;
    my $gene_id     = $gene->dbxref->accession;
    my @transcripts = $gene->search_related(
        'feature_relationship_objects',
        { 'type.name' => 'part_of' },
        { join        => 'type' }
        )->search_related(
        'subject',
        { 'type_2.name' => 'mRNA' },
        { join          => 'type', prefetch => 'dbxref' }
        )->all;

    my $item;
    my $base_url = $self->base_url;
    if ( scalar @transcripts > 1 ) {
        my $items;
        my @alphabet = ( 'A' .. 'Z' );

        for my $i ( 0 .. $#transcripts ) {
            my $trans_id = $transcripts[$i]->dbxref->accesion;
            my $active   = $i == 0 ? 'true' : undef;
            my $subtab   = $self->tab(
                key        => 'protein',
                label      => 'Splice Variant ' . $alphabet[$i],
                primary_id => $trans_id,
                href       => $self->context->url_to(
                    $base_url, $gene_id, 'protein', $trans_id
                )
            );
            push @$items, $subtab;
        }

        my $panel = Genome::Tabview::Config::Panel->new(
            items  => $items,
            layout => 'tabview'
        );
        my $tab = Genome::Tabview::Config::Panel::Item::Tab->new(
            key     => 'protein_isoforms',
            label   => 'Protein Information',
            type    => 'toolbar',
            content => [$panel],
            href => $self->context->url_to( $base_url, $gene_id, 'protein' )
        );
        return $tab;
    }

    my $trans_id = $transcripts[0]->dbxref->accession;
    my $tab      = $self->tab(
        key        => 'protein',
        label      => 'Protein Information',
        primary_id => $trans_id,
        href       => $self->context->url_to(
            $base_url, $gene_id, 'protein', $trans_id
        )
    );
    return $tab;
}

=head2 get_header

 Title    : get_header
 Function : defines the header of the page
 Usage    : $header = $self->get_header();
 Returns  : string
 Args     : none
 
=cut

sub get_header {
    my ($self) = @_;
    return $self->feature->name;
}

=head2 show_protein

 Title    : show_protein
 Function : defines if to show protein tab
 Usage    : $show = $self->show_protein();
 Returns  : boolean
 Args     : none
 
=cut

sub show_protein {
    my ($self) = @_;
    return $self->feature->search_related(
        'feature_relationship_objects',
        { 'type.name' => 'part_of' },
        { join        => 'type' }
        )->search_related(
        'subject',
        { 'type_2.name' => 'mRNA' },
        { join          => 'type' }
        )->count;
}

=head2 show_refs

 Title    : show_refs
 Function : defines if to show references tab
 Usage    : $show = $self->show_refs();
 Returns  : boolean
 Args     : none
 
=cut

sub show_refs {
    my ($self) = @_;
    return $self->feature->search_related( 'feature_pubs', {} )->count;
}

=head2 show_orthologs

 Title    : show_orthologs
 Function : defines if to show orthologs tab
 Usage    : $show = $self->show_orthologs();
 Returns  : boolean
 Args     : none
 
=cut

sub show_orthologs {
    my ($self) = @_;
    return $self->feature->search_related(
        'feature_relationship_subjects',
        { 'type.name' => 'member_of' },
        { join        => 'type' }
        )->search_related(
        'object',
        { 'type_2.name' => 'gene_group' },
        { join          => 'type' }
        )->count;
}

=head2 tab_source

 Title    : tab_source
 Usage    : my $source = $self->tab_source( -key => 'go', -primary_id => <GENE ID>;
 Function : composes sorce url for the tab
 Returns  : string
 Args     : -key        : tab key
            -primary_id : primary id of the feature

=cut

sub tab_source {
    my ( $self, $key, $primary_id ) = validated_list(
        \@_,
        key        => { isa => 'Str' },
        primary_id => { isa => 'Str', optional => 1 }
    );
    $primary_id ||= $self->primary_id;
    return $self->context->url_to( $self->base_url, $primary_id,
        $key . '.json' );
}

=head2 tab

 Title    : tab
 Function : composes tab
 Usage    : $tab = $self->tab( key =>'go', primary_id => <GENE ID>, active => 1);
 Returns  : Genome::Tabview::Config::Panel::Item::Tab object
 Args     : key        : tab key
            label      : tab label
            active     : true value result in tab being activated
            primary_id : primary id of the feature. If not passed, primary id of the page 
                          feature would be used instead
            href       : href of the tab. If not set, tab key will be used 
=cut

sub tab {
    my ( $self, %arg ) = validated_hash(
        \@_,
        key        => { isa => 'Str' },
        label      => { isa => 'Str' },
        primary_id => { isa => 'Str', optional => 1 },
        active     => { isa => 'Str', optional => 1 },
        href       => { isa => 'Str', optional => 1 },
        source     => { isa => 'Str', optional => 1 },
        dispatch   => { isa => 'Str', optional => 1 }
    );

    my $active_tab = $arg{active} ? 'true' : $self->active_tab
        && $arg{key} eq $self->active_tab ? 'true' : 'false';
    my $href = $arg{href} ? $arg{href} : $arg{key};


    my $source = $arg{source} || $self->tab_source(
        key        => $arg{key},
        primary_id => $arg{primary_id} || $self->primary_id
    );

    my $item = Genome::Tabview::Config::Panel::Item::Tab->new(
        key    => $arg{key},
        label  => $arg{label},
        active => $active_tab,
        href   => $href,
        source => $source
    );
    $item->dispatch( $arg{dispatch} ) if $arg{dispatch};
    return $item;
}

=head2 show_go

 Title    : show_go
 Function : defines if to show go tab
 Usage    : $show = $self->show_go();
 Returns  : boolean
 Args     : none
 
=cut

#sub show_go {
#    my ($self) = @_;
#
#    my $go = Genome::Tabview::JSON::GO->new(
#        -primary_id => $self->feature->primary_id );
#    return $go->{has_annotations} ? 1 : 0;
#}

=head2 show_phenotypes

 Title    : show_phenotypes
 Function : defines if to show strains and phenotypes tab
 Usage    : $show = $self->show_phenotypes();
 Returns  : boolean
 Args     : none
 
=cut

#sub show_phenotypes {
#    my ($self) = @_;
#    my $gene = $self->feature;
#    return if !@{ $gene->features };
#    my $genotypes = $gene->genotype();
#    return $genotypes ? 1 : 0;
#}

=head2 show_blast

 Title    : show_blast
 Function : defines if to show blast tab
 Usage    : $show = $self->show_blast();
 Returns  : boolean
 Args     : none
 
=cut

#sub show_blast {
#    my ($self) = @_;
#    my $gene = $self->feature;
#    return @{ $gene->features() } ? 1 : 0;
#}

__PACKAGE__->meta->make_immutable;

1;
