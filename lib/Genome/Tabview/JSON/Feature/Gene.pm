
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
use Bio::Root::Root;
use Genome::Tabview::JSON::Genotype;
use Genome::Tabview::JSON::Feature::Generic;
use Genome::Tabview::JSON::GO;
use base qw( Genome::Tabview::JSON::Feature);

my $config;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::JSON::Feature::Gene> object. 
 Usage    : my $page = Genome::Tabview::JSON::Feature::Gene->new();
 Returns  : Genome::Tabview::JSON::Feature::Gene object with default configuration.     
 Args     : -primary_id   - gene primary id.
 
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/PRIMARY_ID/];
    $self->{root} = Bio::Root::Root->new();
    my ( $primary_id, $section )
        = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;
    my $gene = dicty::Feature->new( -primary_id => $primary_id );
    $self->{root}->throw('Id provided does not belong to a gene')
        if $gene->type ne 'gene';

    $self->source_feature($gene);
    return $self;
}

=head2 public_notes

 Title    : public_notes
 Function : returns json formatted gene public notes
 Returns  : hash
 Args     : none

=cut

sub public_notes {
    my ($self) = @_;
    my $gene = $self->source_feature;
    my $pub_notes;
    return if !@{ $gene->public_notes() };
    foreach my $note ( @{ $gene->public_notes() } ) {
        $pub_notes .= $note->text() . "<br>";
    }
    return $self->json->text($pub_notes);
}

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
    my @wiki_links;

    if ( $gene->has_qualifier('Has Wiki Page') ) {
        my $view_link = $json->link(
            -caption => "View annotation for $gene_name",
            -url     => $wiki_root . $gene_name,
            -type    => 'outer',
            -style   => 'font-weight: bold; color: #CC0000',
        );
        push @wiki_links, $view_link;
    }
    my $edit_link = $json->link(
        -caption => "Add an annotation for $gene_name",
        -url     => $wiki_root . $gene_name . "?action=edit",
        -type    => 'outer'
    );
    my $help_link = $json->link(
        -caption => "Community Annotations Help",
        -url     => $wiki_root . "Community_Annotations",
        -type    => 'outer',
    );
    push @wiki_links, ( $edit_link, $help_link );
    return \@wiki_links;
}

=head2 protein_synonyms

 Title    : features
 Function : returns json formatted gene protein synonyms
 Usage    : $protein_synonyms = $gene->protein_synonyms();
 Returns  : hash
 Args     : none
 
=cut

sub protein_synonyms {
    my ($self) = @_;
    return if !@{ $self->source_feature->protein_synonyms };
    my $synonyms = join( ", ", @{ $self->source_feature->protein_synonyms } );
    return $self->json->text($synonyms);
}

=head2 synonyms

 Title    : features
 Function : returns json formatted gene synonyms
 Usage    : $synonyms = $gene->synonyms();
 Returns  : hash
 Args     : none
 
=cut

sub synonyms {
    my ($self) = @_;

    return if !@{ $self->source_feature->synonyms };
    my $synonyms = '<i>'
        . join( ", ", @{ $self->source_feature->synonyms() } ) . '</i>';
    return $self->json->text($synonyms);
}

=head2 name_description

 Title    : name_description
 Function : returns json formatted gene name description
 Usage    : $name_description = $gene->name_description();
 Returns  : hash
 Args     : none
 
=cut

sub name_description {
    my ($self) = @_;

    my $gene = $self->source_feature;
    return if !$gene->name_description;
    return $self->json->text( $gene->name_description );
}

=head2 gene_products

 Title    : features
 Function : returns json formatted gene products
 Usage    : $gene_products = $gene->gene_products();
 Returns  : hash
 Args     : none
 
=cut

sub gene_products {
    my ($self) = @_;

    #return $self->{gene_products} if $self->{gene_products};

    my $gene = $self->source_feature;
    return if !@{ $gene->gene_products() };

    my @gene_products_array = map {
        my $str = $_->product_name();
        $str .= " <font color='#CC0000'>(Automated)</font>"
            if $_->is_automated();
        $str;
    } @{ $gene->gene_products() };

#$self->{gene_products} = $self->json->text( join( '<br>', @gene_products_array ) );
#return $self->{gene_products};
    return $self->json->text( join( '<br>', @gene_products_array ) );
}

=head2 features

 Title    : features
 Function : returns gene features
 Usage    : @features = @{$gene->features()};
 Returns  : reference to an array of Genome::Tabview::JSON::Feature::Generic objects
 Args     : none
 
=cut

sub features {
    my ($self) = @_;
    return $self->{features} if $self->{features};
    my $features;
    foreach my $feature ( @{ $self->source_feature->features } ) {
        my $json_feature = Genome::Tabview::JSON::Feature::Generic->new(
            -primary_id => $feature->primary_id );
        $json_feature->context( $self->context ) if $self->context;
        push @$features, $json_feature;
    }
    $self->{features} = $features;
    return $self->{features};
}

=head2 primary_features

 Title    : primary_features
 Function : returns gene primary features
 Usage    : @features = @{$gene->primary_features()};
 Returns  : reference to an array of Genome::Tabview::JSON::Feature::Generic objects
 Args     : none
 
=cut

sub primary_features {
    my ($self) = @_;
    return $self->{primary_features} if $self->{primary_features};

    return if !@{ $self->source_feature->primary_features };

    my $features;
    foreach my $feature ( @{ $self->source_feature->primary_features } ) {
        my $json_feature = Genome::Tabview::JSON::Feature::Generic->new(
            -primary_id => $feature->primary_id );
        $json_feature->context( $self->context ) if $self->context;
        push @$features, $json_feature;
    }
    $self->{primary_features} = $features;
    return $self->{primary_features};
}

=head2 genbank_fragment

 Title    : genbank_fragment
 Function : returns json genbank genomic fragment links for a gene 
 Returns  : hash
 Args     : none

=cut

sub genbank_fragments {
    my ($self) = @_;
    my $gene = $self->source_feature;
    my $features;

    return $self->{genbank_fragments} if $self->{genbank_fragments};

    my @genbank = grep { $_->source() =~ m{GenBank}ix } @{ $gene->features };
    my @genbank_cdna = grep { $_->type() =~ m{databank}ix } @genbank;

    return if !@genbank_cdna;
    foreach my $feature (@genbank_cdna) {
        my $json_feature = Genome::Tabview::JSON::Feature::Generic->new(
            -primary_id => $feature->primary_id );
        $json_feature->context( $self->context ) if $self->context;
        push @$features, $json_feature;
    }
    $self->{genbank_fragments} = $features;
    return $self->{genbank_fragments};
}

=head2 genbank_mrna

 Title    : genbank_mrna
 Function : returns json genbank mrna links for a gene 
 Returns  : hash
 Args     : none

=cut

sub genbank_mrnas {
    my ($self) = @_;
    my $gene = $self->source_feature;
    my $features;

    return $self->{genbank_mrnas} if $self->{genbank_mrnas};

    my @genbank = grep { $_->source() =~ m{GenBank}ix } @{ $gene->features };
    my @genbank_mrna = grep { $_->type() =~ m{cdna}ix } @genbank;

    return if !@genbank_mrna;
    foreach my $feature (@genbank_mrna) {
        my $json_feature = Genome::Tabview::JSON::Feature::Generic->new(
            -primary_id => $feature->primary_id );
        $json_feature->context( $self->context ) if $self->context;
        push @$features, $json_feature;
    }
    $self->{genbank_mrnas} = $features;
    return $self->{genbank_mrnas};
}

=head2 ests

 Title    : ests
 Function : returns json formatted gene ests links
 Returns  : hash
 Args     : none

=cut

sub ests {
    my ($self)           = @_;
    my $gene             = $self->source_feature;
    my $feature_page_url = '/db/cgi-bin/feature_page.pl?primary_id=';
    my @ests
        = dicty::Search::Feature->Search_overlapping_feats_by_range(
        $gene->reference_feature->name(),
        $gene->start, $gene->end, 'EST' )
        if $gene->start();
    return if !@ests;
    my @links;
    my $count;
    foreach my $est (@ests) {
        $count++;
        my $link = $self->json->link(
            -caption => $est->primary_id,
            -url     => $feature_page_url . $est->primary_id,
            -type    => 'outer',
        );
        push @links, $link;
        if ( $count == 6 ) {
            my $more_link = $self->json->link(
                -caption => 'more..',
                -url     => "/db/cgi-bin/more_est.pl?feature_id="
                    . $gene->feature_id
                    . "&gene_name="
                    . $gene->name,
                -type => 'outer',
            );
            push @links, $more_link;
            last;
        }
    }
    return \@links;
}

=head2 promoters

 Title    : promoters
 Function : returns json formatted gene promoter links
 Returns  : hash
 Args     : none

=cut

sub promoters {
    my ($self) = @_;
    my $gene = $self->source_feature;
    my @links;
    foreach my $promoter ( @{ $gene->promoters() } ) {
        my $link = $self->json->link(
            -caption => $promoter->primary_id,
            -url     => $promoter->details_url,
            -type    => 'outer',
        );
        push @links, $link;
    }
    return \@links;
}

=head2 function_annotations

 Title    : function_annotations
 Function : returns json formatted gene function annotation links
 Returns  : hash
 Args     : none

=cut

sub function_annotations {
    my ($self) = @_;
    return $self->get_GO_annotations( $self->go->function_annotations )
        || ' ';
}

=head2 process_annotations

 Title    : process_annotations
 Function : returns json formatted gene process annotation links 
 Returns  : hash
 Args     : none

=cut

sub process_annotations {
    my ($self) = @_;
    return $self->get_GO_annotations( $self->go->process_annotations ) || ' ';
}

=head2 component_annotations

 Title    : component_annotations
 Function : returns json formatted gene component annotation links 
 Returns  : hash
 Args     : none

=cut

sub component_annotations {
    my ($self) = @_;
    return $self->get_GO_annotations( $self->go->component_annotations )
        || ' ';
}

=head2 get_GO_annotations

 Title    : get_GO_annotations
 Function : returns formatted GO annotations for a gene 
 Returns  : string
 Args     : dicty::Feature::GENE object

=cut

sub get_GO_annotations {
    my ( $self, $ann ) = @_;
    return if !$ann->count;

    my $json = $self->json;
    my @links;
    while ( my $annotation = $ann->next ) {
        my $link = $self->go->annotation_link($annotation);
        my $divider
            = ( scalar @links ) / 2 < scalar $ann->count - 1 ? ',' : '';
        push @links,
            (
            @$link,
            $json->text(
                '&nbsp;('
                    . $self->go->evidence_code(
                    $self->go->get_evidence($annotation)
                    )
                    . ')'
                    . $divider
                    . '&nbsp;&nbsp;'
            ),
            );
    }
    return \@links;
}

=head2 pathways

 Title    : pathways
 Function : returns json formatted gene pathway links 
 Returns  : hash
 Args     : none

=cut

sub pathways {
    my ($self)   = @_;
    my $gene     = $self->source_feature;
    my @pathways = @{ $gene->pathways };

    return if !@pathways;

    my @pathway_links;
    foreach my $pathway (@pathways) {
        my $divider = scalar @pathway_links < scalar @pathways - 1 ? ',' : '';
        my $pathway_name = $pathway->pathway_name;
        my $common_name  = $pathway->common_name . $divider;
        my $link         = $self->json->link(
            -caption => $common_name,
            -url =>
                "/pathways/DICTY/new-image?type=PATHWAY&object=$pathway_name&detail-level=2",
            -type => 'outer',
        );
        push @pathway_links, $link;
    }
    return if !@pathway_links;
    return \@pathway_links;
}

=head2 expression

 Title    : expression
 Function : returns json formatted gene expression links
 Returns  : hash
 Args     : none

=cut

sub expression {
    my ($self) = @_;
    my $gene = $self->source_feature;
    my @expression_links;

    my %hash    = $gene->get_expression_information();
    my $in_situ = 'In situ Expression Pattern';

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
    if ( exists $hash{$in_situ} ) {
        my $link = $self->json->link(
            -caption => $in_situ,
            -url     => $hash{$in_situ},
            -type    => 'outer',
        );
        push @expression_links, $link;
    }

    my $dictyExpress       = $gene->external_ids->{dictyExpress};
    my $dicty_express_link = $self->external_link(
        -source => 'dictyExpress',
        -ids    => [$dictyExpress]
    ) if $dictyExpress;

    my $rnaseq      = $gene->external_ids->{'dictyExpress RNAseq'};
    my $rnaseq_link = $self->external_link(
        -source => 'dictyExpress RNAseq',
        -ids    => [$rnaseq]
    ) if $rnaseq;

    if ($dicty_express_link) {
        push @expression_links, $self->json->text('&nbsp;|&nbsp;')
            if scalar @expression_links > 0;
        push @expression_links, $dicty_express_link;
    }

    if ($rnaseq_link) {
        push @expression_links, $self->json->text('&nbsp;|&nbsp;')
            if scalar @expression_links > 0;
        push @expression_links, $rnaseq_link;
    }
    return if !@expression_links;
    return \@expression_links;
}

=head2 researchers

 Title    : expression
 Function : returns json formatted gene researchers links
 Returns  : hash
 Args     : none

=cut

sub researchers {
    my ($self) = @_;
    my $gene = $self->source_feature;
    return if !@{ $gene->colleagues() };

    my $link = $self->json->link(
        -caption => $gene->name . " Researchers",
        -url     => "/db/cgi-bin/"
            . $config->value('SITE_NAME')
            . "/colleague/colleagueSearch?locus="
            . $gene->feature_id,
        -type => 'outer',
    );
    return $link;
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

    ## -- collect links from mRNA features, preferring links from primary model
    my @cdss = grep { $_->type eq "mRNA" } @{ $gene->features() };
    my @curated_model
        = grep { $_->source() eq $config->value('SITE_NAME') . " Curator" }
        @cdss;
    my @predicted_model
        = grep { $_->source() ne $config->value('SITE_NAME') . " Curator" }
        @cdss;

    my %linkage;
    my @features = ( $gene, @curated_model, @predicted_model );

    foreach my $feature (@features) {
        my $external_id_hash = $feature->external_ids;
        foreach my $key ( keys %$external_id_hash ) {
            my $value = $$external_id_hash{$key};
            next
                if exists $linkage{$key}
                    && ( join( ' ', @{ $linkage{$key} } ) =~ m{$value} );
            push @{ $linkage{'ENA'} }, $value
                if $key eq 'Protein Accession Number';
            push @{ $linkage{$key} }, $value;
        }
    }

    my @external_links;
    foreach my $key ( keys %linkage ) {
        ## microarray links are displayed in "Expression group"
        next if $key =~ m{dictyExpress}i;

        my @link = $self->external_link(
            -source => $key,
            -ids    => $linkage{$key},
        );
        my $divider
            = ( scalar @external_links ) / 2 < scalar( keys(%linkage) ) - 1
            ? '&nbsp;|&nbsp;'
            : undef;

        if (@link) {
            push @external_links, @link;
            push @external_links, $self->json->text($divider) if $divider;
        }
    }

    return if !@external_links;
    return \@external_links;
}

=head2 summary

 Title    : summary
 Function : returns gene summary
 Returns  : hash
 Args     : none

=cut

sub summary {
    my ($self) = @_;
    return $self->{summary} if $self->{summary};
    my $gene      = $self->source_feature;
    my $paragraph = $gene->paragraph();
    my $xsl       = $config->value('WEB_DB_ROOT') . "/xsl/paragraph.xsl";

    $self->{summary} = $paragraph->transform($xsl);
    return $self->{summary};
}

=head2 curator_notes

 Title    : curator_notes
 Function : returns json formatted gene curator notes 
 Returns  : hash
 Args     : none

=cut

sub curator_notes {
    my ($self) = @_;
    my $summary = $self->summary;
    my $notes;
    if ( $summary =~ m{\[Curation\sStatus:\s.+\]}sx ) {
        $summary =~ m{(.+)\[Curation\sStatus:\s.+\]}sx;
        $notes = $1;
    }
    else {
        $notes = $summary;
    }
    my $check = $notes;
    $check =~ s{\s\n}{}gx;

    return $self->json->format_url($notes) if $notes =~ m{\S+}x;
    return;
}

=head2 curation_status

 Title    : curation_status
 Function : returns json formatted gene curation status
 Returns  : hash
 Args     : none

=cut

sub curation_status {
    my ($self) = @_;
    my $summary = $self->summary;
    if ( $summary =~ m{.+\[Curation\sStatus:\s(.+)\]}sx ) {
        my $status = $1;

        return $self->json->text($status) if $status ne ' ';
    }
    return;
}

=head2 genotypes

 Title    : genotypes
 Function : returns gene genotypes data
 Returns  : hash
 Args     : none

=cut

sub genotypes {
    my ($self) = @_;
    $self->_get_genotypes if !$self->{genotypes};
    return $self->{genotypes};
}

=head2 additional_strains

 Title    : additional_strains
 Function : returns additional strains data for a gene 
 Returns  : hash
 Args     : none

=cut

sub additional_strains {
    my ($self) = @_;
    $self->_get_genotypes
        if !$self->{genotypes} && !$self->{additional_strains};
    return $self->{additional_strains};
}

=head2 mutant_strains

 Title    : mutant_strains
 Function : returns mutant links data for a gene 
 Returns  : hash
 Args     : none

=cut

sub mutant_links {
    my ($self) = @_;
    my $gene   = $self->source_feature;
    my @urls   = $gene->get_insertional_mutants_urls();
    return if @urls == 0;

    my @mutant_links;
    foreach my $array_ref (@urls) {
        my $title = @$array_ref[0];
        my $url   = @$array_ref[1];
        my $link  = $self->json->link(
            -caption => $title,
            -url     => $url,
            -type    => 'outer',
        );
        push @mutant_links, $link;
    }
    return \@mutant_links if @mutant_links;
}

=head2 _get_genotypes

 Title    : _get_genotypes
 Function : gets gene genotypes data
 Returns  : string
 Args     : none

=cut

sub _get_genotypes {
    my ($self) = @_;
    my $gene = $self->source_feature;

    return if !$gene->genotype;

    my @inviable_strains
        = dicty::Search::Genotype->search_inviable_by_feature_id(
        $gene->feature_id );
    my @null_strains = dicty::Search::Genotype->search_null_by_feature_id(
        $gene->feature_id );
    my @strains
        = dicty::Search::Genotype->search_not_null_not_inviable_by_feature_id(
        $gene->feature_id );
    my @genotypes;
    my @additional_strains;

    foreach my $genotype ( @null_strains, @strains, @inviable_strains ) {
        my $json_genotype = Genome::Tabview::JSON::Genotype->new(
            -genotype_id => $genotype->genotype_id );
        $json_genotype->context( $self->context ) if $self->context;

        my $count = dicty::Search::Genotype->count_experiments_by_id(
            $genotype->genotype_id );
        if ( $count > 0 ) {
            push @genotypes, $json_genotype;
        }
        else {
            push @additional_strains, $json_genotype;
        }
    }
    $self->{genotypes} = \@genotypes;
    $self->{additional_strains} = \@additional_strains if @additional_strains;
    return $self;
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
        -caption =>
            "/db/cgi-bin/ggb/gbrowse_img/$species?name=${name}&width=500&type=${track}&keystyle=between&abs=1",
        -url  => "/db/cgi-bin/ggb/gbrowse/$species?name=${name}",
        -type => 'gbrowse',
    );
    return $gbrowse_link;
}

=head2 go

 Title    : go
 Function : returns gene go
 Usage    : my $go = $gene->go;
 Returns  : hash
 Args     : none
 
=cut

sub go {
    my ($self) = @_;
    my $primary_id = $self->source_feature->primary_id;

    return $self->{go} if $self->{go};

    $self->{go}
        = Genome::Tabview::JSON::GO->new( -primary_id => $primary_id );
    $self->{go}->context( $self->context ) if $self->context;
    return $self->{go};
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
        -caption => $gene->name,
        -url     => "/gene/" . $gene->primary_id,
        -type    => 'outer',
    );
}

=head2 plasmids

 Title    : plasmids
 Usage    : $gene->plasmids();
 Function : returns array reference of plasmids for gene
 Returns  : array reference 
 Args     : none

=cut

sub plasmids {
    my ($self) = @_;
    return $self->source_feature->plasmids;
}

sub orthologs {
    my ($self) = @_;
    return $self->source_feature->orthologs;
}

sub topics_by_reference {
    my ( $self, $reference ) = @_;
    return $self->source_feature->topics_by_reference(
        $reference->source_reference );
}

1;

