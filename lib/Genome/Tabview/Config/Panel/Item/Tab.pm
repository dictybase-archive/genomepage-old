
=head1 NAME

   B<Genome::Tabview::Config::Panel::Item::Tab> - Class for handling tabview panel items

=head1 VERSION

    This document describes B<Genome::Tabview::Config::Panel::Item::Tab> version 1.0.0

=head1 SYNOPSIS

    my $panel  = Genome::Tabview::Config::Panel->new(
        -layout   => 'tabview',
        -position => 'center',
    );
    my $gene = Genome::Tabview::Config::Panel::Item::Tab->new(
        -key        => 'gene',
        -label      => 'Gene Summary',
        -active     => 'true',
        -source     => '/db/cgi-bin/dictyBase/yui/tab.pl?&tab=go&primary_id=<GENE ID>'
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

use strict;
use Bio::Root::Root;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Config::Panel::Item::Tab> object.
 Returns  : Genome::Tabview::Config::Panel::Item::Tab object 
 Args     : -key        : defines tab key,
            -label      : defines tab label to display,
            -active     : 'true' value would result in tab being active by default,
            -source     : required if tab content is being loaded through request to the server.
            -type       : class to be assigned to the element
            -content    : If defined should contain elements to display inside the tab as a
                          reference to an array of Genome::Tabview::Config::Panel objects. 
            -dispatch   : If tab content should go through dispatcher              
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    $self->{root} = Bio::Root::Root->new();

    my $arglist = [qw/KEY LABEL ACTIVE SOURCE TYPE CONTENT HREF DISPATCH/];
    my ( $key, $label, $active, $source, $type, $content, $href, $dispatch ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('key is not provided')   if !$key;
    $self->{root}->throw('label is not provided') if !$label;
    $self->{root}->throw('source or content should be provided')
        if !( $source || $content );

    if ($content) {
        foreach my $panel (@$content) {
            $self->{root}->throw(
                'Content should contain Genome::Tabview::Config::Panel implementing objects'
            ) if ref($panel) !~ m{Genome::Tabview::Config::Panel};
        }
    }
    $self->key($key);
    $self->label($label)       if $label;
    $self->active($active)     if $active;
    $self->source($source)     if $source;
    $self->type($type)         if $type;
    $self->href($href)         if $href;
    $self->content($content)   if $content;
    $self->dispatch($dispatch) if $dispatch;
    return $self;
}

=head2 key

 Title    : key
 Usage    : $item->key('go');
 Function : gets/sets key of the item
 Returns  : string
 Args     : string

=cut

sub key {
    my ( $self, $arg ) = @_;
    $self->{key} = $arg if defined $arg;
    return $self->{key};
}

=head2 label

 Title    : label
 Usage    : $item->label('GO Annotations');
 Function : gets/sets label of the item
 Returns  : string
 Args     : string

=cut

sub label {
    my ( $self, $arg ) = @_;
    $self->{label} = $arg if defined $arg;
    return $self->{label};
}

=head2 active

 Title    : active
 Usage    : $item->active('true');
 Function : gets/sets active parameter of the item
 Returns  : string
 Args     : string

=cut

sub active {
    my ( $self, $arg ) = @_;
    $self->{active} = $arg if defined $arg;
    return $self->{active};
}

=head2 source

 Title    : source
 Usage    : $item->source('/db/cgi-bin/dictyBase/yui/tab.pl?&tab=gene&primary_id=<GENE ID>');
 Function : gets/sets source of the item
 Returns  : string
 Args     : string

=cut

sub source {
    my ( $self, $arg ) = @_;
    $self->{source} = $arg if defined $arg;
    return $self->{source};
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

=head2 href

 Title    : href
 Usage    : $item->href('feature/DDB1234567');
 Function : gets/sets href of the item
 Returns  : string
 Args     : string

=cut

sub href {
    my ( $self, $arg ) = @_;
    $self->{href} = $arg if defined $arg;
    return $self->{href};
}

=head2 dispatch

 Title    : dispatch
 Usage    : $item->dispatch('true');
 Function : gets/sets dispatch of the item
 Returns  : string
 Args     : string

=cut

sub dispatch {
    my ( $self, $arg ) = @_;
    $self->{dispatch} = $arg if defined $arg;
    return $self->{dispatch};
}

=head2 content

 Title    : key
 Usage    : $item->content(\@panels);
 Function : gets/sets content of the item
 Returns  : reference to an array of Genome::Tabview::Config::Panel objects
 Args     : reference to an array of Genome::Tabview::Config::Panel objects

=cut

sub content {
    my ( $self, $arg ) = @_;
    if ($arg) {
        $self->{root}->throw("Content should be array reference")
            if ref($arg) ne 'ARRAY';
        foreach my $panel (@$arg) {
            $self->{root}->throw(
                'Content should be reference to an array of Genome::Tabview::Config::Panel objects'
            ) if ref($panel) !~ m{Genome::Tabview::Config::Panel}i;
        }
        $self->{content} = $arg;
    }
    return $self->{content};
}

=head2 to_json

 Title    : to_json 
 Usage    : $panel->to_json();
 Function : returns json representation of the item 
 Returns  : string 
 Args     : none
    
=cut

sub to_json {
    my ( $self, @args ) = @_;
    my $item;
    $item->{key}      = $self->key;
    $item->{label}    = $self->label;
    $item->{active}   = $self->active if $self->active;
    $item->{source}   = $self->source if $self->source;
    $item->{type}     = $self->type if $self->type;
    $item->{href}     = $self->href if $self->href;
    $item->{dispatch} = $self->dispatch if $self->dispatch;
    if ( $self->content ) {
        foreach my $panel ( @{ $self->content } ) {
            push @{ $item->{content} }, $panel->to_json;
        }
    }
    return $item;
}

1;

