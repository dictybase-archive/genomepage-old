
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
use Bio::Root::Root;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Config::Panel::Item::Accordion> object.
 Returns  : Genome::Tabview::Config::Panel::Item::Accordion object 
 Args     : -key        : defines accordion key,
            -label      : defines accordion label to display,
            -type       : class to be assigned to the element
            -content    : If defined should contain elements to display inside the tab as a
                          reference to an array of Genome::Tabview::Config::Panel objects.
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    $self->{root} = Bio::Root::Root->new();

    my $arglist = [qw/KEY LABEL SOURCE TYPE CONTENT/];
    my ( $key, $label, $source, $type, $content ) =
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
    $self->label($label)     if $label;
    $self->source($source)   if $source;
    $self->type($type)       if $type;
    $self->content($content) if $content;
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
            my $warn =
                'Content should be reference to an array of Genome::Tabview::Config::Panel objects';
            $self->{root}->throw($warn)
                if ref($panel) !~ m{Genome::Tabview::Config::Panel}i;
        }
        $self->{content} = $arg;
    }
    return $self->{content};
}

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
    $item->{key}    = $self->key;
    $item->{label}  = $self->label if $self->label;
    $item->{source} = $self->source if $self->source;
    $item->{type}   = $self->type if $self->type;
    if ( $self->content ) {
        foreach my $panel ( @{ $self->content } ) {
            push @{ $item->{content} }, $panel->to_json;
        }
    }
    return $item;
}

1;

