
=head1 NAME

   B<Genome::Tabview::Config> - Class for handling page display element configuration

=head1 VERSION

    This document describes B<Genome::Tabview::Config> version 1.0.0

=head1 SYNOPSIS

    use Genome::Tabview::Config;
    my $config = Genome::Tabview::Config->new();
    my $panel  = Genome::Tabview::Config::Panel->new(
        layout   => 'tabview',
        position => 'center',
    );
    my $gene = Genome::Tabview::Config::Panel::Item::Tab->new(
        key        => 'gene',
        label      => 'Gene Summary',
        active     => 'true',
        primary_id => $primary_id,
    );
    $panel->add_item($gene);
    $config->add_panel($panel);
    print $config->to_json();
    
=head1 DESCRIPTION

    B<Genome::Tabview::Config> Class providing basic options for configuration and manipulation of
    page display elements. Config is a collection of Genome::Tabview::Config::Panel objects, where 
    each of them represents one structural element of the display

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

JSON
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

package Genome::Tabview::Config;

use strict;
use namespace::autoclean;
use Mouse;
use JSON qw/encode_json/;

=head2 panels

 Title    : panels
 Usage    : $config->panels();
 Function : gets/sets config panels
 Returns  : reference to an array of Genome::Tabview::Config::Panel objects
 Args     : reference to an array of Genome::Tabview::Config::Panel objects

=cut

has '_panels' => (
    is      => 'rw',
    isa     => 'ArrayRef[Genome::Tabview::Config::Panel]',
    traits  => [qw/Array/],
    handles => {
        'add_panel' => 'push',
        'panels'    => 'elements'
    }
);

=head2 to_json

 Title      : to_json 
 Usage      : $config->to_json();
 Function   : returns json representation of config 
 Returns    : string 
 Args       : none
 
=cut

sub to_json {
    my ( $self, @args ) = @_;
    my $config;
    foreach my $panel ( $self->panels ) {
        push @$config, $panel->to_json;
    }
    return encode_json($config);
}

__PACKAGE__->meta->make_immutable;

1;

