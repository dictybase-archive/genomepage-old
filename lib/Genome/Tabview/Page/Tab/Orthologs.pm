
=head1 NAME

   B<Genome::Tabview::Page::Tab::Orthologs> - Class for handling gene orthologs tab configuration 

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Tab::Orthologs> version 1.0.0

=head1 SYNOPSIS

    my $tab = Genome::Tabview::Page::Tab::Orthologs->new( -primary_id => <GENE ID> );
    my $json = $tab->configure();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Tab::Orthologs> handles gene orthologs tab display.
    

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

package Genome::Tabview::Page::Tab::Orthologs;

use strict;
use Bio::Root::Root;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::Config::Panel::Item::JSON::Table;

use base qw( Genome::Tabview::Page::Tab );

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::Tab::Orthologs> object. 
            Sets templates and configuration parameters for tabs to be displayed
 Usage    : my $tab = Genome::Tabview::Page::Tab::Orthologs->new( -primary_id => 'DDB_GXXXXXX' );
 Returns  : Genome::Tabview::Page::Tab::Orthologs object with default configuration.
 Args     : gene primary id
 
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/PRIMARY_ID BASE_URL/];

    $self->{root} = Bio::Root::Root->new();
    my ( $primary_id, $base_url ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;

    my $feature = dicty::Feature->new( -primary_id => $primary_id );
    $self->feature($feature);
    $self->base_url($base_url) if $base_url;
    return $self;
}

=head2 init

 Title    : init
 Function : initializes the tab. Sets tab configuration parameters
 Usage    : $tab->init();
 Returns  : nothing
 Args     : none
 
=cut

sub init {
    my ($self) = @_;
    my $gene = Genome::Tabview::JSON::Feature::Gene->new(
        -primary_id => $self->feature->primary_id );

    my $table = Genome::Tabview::Config::Panel::Item::JSON::Table->new();
    $table->class('general');
    $table->add_column(
        -key       => 'species',
        -label     => 'Species',
        -sortable  => 'true',
        -width     => '190',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'id',
        -label     => 'ID',
        -sortable  => 'true',
        -width     => '140',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'uniprot',
        -label     => 'UniProtKB',
        -sortable  => 'true',
        -width     => '70',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'product',
        -label     => 'Gene product',
        -sortable  => 'true',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'source',
        -label     => 'Source',
        -sortable  => 'true',
        -formatter => 'grouper',
    );

    my $ortholog_hash;
    foreach my $ortholog ( @{ $gene->orthologs } ) {
        my $binomial   = $ortholog->organism->binomial;
        my $collection = $ortholog->get_dbxref('UniProtKB');
        my @uniprot_links =
            map {
            $self->json->link(
                -url =>
                    Genome::Tabview::JSON::Feature::Gene->link('UniProt')
                    ->get_links( $_->primary_id ),
                -caption => $_->primary_id,
                -type    => 'outer'
                )
            } $collection->get_Annotations('dblink');

        my $product = join( ', ',
            map { $_->product_name } @{ $ortholog->gene_products } );

        my $source = $ortholog->source;
        $source .= ' protein ' . $ortholog->organism->common_name
            if $ortholog->source =~ m{ensembl}i;

        my $link =
              $ortholog->source =~ m{dictyBase}
            ? $ortholog->primary_id
            : $ortholog->name;

        $ortholog_hash->{$binomial}->{ $ortholog->name }->{linkout} =
            $self->json->link(
            -url => Genome::Tabview::JSON::Feature::Gene->link($source)
                ->get_links($link),
            -caption => $ortholog->name,
            -type    => 'outer'
            );
        $ortholog_hash->{$binomial}->{ $ortholog->name }->{uniprot} =
            \@uniprot_links;
        $ortholog_hash->{$binomial}->{ $ortholog->name }->{product} =
            $product;
        push
            @{ $ortholog_hash->{$binomial}->{ $ortholog->name }->{source} },
            $ortholog->{algorithm};
    }

    my $binomial_array = [
        'Dictyostelium discoideum',
        'Dictyostelium purpureum',
        'Homo sapiens',
        'Mus musculus',
        'Saccharomyces cerevisiae S288c',
        'Drosophila melanogaster',
        'Caenorhabditis elegans',
        'Escherichia coli K-12',
        'Arabidopsis thaliana',
    ];

    foreach my $binomial (@$binomial_array) {
        next if !exists $ortholog_hash->{$binomial};
        foreach my $id ( keys %{ $ortholog_hash->{$binomial} } ) {
            my $ortholog = $ortholog_hash->{$binomial}->{$id};
            my $data     = {
                species => [ $self->json->text($binomial) ],
                uniprot => $ortholog->{uniprot},
                id      => [ $ortholog->{linkout} ],
                product =>
                    [ $self->json->text( $ortholog->{product} || ' ' ) ],
                source => [ $self->json->text( $ortholog->{source} ) ],
            };
            $table->add_record($data);
        }
    }

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'json' );

    my $item = Genome::Tabview::Config::Panel::Item::JSON->new(
        -type    => 'orthologs_table',
        -content => $table->structure,
    );

    $panel->add_item($item);
    $config->add_panel($panel);
    $self->config($config);
    return $self;
}

1;
