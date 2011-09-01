
=head1 NAME

   B<Genome::Tabview::Page::Tab::Feature::GenBank> - Class for handling feature tab configuration 

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Tab::Feature::GenBank> version 1.0.0

=head1 SYNOPSIS

    my $tab = Genome::Tabview::Page::Tab::Feature::GenBank->new( -primary_id => 'DDB0185055' );
    my $json = $tab->configure();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Tab::Feature::GenBank> handles gene tab configuration, 
    determined which sections are available for the tab.

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

package Genome::Tabview::Page::Tab::Feature::GenBank;

use strict;
use Bio::Root::Root;
use dicty::Feature;
use Genome::Tabview::JSON::Feature::Generic;
use base qw( Genome::Tabview::Page::Tab::Feature );

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::Tab::Feature::GenBank> object. 
            Sets templates and configuration parameters for tabs to be displayed
 Usage    : my $tab = Genome::Tabview::Page::Tab::Feature::GenBank->new( -primary_id => 'DDB0185055' );
 Returns  : Genome::Tabview::Page::Tab::Feature::GenBank object with default configuration.
 Args     : feature primary id
 
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/PRIMARY_ID BASE_URL/];

    $self->{root} = Bio::Root::Root->new();
    my ($primary_id, $base_url) = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;

    my $feature = dicty::Feature->new( -primary_id => $primary_id );
    $self->feature($feature);
    $self->tab('feature');
    $self->base_url($base_url) if $base_url;
    return $self;
}

=head2 init

 Title    : init
 Function : initializes the tab. Sets tab configuration parameters
 Usage    : $tab->init();
 Returns  : nothing
 Args     : none
 
=cut

sub init {
    my ($self) = @_;
    my $config = Genome::Tabview::Config->new();
    my $panel  = Genome::Tabview::Config::Panel->new(
        -layout => 'accordion' );
    
    my @items;
    push @items, $self->accordion(
        -key   => 'info',
        -label => $self->simple_label("General Information"),
    );
    push @items, $self->accordion(
        -key   => 'protein',
        -label => $self->simple_label("Protein Information"),
    ) if $self->show_protein;
    push @items, $self->accordion(
        -key   => 'references',
        -label => $self->simple_label("References"),
    );
    $panel->items( \@items );
    $config->add_panel($panel);
    $self->config($config);
    return $self;
}

=head2 show_protein

 Title    : show_protein
 Function : defines if to show protein info section
 Usage    : $show = $tab->show_protein();
 Returns  : boolean
 Args     : none
 
=cut

sub show_protein {
    my ($self) = @_;
    my $feature = Genome::Tabview::JSON::Feature::Generic->new( -primary_id => $self->feature->primary_id);
    my $sequences = $feature->available_sequences;
    foreach my $seq_type (@$sequences){
        return 1 if $seq_type =~ m{protein}i;
    }
    return;
}
1;
