
=head1 NAME

B<Genome::Factory::Tabview::Tab> - [Factory for picking up sources for tabbed view display] 


=head1 VERSION

This document describes B<Genome::Factory::Tabview::Tab> version 0.0.1

=head1 SYNOPSIS

 use Genome::Factory::Tabview::Tab;
 my $factory = Genome::Factory::Tabview::Tab->new( -tab => 'gene', -primary_id => $primary_id);
 my $tab = $factory->instantiate;

 my $factory = Genome::Factory::Tabview::Tab->new();
 $factory->tab('gene);
 $factory->primary_id($primary_id);
 my $tab = $factory->instantiate;

=head1 DESCRIPTION

 Tabview interface implies using of multiple tabs having different configuration. The factory module
 provides dynamic retrevial of classes based on their name.
 
=head1 DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

B<Genome::Factory::Tabview::Tab> requires setting up of standard dictybase environment
variables. For detail look in the I<conf.sh> file under the bin folder of dictybase
codebase.

=head1 DEPENDENCIES

dicty::Root
Module::Find

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.Please report any bugs or feature requests to B<dictybase@northwestern.edu>

=head1 AUTHOR

I<Yulia Bushmanova> B<y-bushmanova@northwestern.edu>
I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>

=head1 LICENCE AND COPYRIGHT

Copyright (c) B<2003>, Dictybase C<<dictybase@northwestern.edu>>. All rights reserved.

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

package Genome::Factory::Tabview::Tab;

use strict;
use namespace::autoclean;
use Moose;
use Module::Find;
use Class::MOP;
use Carp;

=head2 tab

Title    : tab
Function : gets/sets implementation of dicty::UI::Tabview::GenePage::Tab
Usage    : $factory->tab('gene');
Returns  : string
Args     : string

=cut

=head2 primary_id

Title    : primary_id
Function : gets/sets primary id
Usage    : $factory->primary_id($primary_id);
Returns  : string
Args     : string

=cut

=head2 base_url

Title    : base_url
Usage    : $factory->base_url('purpureum');
Function : gets/sets base_url
Returns  : string
Args     : string

=cut

=head2 default_namespace

Title    : default_namespace
Function : gets/sets class namespace where the factory will search for 
		   B<dicty::UI::Tabview::GenePage::Tab> implementing classes that matches the source name.
		   If not given the default namespace will be B<dicty::UI::Tabview::GenePage::Tab> which is
		   generally set during the object creation.
Usage    : $factory->default_namespace($namespace);
		   or 
		   factory->default_namespace();
Returns  : string
Args     : string

=cut

has [qw/primary_id base_url tab/] => ( is => 'rw', isa => 'Str' );
has 'default_namespace' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'Genome::Tabview::Page::Tab',
    lazy    => 1
);
has 'context' => ( is => 'rw', isa => 'Mojolicious::Controller' );

=head2 instantiate

 Title    : instantiate
 Function : Instantiates dicty::UI::Tabview::GenePage::Tab subclass based on provided data
 Usage    : my $tab = Genome::Factory::Tabview::Tab->instantiate();
 Returns  : dicty::UI::Tabview::GenePage::Tab implementing object with default configuration.
 Args     : none
 
=cut

sub instantiate {
    my ($self) = @_;

    my $tab        = $self->tab;
    my @modules = grep {/::$tab$/i} findsubmod $self->default_namespace;
    croak "Module matching tab $tab not found in namespace ",
        $self->default_namespace, "\n"
        if !@modules;

    Class::MOP->load_class($modules[0]);
    my $obj = $modules[0]
        ->new( primary_id => $self->primary_id, base_url => $self->base_url );
    if ( $self->context ) {
        $obj->context( $self->context ) if $obj->can('context');
    }
    return $obj;
}

__PACKAGE__->meta->make_immutable;

1;
