
=head1 NAME

   B<Genome::Tabview::Config::Panel::Item::Tab> - Class for handling tabview panel items

=head1 VERSION

    This document describes B<Genome::Tabview::Config::Panel::Item::Tab> version 1.0.0

=head1 SYNOPSIS

    my $panel  = Genome::Tabview::Config::Panel->new(
        layout   => 'tabview',
        position => 'center',
    );
    my $gene = Genome::Tabview::Config::Panel::Item::Tab->new(
        key        => 'gene',
        label      => 'Gene Summary',
        active     => 'true',
        source     => '/db/cgi-bin/dictyBase/yui/tab.pl?&tab=go&primary_id=<GENE ID>'
    );
    $panel->add_item($gene);
    
=head1 DESCRIPTION

    B<Genome::Tabview::Config::Panel::Item::Tab> Represents single tab on panel with 
    tabview layout

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

Bio::Root::Root

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

package Genome::Tabview::Config::Panel::Item::Tab;

use namespace::autoclean;
use Mouse;

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

=head2 active

 Title    : active
 Usage    : $item->active('true');
 Function : gets/sets active parameter of the item
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

=head2 href

 Title    : href
 Usage    : $item->href('feature/DDB1234567');
 Function : gets/sets href of the item
 Returns  : string
 Args     : string

=cut

=head2 dispatch

 Title    : dispatch
 Usage    : $item->dispatch('true');
 Function : gets/sets dispatch of the item
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

has [qw/key label/] => ( is => 'rw', isa => 'Str', required => 1 );
has 'source' => ( is => 'rw', isa => 'Str' );
has 'content' => (
    is         => 'rw',
    isa        => 'ArrayRef[Genome::Tabview::Config::Panel]',
    auto_deref => 1
);
has [qw/active type href dispatch/] => ( is => 'rw', isa => 'Str' );

=head2 to_json

 Title    : to_json 
 Usage    : $panel->to_json();
 Function : returns json representation of the item 
 Returns  : string 
 Args     : none
    
=cut

sub to_json {
    my ($self) = @_;
    my $item;
    $item->{key}   = $self->key;
    $item->{label} = $self->label;
    $item->{active} = $self->active eq 'true' ? 1 : 0;
    for my $tag (qw/source type href dispatch/) {
        $item->{$tag} = $self->$tag if $self->$tag;
    }
    if ( $self->content ) {
        foreach my $panel ( $self->content ) {
            push @{ $item->{content} }, $panel->to_json;
        }
    }
    return $item;
}

__PACKAGE__->meta->make_immutable;

1;

