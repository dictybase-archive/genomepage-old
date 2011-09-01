
=head1 NAME

   B<Genome::Tabview::Page::Section::GO> - Class for handling section display

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Section::GO> version 1.0.0

=head1 SYNOPSIS

    my $section = Genome::Tabview::Page::Section::GO->new( 
        -primary_id => <GENE ID>, 
        -section => 'function',
    );
    my $json = $section->process();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Section::GO> handles section display.

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

package Genome::Tabview::Page::Section::GO;

use strict;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::JSON::Feature::Gene;
use base qw( Genome::Tabview::Page::Section );

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::Section::GO> object. 
 Usage    : my $page = Genome::Tabview::Page::Section::GO->new();
 Returns  : Genome::Tabview::Page::Section::GO object with default configuration.
 Args     : -primary_id   - feature primary id
            -section      - section id
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/PRIMARY_ID SECTION BASE_URL CONTEXT/];
    $self->{root} = Bio::Root::Root->new();

    my ( $primary_id, $section, $base_url, $context )
        = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;

    #$self->{root}->throw('section is not provided')    if !$section;

    my $gene = Genome::Tabview::JSON::Feature::Gene->new(
        -primary_id => $primary_id );

    if ($context) {
        $gene->context($context);
        $self->context($context);
    }

    $self->section($section) if $section;
    $self->gene($gene);
    $self->base_url($base_url) if $base_url;
    return $self;
}

=head2 init

 Title    : init
 Function : initializes the section.
 Usage    : $section->init();
 Returns  : nothing
 Args     : none
 
=cut

sub init {
    my ($self)   = @_;
    my $section  = $self->section;
    my $settings = {
        function  => sub { $self->function_annotation(@_) },
        process   => sub { $self->process_annotation(@_) },
        component => sub { $self->component_annotation(@_) },
    };
    my $config = $settings->{$section}->();
    $self->config($config);
    return $self;
}

=head2 function_annotation

 Title    : function_annotation
 Function : returns molecular function annotation section rows
 Usage    : $json = $section->function();
 Returns  : hash  
 Args     : none
 
=cut

sub function_annotation {
    my ($self)      = @_;
    my $gene        = $self->gene;
    my $go          = $gene->go;
    my $annotations = $go->function_annotations;

    my $config = Genome::Tabview::Config->new();
    my $panel  = $self->json_panel( $go->annotation_table($annotations) );
    $config->add_panel($panel);
    return $config;

}

=head2 process_annotation

 Title    : process_annotation
 Function : returns process annotation section rows
 Usage    : $json = $section->process();
 Returns  : hash  
 Args     : none
 
=cut

sub process_annotation {
    my ($self)      = @_;
    my $gene        = $self->gene;
    my $go          = $gene->go;
    my $annotations = $go->process_annotations;

    my $config = Genome::Tabview::Config->new();
    my $panel  = $self->json_panel( $go->annotation_table($annotations) );
    $config->add_panel($panel);
    return $config;
}

=head2 component_annotation

 Title    : component_annotation
 Function : returns component annotation section rows
 Usage    : $json = $section->function();
 Returns  : hash  
 Args     : none
 
=cut

sub component_annotation {
    my ($self)      = @_;
    my $gene        = $self->gene;
    my $go          = $gene->go;
    my $annotations = $go->component_annotations;

    my $config = Genome::Tabview::Config->new();
    my $panel  = $self->json_panel( $go->annotation_table($annotations) );
    $config->add_panel($panel);
    return $config;
}

1;
