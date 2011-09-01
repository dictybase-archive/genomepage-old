
=head1 NAME

    B <Genome::Tabview::JSON::Genotype> - Class for handling JSON structure conversion for 
    dicty::Genetics::Genotype implementing objects

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::Genotype> version 1.0.0

=head1 SYNOPSIS

    my $json = Genome::Tabview::JSON::Genotype->new( -genotype_id => '1');
    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::Genotype> is a proxy class that provides feature information 
    representation in a way suitable for furthure JSON convertion

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported. Please report any bugs or feature requests to B<dictybase@northwestern.edu>

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

package Genome::Tabview::JSON::Genotype;

use strict;
use Bio::Root::Root;
use dicty::Search::Strain;
use dicty::Genetics::Genotype;
use Genome::Tabview::JSON::Experiment;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::JSON::Genotype> object. 
 Usage    : my $genotype = Genome::Tabview::JSON::Genotype->new(
            -genotype_id => $genotype->genotype_id );
 Returns  : Genome::Tabview::JSON::Genotype object with default configuration.     
 Args     : -genotype_id   - genotype id.
 
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/GENOTYPE_ID/];
    $self->{root} = Bio::Root::Root->new();
    my ($genotype_id) = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('genotype number is not provided') if !$genotype_id;

    my $genotype
        = dicty::Genetics::Genotype->new( -genotype_id => $genotype_id );
    my $strain = dicty::Search::Strain->Search_by_genotype_id(
        $genotype->genotype_id() );
    $self->source_genotype($genotype);
    $self->source_strain($strain);
    return $self;
}

sub context {
    my ( $self, $arg ) = @_;
    $self->{context} = $arg if defined $arg;
    return $self->{context} if defined $self->{context};
}

=head2 json

 Title    : json
 Usage    : $genotype->json->link(....);
 Function : gets/sets json handler. Uses Genome::Tabview::Config::Panel::Item::JSON as default one
 Returns  : nothing
 Args     : JSON handler

=cut

sub json {
    my ( $self, $arg ) = @_;
    $self->{json} = $arg if $arg;
    $self->{json} = Genome::Tabview::Config::Panel::Item::JSON->new()
        if !$self->{json};
    return $self->{json};
}

=head2 source_genotype

 Title    : source_genotype
 Usage    : $genotype->source_genotype($genotype);
 Function : gets/sets genotype, that would be used as a source for all calls
 Returns  : dicty::Genetics::Genotype object
 Args     : dicty::Genetics::Genotype object

=cut

sub source_genotype {
    my ( $self, $arg ) = @_;
    $self->{source_genotype} = $arg if defined $arg;
    $self->{root}->throw('Genotype is not defined')
        if not defined $self->{source_genotype};
    $self->{root}->throw('Genotype should be dicty::Genetics::Genotype')
        if ref( $self->{source_genotype} ) !~ m{dicty::Genetics::Genotype}x;
    return $self->{source_genotype};
}

=head2 source_strain

 Title    : source_strain
 Usage    : $genotype->source_strain($strain);
 Function : gets/sets strain, that would be used as a source for calls
 Returns  : dicty::SC::Strain object
 Args     : dicty::SC::Strain object

=cut

sub source_strain {
    my ( $self, $arg ) = @_;
    $self->{source_strain} = $arg if defined $arg;
    $self->{root}->throw('Strain is not defined')
        if not defined $self->{source_strain};
    $self->{root}->throw('Strain should be dicty::SC::Strain')
        if ref( $self->{source_strain} ) !~ m{dicty::SC::Strain}x;
    return $self->{source_strain};
}

=head2 strain_link

 Title    : strain_link
 Usage    : $genotype->strain_link;
 Function : returns genotype strain link
 Returns  : hash
 Args     : none

=cut

sub strain_link {
    my ($self)      = @_;
    my $strain      = $self->source_strain;
    my $genotype    = $self->source_genotype;
    my $strain_name = dicty::MiscUtility::soft_break( $strain->name() );

    my $strain_link = $self->json->link(
        -caption => $strain_name,
        -url =>
            "/db/cgi-bin/$ENV{'SITE_NAME'}/phenotype/strain_and_phenotype_details.pl?genotype_id="
            . $genotype->genotype_id,
        -type => 'outer',
    );
    return $strain_link;
}

=head2 experiments

 Title    : experiments
 Function : returns genotype experiments
 Usage    : my $experiments = $genotype->experiments;
 Returns  : hash
 Args     : none
 
=cut

sub experiments {
    my ($self) = @_;
    my $genotype = $self->source_genotype;
    my @experiments;
    foreach my $experiment ( @{ $genotype->experiments } ) {
        my $json_experiment = Genome::Tabview::JSON::Experiment->new(
            -experiment_id => $experiment->experiment_id );
        $json_experiment->context( $self->context ) if $self->context;
        push @experiments, $json_experiment;
    }
    return \@experiments;
}

=head2 experiment_links

 Title    : experiment_links
 Usage    : $genotype->experiment_links;
 Function : returns genotype experiment links
 Returns  : hash
 Args     : none

=cut

sub experiment_links {
    my ($self) = @_;
    my @experiment_links;

    foreach my $experiment ( @{ $self->experiments } ) {
        my $divider = ( scalar @experiment_links ) / 2
            < scalar @{ $self->experiments } - 1 ? '&nbsp;|&nbsp;' : undef;

        push @experiment_links, $experiment->phenotype_link;
        push @experiment_links, $self->json->text($divider) if $divider;
    }
    return \@experiment_links;
}

=head2 mutant_character

 Title    : mutant_character
 Usage    : $genotype->mutant_character;
 Function : returns genotype strain mutant_character
 Returns  : hash
 Args     : none

=cut

sub mutant_character {
    my ($self) = @_;

    my $strain = $self->source_strain;

    my @charact = @{ $strain->strain_mutant_characteristics };
    return if !@charact;

    my @mutant_charact = map { $_->name } @charact;
    return $self->json->text( join( ", ", @mutant_charact ) );
}

=head2 add_to_cart

 Title    : add_to_cart
 Usage    : $genotype->add_to_cart;
 Function : returns genotype add_to_cart link
 Returns  : hash
 Args     : none

=cut

sub add_to_cart {
    my ($self)   = @_;
    my $strain   = $self->source_strain;
    my $add_link = $self->json->link(
        -url   => '#',
        -type  => 'addToCart',
        -name  => $strain->name,
        -id    => 'Strain-' . $strain->systematic_name,
        -title => 'Click to add strain to your cart'
    );
    my $na_img
        = $self->json->text( '<span class="cart_not_available" name="'
            . $strain->systematic_name
            . '" title="Strain is not available for ordering">&nbsp;</span>'
        );

    my $add_strain = $strain->has_inventory ? $add_link : $na_img;
    return $add_strain;
}
1;
