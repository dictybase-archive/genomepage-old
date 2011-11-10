
=head1 NAME

   B<Genome::Tabview::Config::Panel::Item::Accordion> - Class for handling accordion panel items
=head1 VERSION

    This document describes B<Genome::Tabview::Config::Panel::Item::Accordion> version 1.0.0

=head1 SYNOPSIS

    my $panel  = Genome::Tabview::Config::Panel->new(
        -layout   => 'accordion',
        -position => 'center',
    );
    my $info = Genome::Tabview::Config::Panel::Item::Accordion->new(
        -key   => 'info',
        -label => $self->simple_label("General Information"),
        -source => '/db/cgi-bin/dictyBase/yui/section.pl?&tab=gene&section=info&primary_id=<GENE ID>'
    );
    $panel->add_item($info);
    
=head1 DESCRIPTION

    B<Genome::Tabview::Config::Panel::Item::Accordion> Represents single accordion element 
    on panel with accordion layout

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

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

package Genome::Tabview::Config::Panel::Item::Accordion;

use strict;
use namespace::autoclean;
use Moose;

=head2 key

 Title    : key
 Usage    : $item->key('go');
 Function : gets/sets key of the item
 Returns  : string
 Args     : string

=cut

=head2 label

 Title    : label
 Usage    : $item->label('GO Annotations');
 Function : gets/sets label of the item
 Returns  : string
 Args     : string

=cut

=head2 source

 Title    : source
 Usage    : $item->source('/db/cgi-bin/dictyBase/yui/tab.pl?&tab=gene&primary_id=<GENE ID>');
 Function : gets/sets source of the item
 Returns  : string
 Args     : string

=cut

=head2 type

 Title    : type
 Usage    : $item->type('title_class');
 Function : gets/sets type of the item
 Returns  : string
 Args     : string

=cut

=head2 content

 Title    : key
 Usage    : $item->content(\@panels);
 Function : gets/sets content of the item
 Returns  : reference to an array of Genome::Tabview::Config::Panel objects
 Args     : reference to an array of Genome::Tabview::Config::Panel objects

=cut


has 'key' => ( is => 'rw', isa => 'Str', required => 1 );
has 'label' => ( is => 'rw', isa => 'ArrayRef', required => 1 );
has [qw/source type/] => ( is => 'rw', isa => 'Str' );
has 'content' => (
    is         => 'rw',
    isa        => 'ArrayRef[Genome::Tabview::Config::Panel]',
    auto_deref => 1
);

=head2 to_json

 Title    : to_json 
 Usage    : $panel->to_json();
 Function : returns json representation of panel 
 Returns  : string 
 Args     : none
    
=cut

sub to_json {
    my ( $self) = @_;
    my $item;
    $item->{key}    = $self->key;
    $item->{label}  = $self->label if $self->label;
    $item->{source} = $self->source if $self->source;
    $item->{type}   = $self->type if $self->type;
    if ( $self->content ) {
        foreach my $panel ( $self->content ) {
            push @{ $item->{content} }, $panel->to_json;
        }
    }
    return $item;
}

__PACKAGE__->meta->make_immutable;

1;

