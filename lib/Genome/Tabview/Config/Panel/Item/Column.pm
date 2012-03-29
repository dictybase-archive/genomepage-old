
=head1 NAME

   B<Genome::Tabview::Config::Panel::Item::Column> - Class for handling row panel items 

=head1 VERSION

    This document describes B<Genome::Tabview::Config::Panel::Item::Column> version 1.0.0

=head1 SYNOPSIS

    use Genome::Tabview::Config::Panel::Item::Column;
    my $item = Genome::Tabview::Config::Panel::Item::Column->new(
            -type   => 'content_table_title',
            -content => [{"text":"Gene Name"}],
    );
    
=head1 DESCRIPTION

    B<Genome::Tabview::Config::Panel::Item::Column> Item reperesents single element of panel 
    having type, cospan and content properties.
    
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

package Genome::Tabview::Config::Panel::Item::Column;

use strict;
use namespace::autoclean;
use Mouse;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Config::Panel::Item::Column> object.
 Returns  : Genome::Tabview::Config::Panel::Item::Column object 
 Args     : -type    : class to be assigned to the element
            -rowspan : number of columns a row should take up
            -content : If defined should contain elements to display inside the tab as a
                          reference to an array of Genome::Tabview::Config::Panel objects.
 
=cut

=head2 content

 Title    : key
 Usage    : $item->content(\@panels);
 Function : gets/sets content of the item
 Returns  : reference to an array of Genome::Tabview::Config::Panel objects
 Args     : reference to an array of Genome::Tabview::Config::Panel objects

=cut

has 'content' => (
    is        => 'rw',
    isa       => 'ArrayRef',
    required  => 1,
    traits => [qw/Array/], 
    handles => {
    	'get_content' => 'get', 
    	'has_content' => 'count'
    }
);



=head2 type

 Title    : type
 Usage    : $item->type('title_class');
 Function : gets/sets type of the item
 Returns  : string
 Args     : string

=cut

has 'type' => ( isa => 'Str|Undef',  is => 'rw');

=head2 rowspan

 Title    : rowspan
 Usage    : $item->rowspan(3);
 Function : gets/sets number of rows a column should take up.
 Returns  : string
 Args     : string

=cut


=head2 colspan

 Title    : colspan
 Usage    : $item->colspan(3);
 Function : gets/sets number of columns a row should take up.
 Returns  : string
 Args     : string

=cut

has [qw/rowspan colspan/] => (is => 'rw',  isa => 'Maybe[Int]');

=head2 to_json

 Title    : to_json 
 Usage    : $panel->to_json();
 Function : returns json representation of panel 
 Returns  : string 
 Args     : none
    
=cut

sub to_json {
    my ( $self, @args ) = @_;
    my $item;
    $item->{type}    = $self->type    if $self->type;
    $item->{rowspan} = $self->rowspan if $self->rowspan;
    $item->{colspan} = $self->colspan if $self->colspan;
    if ( $self->content ) {
        foreach my $panel ( @{ $self->content } ) {
            push @{ $item->{content} }, $panel->to_json;
        }
    }
    return $item;
}

__PACKAGE__->meta->make_immutable;

1;
