
=head1 NAME

   B<Genome::Tabview::Page::Tab::References> - Class for handling gene References tab configuration 

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Tab::References> version 1.0.0

=head1 SYNOPSIS

    my $tab = Genome::Tabview::Page::Tab::References->new( -primary_id => <GENE ID> );
    my $json = $tab->configure();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Tab::References> handles gene References tab display.
    

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

package Genome::Tabview::Page::Tab::References;

use strict;
use Bio::Root::Root;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::Config::Panel::Item::Row;
use Genome::Tabview::Config::Panel::Item::Column;
use Genome::Tabview::Config::Panel::Item::JSON::Tree;
use Genome::Tabview::Config::Panel::Item::JSON::Table;
use Modware::DataSource::Chado;
use base qw( Genome::Tabview::Page::Tab );

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::Tab::References> object. 
            Sets templates and configuration parameters for tabs to be displayed
 Usage    : my $tab = Genome::Tabview::Page::Tab::References->new( -primary_id => 'DDB0185055' );
 Returns  : Genome::Tabview::Page::Tab::References object with default configuration.
 Args     : feature primary id
 
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/PRIMARY_ID BASE_URL CONTEXT/];

    $self->{root} = Bio::Root::Root->new();
    my ( $primary_id, $base_url, $context )
        = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;

    my $feature = dicty::Feature->new( -primary_id => $primary_id );
    $self->feature($feature);
    $self->inner_id( rand(200) );
    $self->base_url($base_url) if $base_url;
    $self->context($context)   if $context;
    return $self;
}

=head2 inner_id

 Title    : inner_id
 Usage    : $tab->inner_id(12345);
 Function : gets/sets tab inner id, that will be aplied as a prefix to tab elements
 Returns  : string
 Args     : string

=cut

sub inner_id {
    my ( $self, $arg ) = @_;
    $self->{inner_id} = $arg if defined $arg;
    $self->{root}->throw('inner_id is not defined')
        if not defined $self->{inner_id};
    return $self->{inner_id};
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

    my $config = Genome::Tabview::Config->new();

    my $column_panel = Genome::Tabview::Config::Panel->new(
        -layout => 'column',
        -items  => [ $self->topic_tree, $self->references_info ],
    );
    $config->add_panel($column_panel);
    $self->config($config);
    return $self;
}

=head2 topic_tree

 Title    : topic_tree
 Function : Returns Genome::Tabview::Config::Panel::Item::Column with 
            tree structure containing topics fo gene references
 Usage    : my $item = $tab->topic_tree;
 Returns  : Genome::Tabview::Config::Panel::Item::Column
 Args     : none
 
=cut

sub topic_tree {
    my ($self) = @_;
    my $gene = $self->feature;

    my $tree = Genome::Tabview::Config::Panel::Item::JSON::Tree->new(
        -action   => 'filter',
        -argument => $self->inner_id . '_table'
    );

    ## get topics by category
    my $schema     = Modware::DataSource::Chado->handler;
    my $root_topic = $schema->resultset('Cv::Cvterm')->find(
        {   'cvterm_relationship_subjects.subject_id' => undef,
            'is_obsolete'                             => 0,
            'is_relationshiptype'                     => 0,
            'cv.name' => 'dictyBase_literature_topic'
        },
        { join => [ 'cvterm_relationship_subjects', 'cv' ] }
    );
    my $topics;
    foreach
        my $group ( $root_topic->search_related('cvterm_relationship_objects')
        ->search_related('subject')->all )
    {
        push @{ $topics->{ $group->name } },
            map { $_->name }
            $group->search_related('cvterm_relationship_objects')
            ->search_related( 'subject',
            { name => { '-in' => $gene->topics } } )->all;
    }

    foreach my $topic_class ( keys %$topics ) {
        next if @{ $topics->{$topic_class} } == 0;

        my @child_nodes;
        foreach my $topic ( @{ $topics->{$topic_class} } ) {
            push @child_nodes,
                $tree->node(
                -type  => 'text',
                -label => $topic,
                -title => 'Click to show only papers with ' 
                    . $topic
                    . ' topic',
                );
        }
        my $node = $tree->node(
            -type     => 'text',
            -label    => '<b>' . $topic_class . '</b>',
            -expanded => 'true',
            -children => \@child_nodes,
        ) if $topic_class;
        $tree->add_node($node);
    }
    if ( grep { !$gene->topics_by_reference($_) } @{ $gene->references } ) {
        my $node = $tree->node(
            -type  => 'text',
            -label => 'Not yet curated',
            -title => 'Click to show only not yet curated papers',
        );
        $tree->add_node($node);
    }
    my $column = Genome::Tabview::Config::Panel::Item::Column->new(
        -type    => 'content_table_title',
        -content => [ $self->json_panel( $tree->structure ) ],
    );
    return $column;
}

=head2 references_info

 Title    : references_info
 Function : Returns Genome::Tabview::Config::Panel::Item::Column with 
            rows containing references info
 Usage    : my $item = $tab->references_info;
 Returns  : Genome::Tabview::Config::Panel::Item::Column
 Args     : none
 
=cut

sub references_info {
    my ($self) = @_;

    my $gene = $self->feature;
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    my @references = @{ $gene->references };
    my $not_curated = grep { !$gene->topics_by_reference($_) } @references;

    my @rows;
    push @rows,
        $self->row( 'This page displays all the papers associated with '
            . $self->feature->name
            . ' in dictyBase, along with all the literature topics those papers address. Click on a topic on the left to see the papers that address it.'
        );
    push @rows,
        $self->row( 'Curated references: ' . ( @references - $not_curated ) );
    push @rows, $self->row( 'References not yet curated: ' . $not_curated );
    push @rows, $self->reference_table;
    $panel->items( \@rows );

    my $column = Genome::Tabview::Config::Panel::Item::Column->new(
        -content => [$panel] );
    return $column;
}

=head2 reference_table

 Title    : reference_table
 Function : Returns Genome::Tabview::Config::Panel::Item::Row with 
            table structure containing gene references
 Usage    : my $item = $tab->reference_table;
 Returns  : Genome::Tabview::Config::Panel::Item::Row
 Args     : none
 
=cut

sub reference_table {
    my ($self) = @_;

    my $primary_id = $self->feature->primary_id;
    my $gene       = Genome::Tabview::JSON::Feature::Gene->new(
        -primary_id => $primary_id );
	$gene->context($self->context) if $self->context;
	

    my $table = Genome::Tabview::Config::Panel::Item::JSON::Table->new(
        -id        => $self->inner_id . '_table',
        -filter    => 'true',
        -paginator => 'true'
    );

    $table->class('general');
    $table->add_column(
        -key      => 'ref',
        -label    => 'Reference',
        -sortable => 'true',
    );
    $table->add_column(
        -key      => 'ref_link',
        -label    => ' ',
        -sortable => 'false',
        -width    => '140',
    );
    $table->add_column(
        -key      => 'genes',
        -label    => 'Other Genes Addressed',
        -width    => '200',
        -sortable => 'true',
    );
    $table->add_column(
        -key    => 'topics',
        -label  => '',
        -hidden => 'true'
    );

    foreach my $reference ( @{ $gene->references } ) {
        my @gene_links = map { $_->gene_link }
            grep { $_->source_feature->primary_id ne $primary_id }
            @{ $reference->genes(7) };

        if ( scalar @gene_links >= 6 ) {
            my $more_link = $self->json->link(
                -caption => 'more..',
                -url => "/db/cgi-bin/dictyBase/reference/reference.pl?refNo="
                    . $reference->source_reference->pub_id
                    . '#summary',
                -type  => 'outer',
                -style => 'font-weight: bold; color: #CC0000',
            );
            push @gene_links, $more_link;
        }
        my $topics = $gene->topics_by_reference($reference)
            || ['Not yet curated'];

        my $data = {
            ref      => [ $reference->citation ],
            genes    => \@gene_links,
            ref_link => $reference->links,
            topics   => [ $self->json->text( join( ',', @{$topics} ) ) ]
        };
        $table->add_record($data);
    }
    my $reference_table_row
        = Genome::Tabview::Config::Panel::Item::Row->new(
        -content => [ $self->json_panel( $table->structure ) ],
        -colspan => 2
        );

    return $reference_table_row;
}

=head2 row

 Title    : row
 Function : returns Genome::Tabview::Config::Panel object with "column" layout, 
            and items each of each is a Genome::Tabview::Config::Panel object with 
            "simple" layout with and column data items. First column would have "title" class 
            that would result in different display.
 Usage    : $row = $section->row(@elements);
 Returns  : Genome::Tabview::Config::Panel object
 Args     : array of items to put into columns inside the row
 
=cut

sub row {
    my ( $self, @column_data ) = @_;
    my $column_panel = Genome::Tabview::Config::Panel->new(
        -layout => 'column',
        -items  => $self->columns(@column_data)
    );
    my $item = Genome::Tabview::Config::Panel::Item::Row->new(
        -content => [$column_panel] );
    return $item;
}

=head2 columns

 Title    : columns
 Function : returns reference to an array of Genome::Tabview::Config::Panel::Item::JSON
            objects containing column data. First column would have "title" class 
            that would result in different display.
 Usage    : $columns = $section->columns(@elements);
 Returns  : Genome::Tabview::Config::Panel object
 Args     : array of items to put into columns inside the row
 
=cut

sub columns {
    my ( $self, @column_data ) = @_;
    my @columns;
    my $i = 0;
    foreach my $column (@column_data) {
        my $json_panel = $self->json_panel($column);
        push @columns,
            Genome::Tabview::Config::Panel::Item::Column->new(
            -content => [$json_panel], );
        $i = 1;
    }
    return \@columns;
}

=head2 json_panel

 Title    : json_panel
 Function : returns Genome::Tabview::Config::Panel with json layout. 
            If string have been passed, converts it into json text structure, 
            otherwise keeps passed object "as is"
 Usage    : $panel = $section->json_panel($data);
 Returns  : Genome::Tabview::Config::Panel object
 Args     : string or array of json preformatted hashes
 
=cut

sub json_panel {
    my ( $self, $rawdata ) = @_;
    my $data = ref($rawdata) eq 'ARRAY' ? $rawdata : [$rawdata];
    my $json_item = 'Genome::Tabview::Config::Panel::Item::JSON';
    my @json_items;
    foreach my $element (@$data) {
        my $ref = \$element;
        if ( ref($ref) eq 'SCALAR' ) {
            my $item
                = $json_item->new( -content => $self->json->text($element) );
            push @json_items, $item;
        }
        else {
            my $item = $json_item->new( -content => $element );
            push @json_items, $item;
        }
    }
    my $json_panel = Genome::Tabview::Config::Panel->new(
        -layout => 'json',
        -items  => \@json_items,
    );
    return $json_panel;
}

1;
