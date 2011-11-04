
=head1 NAME

    B <Genome::Tabview::JSON::Experiment> - Class for handling JSON structure conversion for 
    dicty::Genetics::Experiment implementing objects

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::Experiment> version 1.0.0

=head1 SYNOPSIS

    my $json = Genome::Tabview::JSON::Experiment->new( -experiment_id => '1');

    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::Experiment> is a proxy class that provides feature information 
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

package Genome::Tabview::JSON::Experiment;

use strict;
use Bio::Root::Root;
use Genome::Tabview::JSON::Reference;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::JSON::Experiment> object. 
 Usage    : my $genotype = Genome::Tabview::JSON::Experiment->new(
            -genotype_id => $genotype->genotype_id );
 Returns  : Genome::Tabview::JSON::Experiment object with default configuration.     
 Args     : -genotype_id   - genotype id.
 
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/EXPERIMENT_ID/];
    $self->{root} = Bio::Root::Root->new();
    my ($experiment_id) = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('experiment id is not provided') if !$experiment_id;

    my $experiment =
        dicty::Genetics::Experiment->new( -experiment_id => $experiment_id );
    $self->source_experiment($experiment);
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

=head2 source_experiment

 Title    : source_experiment
 Usage    : $experiment->source_experiment($experiment);
 Function : gets/sets experiment, that would be used as a source for all calls
 Returns  : dicty::Genetics::Experiment object
 Args     : dicty::Genetics::Experiment object

=cut

sub source_experiment {
    my ( $self, $arg ) = @_;
    $self->{source_experiment} = $arg if defined $arg;
    $self->{root}->throw('Experiment is not defined')
        if not defined $self->{source_experiment};
    $self->{root}->throw('Experiment should be dicty::Genetics::Experiment')
        if ref( $self->{source_experiment} ) !~
            m{dicty::Genetics::Experiment}x;
    return $self->{source_experiment};
}

=head2 phenotype_link

 Title    : phenotype_link
 Usage    : $experiment->phenotype_link;
 Function : returns experiment phenotype link
 Returns  : hash
 Args     : none

=cut

sub phenotype_link {
    my ($self)     = @_;
    my $experiment = $self->source_experiment;
    my $link       = $self->json->link(
        -caption => $experiment->phenotype_character->entity->name,
        -url =>
            "/db/cgi-bin/$ENV{'SITE_NAME'}/phenotype/phenotype_search.pl?query="
            . $experiment->phenotype_character->entity->term_id,
        -type => 'outer',
    );
    return $link;
}

=head2 notes

 Title    : notes
 Usage    : $experiment->notes;
 Function : returns experiment notes
 Returns  : hash
 Args     : none

=cut

sub notes {
    my ($self)              = @_;
    my $experiment          = $self->source_experiment;
    my $phenotype_character = $experiment->phenotype_character;

    my $sentence = $phenotype_character->sentence();
    $sentence =~ s/\[(.*)\]//g;
    $sentence =~ s/\[//g;
    $sentence =~ s/\]//g;

    my $assay = "<b>Assay:</b> " . $phenotype_character->assay->name()
        if $phenotype_character->assay();
    my $environment =
        "<b>Environment:</b> " . $experiment->environment->name()
        if $experiment->environment();

    my @notes;
    push @notes, $sentence if $sentence =~ m{\S};
    push @notes, $assay if $assay;
    push @notes, $environment if $environment;

    my $notes = $self->json->text( join( '<br>', @notes ) )
        if @notes;
    return $notes;
}

=head2 reference

 Title    : reference
 Function : returns experiment reference
 Usage    : $reference = $experiment->reference;
 Returns  : Genome::Tabview::JSON::Reference object
 Args     : none
 
=cut

sub reference {
    my ($self) = @_;

    return if !$self->source_experiment->reference;
    return $self->{reference} if $self->{reference};

    $self->{reference} = Genome::Tabview::JSON::Reference->new(
        -pub_id => $self->source_experiment->reference->pub_id );
	$self->{reference}->context($self->context) if $self->context;
    return $self->{reference};
}

1;
