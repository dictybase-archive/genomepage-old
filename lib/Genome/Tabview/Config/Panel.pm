
=head1 NAME

   B<Genome::Tabview::Config::Panel> - Class for handling Panel display

=head1 VERSION

    This document describes B<Genome::Tabview::Config::Panel> version 1.0.0

=head1 SYNOPSIS

    use Genome::Tabview::Config::Panel;
    my $panel  = Genome::Tabview::Config::Panel->new(
        -layout   => 'tabview',
        -position => 'center',
    );
    my $gene = Genome::Tabview::Config::Panel::Item::Tab->new(
        -key        => 'gene',
        -label      => 'Gene Summary',
        -active     => 'true',
        -primary_id => $primary_id,
    );
    $panel->add_item($gene);
    
=head1 DESCRIPTION

    B<Genome::Tabview::Config::Panel> Panel is a collections of display elements (items) together
    with layout information, such as "tabview","accordion", etc. 

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

Bio::Root::Root
Genome::Tabview::Config

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

package Genome::Tabview::Config::Panel;

use strict;
use Bio::Root::Root;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Config::Panel> object.
 Returns  : Genome::Tabview::Config::Panel object 
 Args     : -position: position of the panel inside of the parent element
            -layout     : layout to be applied to the panel items
            -type       : class to be assigned to each item of the panel
            -items      : reference to the array of Genome::Tabview::Config::Panel::Item 
                          implementing objects
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    $self->{root} = Bio::Root::Root->new();

    my $arglist = [qw/LAYOUT TYPE POSITION ITEMS/];
    my ( $layout, $type, $position, $items ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('layout is not provided') if !$layout;

    $self->layout($layout);
    $self->type($type)         if $type;
    $self->position($position) if $position;
    $self->items($items)       if $items;
    return $self;
}

=head2 layout

 Title    : layout
 Usage    : $panel->layout('accordion');
 Function : gets/sets inner layout for the panel
 Returns  : string
 Args     : string

=cut

sub layout {
    my ( $self, $arg ) = @_;
    $self->{layout} = $arg if defined $arg;
    $self->{root}->throw('Layout is not defined')
        if not defined $self->{layout};
    return $self->{layout};
}

=head2 type

 Title    : type
 Usage    : $item->type('title_class');
 Function : gets/sets type of the item
 Returns  : string
 Args     : string

=cut

sub type {
    my ( $self, $arg ) = @_;
    $self->{type} = $arg if defined $arg;
    return $self->{type};
}

=head2 position

 Title    : position
 Usage    : $panel->position('center');
 Function : gets/sets position of the panel
 Returns  : string
 Args     : string

=cut

sub position {
    my ( $self, $arg ) = @_;
    $self->{position} = $arg if defined $arg;
    return $self->{position};
}

=head2 items

 Title    : items
 Usage    : $panel->items(\@items);
 Function : gets/sets items of the panel
 Returns  : reference to the array of Genome::Tabview::Config::Panel::Item objects
 Args     : reference to the array of Genome::Tabview::Config::Panel::Item
            objects
=cut

sub items {
    my ( $self, $arg ) = @_;
    return $self->{items} if !$arg;
    $self->{root}->throw("Items should be array reference")
        if ref($arg) ne 'ARRAY';
    foreach my $item (@$arg) {
        $self->add_item($item);
    }
    return $self->{items};
}

=head2 add_item

 Title    : add_item
 Usage    : $panel->add_item($item);
 Function : adds item to the panel
 Returns  : string
 Args     : Genome::Tabview::Config::Panel::Item implementing object

=cut

sub add_item {
    my ( $self, $arg ) = @_;
    return if !$arg;
    $self->{root}->throw(
        "Item should be Genome::Tabview::Config::Panel::Item implementing object"
    ) if ref($arg) !~ 'Genome::Tabview::Config::Panel::Item';
    push @{ $self->{items} }, $arg;
    return;
}

=head2 to_json

 Title     : to_json 
 Usage     : $panel->to_json();
 Function  : returns hash representation of the panel ready for the json transformation 
 Returns   : hash 
 Args      : none
 
=cut

sub to_json {
    my ( $self, @args ) = @_;
    my $items;
    $self->{root}->throw('No items found for the panel') if !$self->items;
    foreach my $item ( @{ $self->items } ) {
        push @$items, $item->to_json;
    }
    my $panel;
    $panel->{layout}   = $self->layout;
    $panel->{position} = $self->position if $self->position;
    $panel->{items}    = $items;
    return $panel;
}

=head2 add_table_item

 Title    : add_table_item
 Usage    : $panel->add_table_item($table);
 Function : gets/sets layout
 Returns  : string
 Args     : string

=cut

sub add_table_item {
    my ( $self, $item ) = @_;
    push @{ $self->{items} }, $item;
    return $self;
}

1;

