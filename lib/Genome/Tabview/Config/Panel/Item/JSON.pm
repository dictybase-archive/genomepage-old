
=head1 NAME

   B<Genome::Tabview::Config::Panel::Item::JSON> - Class for handling panel items containinj JSON 
   preformatted data as a content

=head1 VERSION

    This document describes B<Genome::Tabview::Config::Panel::Item::JSON> version 1.0.0

=head1 SYNOPSIS

    use Genome::Tabview::Config::Panel::Item::JSON;
    my $item = Genome::Tabview::Config::Panel::Item::JSON->new(
            -type   => 'content_table_title',
            -content => [{"text":"Gene Name"}],
    );
    
=head1 DESCRIPTION

    B<Genome::Tabview::Config::Panel::Item::JSON> Item reperesents single element of panel 
    having type and content properties. Content of the item would be sent to the client side formatter "as is"

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

package Genome::Tabview::Config::Panel::Item::JSON;

use strict;
use Bio::Root::Root;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Config::Panel::Item::JSON> object.
 Returns  : Genome::Tabview::Config::Panel::Item::JSON object 
 Args     : -type    : class to be assigned to the element
            -content : item content, this Item implementation does not have any restrictions
                       for the content. All the elements would be formatted based on their json type flag
 
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    $self->{root} = Bio::Root::Root->new();
    my $arglist = [qw/CONTENT/];
    my ($content) = $self->{root}->_rearrange( $arglist, @args );

    $self->content($content) if $content;
    return $self;
}

=head2 content

 Title    : key
 Usage    : $item->content($panel);
 Function : gets/sets content of the item
 Returns  : reference to an array of hashes
 Args     : reference to an array of hashes

=cut

sub content {
    my ( $self, $arg ) = @_;
    $self->{content} = $arg if defined $arg;
    return $self->{content};
}

=head2 link

 Title    : link
 Function : Composes link json representation with defined parameters
 Usage    : my $link = $item->link( 
                -url      => 'www.dictybase.org', 
                -caption  => 'dictyBase Home',
                -type     => 'outer',
            );
 Returns  : hash
 Args     : -url     - link url
            -caption - link caption
            -type    - link type ('tab' for the new tab link, 'outer' for the new window link, 
                        'gbrowse' for the gbrowse link)
=cut

sub link {
    my ( $self, @args ) = @_;

    ## -- allowed arguments
    my $arglist = [qw/URL CAPTION TYPE STYLE TITLE NAME ID/];
    my ( $url, $caption, $type, $style, $title, $name, $id ) =
        $self->{root}->_rearrange( $arglist, @args );

    $self->{root}->throw('url is not provided') if !$url;
    $caption = $url if !$caption;
    my $json_link;
    $json_link->{caption} = $caption;
    $json_link->{url}     = $url;
    $json_link->{type}    = $type;
    $json_link->{style}   = $style if $style;
    $json_link->{title}   = $title if $title;
    $json_link->{id}      = $id if $id;
    $json_link->{name}    = $name if $name;

    return $json_link;
}

=head2 text

 Title    : text
 Function : Composes text json representation with defined parameters
 Usage    : my $text = $item->text( "Hello" );
 Returns  : hash
 Args     : string
 
=cut

sub text {
    my ( $self, $string ) = @_;

    ## -- allowed arguments
    $self->{root}->throw('string is not provided') if !$string;
    my $text = { text => $string };
    return $text;
}

=head2 selector

 Title    : selector
 Function : Composes selector json representation
 Usage    : my $selector = $item->selector( -options => \@data, -action => $action_obj );
 Returns  : hash
 Args     : -options    : array of options to select from
            -action_link     : where the selected option will be passed to
 
=cut

sub selector {
    my ( $self, @args ) = @_;
    my $arglist = [qw/OPTIONS ACTION_LINK CLASS CAPTION/];
    my ( $options, $action, $class, $caption ) =
        $self->{root}->_rearrange( $arglist, @args );

    $self->{root}->throw('options are not provided') if !@$options;

    my $selector = {
        type           => 'selector',
        options        => $options,
        action_link    => $action,
        selector_class => $class,
    };
    $selector->{caption} = $caption if $caption;
    return $selector;
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
    my $item = $self->content;
    return $item;
}

=head2 format_url

 Title    : format_url
 Function : Replaces input string, containing href tags, with array, composed of strings
            and json data structures representing links
 Returns  : reference to array
 Args     : string

=cut

sub format_url {
    my ( $self, $string ) = @_;

    #return $string if $string !~ m{href}ixg;

    # fixing links without closing tag
    $string .= '</a>' if $string !~ m{</a>}ixg;
    $string =~ s{\n}{}g;
    my $input = $string;
    my $match_hash;
    my @output;
    my $i = 0;

   # Make hash of link replacements and replace actual links with "CUT" marker
    while ( $input =~ m{(<a.*?/a>)}g ) {
        my $match = $1;
        my ( $url, $caption ) = $match =~ m{href="(.+?)">(.+?)</a};
        my $link = $self->link(
            -caption => $caption,
            -url     => $url,
            -type    => 'outer',
        );
        $string =~ s{<a.*?/a>}{CUT};
        $match_hash->{$i} = $link;
        $i++;
    }

    # Split string on "CUT" marks and merge with link objects
    my @row = split( 'CUT', $string );
    for ( my $j = 0; $j < @row; $j++ ) {
        push @output, $self->text( $row[$j] );
        push @output, $match_hash->{$j} if $match_hash->{$j};
    }
    return \@output;
}

1;

