
=head1 NAME

   B<Genome::Tabview::Page::Section::Gene> - Class for handling section information retrivial for gene tab 

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Section::Gene> version 1.0.0

=head1 SYNOPSIS

    my $section = Genome::Tabview::Page::Section::Gene->new( 
        -primary_id => <GENE ID>, 
        -section => 'info',
    );
    my $json = $section->process();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Section::Gene> handles section information retrivial for gene tab.
    Expects if feature id had been passed instead of gene id, guesses for the corresponding gene.

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

package Genome::Tabview::Page::Section::Gene;

use strict;
use namespace::autoclean;
use Carp;
use Moose;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::Config::Panel::Item::Tab;

extends 'Genome::Tabview::Page::Section';

has '+gene' => (
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $row
            = $self->model->resultset('Sequence::Feature')
            ->search( { 'dbxref.accession' => $self->primary_id },
            { rows => 1, join => 'dbxref' } )->single;
        return Genome::Tabview::JSON::Feature::Gene->new(
            source_feature => $row );
    }
);

=head2 init

 Title    : init
 Function : initializes the section.
 Usage    : $section->init();
 Returns  : nothing
 Args     : none
 
=cut

sub init {
    my ($self)   = @_;
    my $section  = $self->section;
    my $settings = {
        info         => sub { $self->info(@_) },
        genomic_info => sub { $self->genomic_info(@_) },
        product      => sub { $self->product(@_) },
        sequences    => sub { $self->sequences(@_) },
        links        => sub { $self->links(@_) },
        references   => sub { $self->references(@_) },
    };
    my $config = $settings->{$section}->();
    $self->config($config);
    return $self;
}

=head2 info

 Title    : info
 Function : returns gene general information section data
 Usage    : $json = $section->info();
 Returns  : array reference
 Args     : none
 
=cut

sub info {
    my ($self) = @_;
    my $gene = $self->gene;

    # the coordinates section contains the notes directly under
    # gbrowse.  Since many features do not contain a gbrowse image
    # we display the notes here, in the general_information section

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( layout => 'row' );

    ## -- collect section rows
    my @rows;
    push @rows, $self->row( 'Gene Name',    $gene->name );
    push @rows, $self->row( 'Gene ID',      $gene->primary_id );
    push @rows, $self->row( 'Gene Product', $gene->gene_products )
        if $gene->gene_products;
    push @rows, $self->row( 'Community Annotations', $gene->wiki_links );
    $panel->items( \@rows );
    $config->add_panel($panel);
    return $config;
}

=head2 genomic_info

 Title    : genomic_info
 Function : returns gene genomic information section data
 Usage    : $json = $section->genomic_info();
 Returns  : array
 Args     : none
 
=cut

sub genomic_info {
    my ($self) = @_;
    my $gene = $self->gene;

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( layout => 'row' );

    my $gbrowse_link = $gene->gbrowse_link;
    my $gbrowse_text = $self->json->text(
        '[Click on the map to browse the genome from this location]<br>');
    my @gbrowse = ( $gbrowse_text, $gbrowse_link );

    ## -- collect section rows
    my @rows;
    push @rows, $self->row( 'Location',    $gene->location );
    push @rows, $self->row( 'Genomic Map', \@gbrowse );
    $panel->items( \@rows );
    $config->add_panel($panel);
    return $config;
}

=head2 product

 Title    : gene_product
 Function : returns gene product section data
 Usage    : $json = $section->gene_product();
 Returns  : reference to array
 Args     : none
 
=cut

sub product {
    my ($self) = @_;
    my $gene   = $self->gene;
    my $config = Genome::Tabview::Config->new();

    my @panels;
    my @primary_ids;
    foreach my $feature ( $gene->transcripts ) {
        my $panel = Genome::Tabview::Config::Panel->new( layout => 'row' );
        my $rows = $self->product_coordinates($feature);
        $panel->items($rows);
        push @panels,      $panel;
        push @primary_ids, $feature->source_feature->dbxref->accession;
    }
    return $config->add_panel( $panels[0] ) if scalar @panels == 1;

    my $tab_panel = Genome::Tabview::Config::Panel->new(
        layout => 'tabview',
        type   => 'isoform-tab'
    );
    my @alphabet = ( 'A' .. 'Z' );
    for my $i ( 0 .. $#panels ) {
        my $item = Genome::Tabview::Config::Panel::Item::Tab->new(
            key     => 'product_isoform',
            label   => 'Splice Variant ' . $alphabet[$i],
            content => [ $panels[$i] ],
            href    => $self->context->url_to(
                $gene->source_feature->dbxref->accession, 'feature',
                $primary_ids[$i]
            )
        );
        $tab_panel->add_item($item);
    }
    return $config->add_panel($tab_panel);
}

=head2 product_coordinates

 Title    : product_coordinates
 Function : returns gene product info with coordinate table
 Usage    : $row = $section->product_coordinates();
 Returns  : reference to an array of Genome::Tabview::Config::Item::Row objects with row layout
 Args     : dicty::Feature
 
=cut

sub product_coordinates {
    my ( $self, $feature ) = @_;
    my @rows;

    ## -- a bit complicated panel with four columns, two of each have rowspan = 5
    my $panel = Genome::Tabview::Config::Panel->new( layout => 'column' );
    my $column_item = 'Genome::Tabview::Config::Panel::Item::Column';
    my $row_item    = 'Genome::Tabview::Config::Panel::Item::Row';

    my @feature_data
        = ( $feature->feature_tab_link( base_url => $self->base_url ), );

    my @columns;
    push @columns, @{ $self->columns( $feature->gene_type, \@feature_data ) };
    if ( !$feature->pseudogene ) {
        push @columns,
            $column_item->new(
            type    => 'content_table_second_title',
            rowspan => 5,
            content => [ $self->json_panel('Genomic Coordinates') ],
            );
        push @columns,
            $column_item->new(
            rowspan => 5,
            content => [ $self->json_panel( $feature->coordinate_table ) ],
            );
    }
    $panel->items( \@columns );
    my $row = $row_item->new( content => [$panel] );

    push @rows, $row;

    my $length_row
        = $feature->protein
        ? $self->row( 'Protein Length', $feature->protein->length )
        : $feature->transcript ? $self->row( 'Transcript Sequence Length',
        $feature->transcript_length )
        : $feature->pseudogene ? $self->row( 'Pseudogene Sequence Length',
        $feature->pseudogene_length )
        : undef;
    push @rows, $length_row if $length_row;

    if ( $feature->protein ) {
        push @rows,
            $self->row(
            'Protein Molecular Weight',
            $feature->protein->molecular_weight
            ),
            $self->row( 'More Protein Data',
            $feature->protein->protein_tab_link( $self->base_url ) );
    }

    push @rows,
        $self->row( 'Sequence',
        $feature->get_fasta_selection( -base_url => $self->base_url ) );

    return \@rows;
}

=head2 sequences

 Title    : sequences
 Function : returns gene associated sequences section config
 Usage    : $config = $section->sequences();
 Returns  : Genome::Tabview::Config
 Args     : none
 
=cut

sub sequences {
    my ($self) = @_;
    my $gene   = $self->gene;
    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( layout => 'row' );
    my @rows;
    if ( my $ests = $gene->ests ) {
        my @rows;
        push @rows, $self->row( 'ESTs', $ests );
        $panel->items( \@rows );
        $config->add_panel($panel);
        return $config;
    }
}

=head2 links

 Title    : links
 Function : returns gene links section config, including 
            external databases, researchers, pathway and expression lins
 Usage    : $config = $section->links();
 Returns  : Genome::Tabview::Config
 Args     : none
 
=cut

sub links {
    my ( $self ) = @_;
    my $gene   = $self->gene;
    my $config = Genome::Tabview::Config->new();
    my $panel  = Genome::Tabview::Config::Panel->new( layout => 'row' );
    my @rows;
    if ( my $row = $gene->external_links ) {
        $panel->items( [ $self->row( 'External Resources', $row ) ] );
        $config->add_panel($panel);
        return $config;
    }
}

=head2 references

 Title    : references
 Function : returns json formatted gene latest references
 Usage    : $config = $section->references();
 Returns  : Genome::Tabview::Config
 Args     : none
 
=cut

sub references {
    my ($self) = @_;
    my $gene   = $self->gene;
    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( layout => 'row' );

    my $count = 0;
    my @rows;
    return if !$gene->references;
    foreach my $reference ( @{ $gene->references } ) {
        last if ( $count++ == 5 );
        push @rows, $self->row( $reference->links, $reference->citation );
    }
    $panel->items( \@rows );
    $config->add_panel($panel);
    return $config;
}

1;
