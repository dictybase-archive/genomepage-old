
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
use namespace::autoclean;
use Mouse;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::Config::Panel::Item::JSON::Table;

extends 'Genome::Tabview::Page::Tab';

has 'binomial_array' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
    lazy       => 1,
    default    => sub {
        return [
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
    my $gene = Genome::Tabview::JSON::Feature::Gene->new(
        source_feature => $self->feature );

    my $table = Genome::Tabview::Config::Panel::Item::JSON::Table->new();
    $table->class('general');
    $table->add_column(
        key       => 'species',
        label     => 'Species',
        sortable  => 'true',
        width     => '190',
        formatter => 'grouper',
    );
    $table->add_column(
        key       => 'id',
        label     => 'ID',
        sortable  => 'true',
        width     => '140',
        formatter => 'grouper',
    );
    $table->add_column(
        key       => 'uniprot',
        label     => 'UniProtKB',
        sortable  => 'true',
        width     => '70',
        formatter => 'grouper',
    );
    $table->add_column(
        key       => 'product',
        label     => 'Gene product',
        sortable  => 'true',
        formatter => 'grouper',
    );
    $table->add_column(
        key       => 'source',
        label     => 'Source',
        sortable  => 'true',
        formatter => 'grouper',
    );

    my $ortholog_hash;
    my $source
        = $gene->ortholog_group->search_related( 'analysisfeatures', {} )
        ->search_related( 'analysis', {}, { 'rows' => 1 } )->single->program;
    ## -- $ortholog is a BCS::Sequence::Feature object
    foreach my $ortholog ( @{ $gene->orthologs } ) {
        my $name = $ortholog->uniquename;
        my $binomial = sprintf "%s %s", $ortholog->organism->genus,
            $ortholog->organism->species;
        my @dbxrefs
            = $ortholog->search_related( 'feature_dbxrefs', {} )
            ->search_related(
            'dbxref',
            { 'db.name' => { '!=', 'GFF_source' } },
            { join      => 'db' }
            );
        my $uniprot_links = [
            map {
                $self->json->link(
                    url     => $_->db->urlprefix . $_->accession,
                    caption => $_->accession,
                    type    => 'outer'
                    )
                } grep { $_->db->name eq 'DB:UniProtKB' } @dbxrefs
        ];
        my @all_pdts = map { $_->value } $ortholog->search_related(
            'featureprops',
            {   'type.name' => 'product',
                'cv.name'   => 'feature_property'
            },
            { join => [ { 'type' => 'cv' } ] }
        );
        my $product = join( ',', @all_pdts );

        $ortholog_hash->{$binomial}->{$name}->{linkout} = $self->json->link(
            url => $ortholog->dbxref->db->urlprefix
                . $ortholog->dbxref->accession,
            caption => $name,
            type    => 'outer'
        );
        $ortholog_hash->{$binomial}->{$name}->{uniprot} = $uniprot_links
            if @$uniprot_links;
        $ortholog_hash->{$binomial}->{$name}->{product} = $product
            if $product;
        push @{ $ortholog_hash->{$binomial}->{$name}->{source} }, $source;
    }

BINOMIAL:
    foreach my $binomial ( $self->binomial_array ) {
        next BINOMIAL if not exists $ortholog_hash->{$binomial};
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
    my $panel  = Genome::Tabview::Config::Panel->new( layout => 'json' );
    my $item   = Genome::Tabview::Config::Panel::Item::JSON->new(
        type    => 'orthologs_table',
        content => $table->structure,
    );

    $panel->add_item($item);
    $config->add_panel($panel);
    $self->config($config);
    return $self;
}

__PACKAGE__->meta->make_immutable;

1;
