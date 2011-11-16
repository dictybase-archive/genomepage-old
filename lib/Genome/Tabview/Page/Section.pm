
=head1 NAME

   B<Genome::Tabview::Page::Section> - Class for handling section display

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Section> version 1.0.0

=head1 SYNOPSIS

    use base /Genome::Tabview::Page::Section/;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Section> provides common interface for TabView sections.

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

package Genome::Tabview::Page::Section;

use strict;
use namespace::autoclean;
use Carp;
use Moose;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::Config::Panel::Item;
use Genome::Tabview::Config::Panel::Item::JSON;
use Genome::Tabview::Config::Panel::Item::Column;
use Genome::Tabview::Config::Panel::Item::Row;


=head2 section

 Title    : section
 Usage    : $section->section('gene_info');
 Function : gets/sets section
 Returns  : string
 Args     : string

=cut

=head2 base_url

 Title    : base_url
 Usage    : $page->base_url('purpureum');
 Function : gets/sets base_url
 Returns  : string
 Args     : string

=cut

=head2 json

 Title    : json
 Usage    : $self->json->link(....);
 Function : gets/sets json handler. Uses Genome::Tabview::Config::Panel::Item::JSON as default one
 Returns  : Genome::Tabview::Config::Panel::Item::JSON
 Args     : JSON handler class instance

=cut

has 'primary_id' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);



has 'base_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_base_url'
);

before 'base_url' => sub {
    my ($self) = @_;
    croak "context attribute need to be set\n" if !$self->has_context;
};

sub _build_base_url {
    my ($self) = @_;
    return $self->context->url_to;
}

for my $attr(qw/section tab/) {
	has $attr => (is => 'rw',  isa => 'Str',  predicate => 'has_'.$attr);
}

has 'context' => (
    is        => 'rw',
    isa       => 'Mojolicious::Controller',
    predicate => 'has_context'
);

has 'model' =>
    ( is => 'rw', isa => 'Bio::Chado::Schema', predicate => 'has_model' );

has 'config' => ( is => 'rw', isa => 'Genome::Tabview::Config' );

has 'json' => (
    is      => 'rw',
    isa     => 'Genome::Tabview::Config::Panel::Item::JSON',
    lazy    => 1,
    default => sub { Genome::Tabview::Config::Panel::Item::JSON->new }
);


=head2 process

 Title    : process
 Usage    : $section->process();
 Function : returns section as a json string
 Returns  : string
 Args     : string

=cut

sub process {
    my ( $self, @args ) = @_;
    $self->init;
    my $config = $self->config;
    return $config->to_json;
}

=head2 feature

 Title    : feature
 Usage    : $section->feature($feature);
 Function : gets/sets feature
 Returns  : Genome::Tabview::Page::JSON::Feature object
 Args     : Genome::Tabview::Page::JSON::Feature object

=cut

has 'feature' => ( is => 'rw', isa => 'Genome::Tabview::JSON::Feature' );

=head2 gene

 Title    : gene
 Usage    : $section->gene($gene);
 Function : gets/sets gene
 Returns  : Genome::Tabview::JSON::Feature::GeneGene object
 Args     : Genome::Tabview::JSON::Feature::Gene object

=cut

has 'gene' => ( is => 'rw', isa => 'Genome::Tabview::JSON::Feature::Gene' );

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
        layout => 'column',
        items  => $self->columns(@column_data)
    );
    my $item = Genome::Tabview::Config::Panel::Item::Row->new(
        content => [$column_panel] );
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
    my $columns;
    for my $i (0 .. $#column_data) {
        my $json_panel = $self->json_panel($column_data[$i]);
        my $class = $i == 0 ? 'content_table_title' : undef;
        push @$columns,
            Genome::Tabview::Config::Panel::Item::Column->new(
            type    => $class,
            content => [$json_panel],
            );
    }
    return $columns;
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
            my $item =
                $json_item->new( content => $self->json->text($element) );
            push @json_items, $item;
        }
        else {
            my $item = $json_item->new( content => $element );
            push @json_items, $item;
        }
    }
    my $json_panel = Genome::Tabview::Config::Panel->new(
        layout => 'json',
        _items  => \@json_items,
    );
    return $json_panel;
}

before 'gene' => sub {
	my ($self) = @_;
	croak "model attribute need to set\n" if !$self->has_model;
};

__PACKAGE__->meta->make_immutable;

1;
