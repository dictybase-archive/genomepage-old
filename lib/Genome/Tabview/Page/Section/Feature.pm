
=head1 NAME

   B<Genome::Tabview::Page::Section::Feature> - Class for handling section display

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Section::Feature> version 1.0.0

=head1 SYNOPSIS

    my $section = Genome::Tabview::Page::Section::Feature->new( 
        -primary_id => <GENE ID>, 
        -section => 'info',
    );
    my $json = $section->process();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Section::Feature> handles section display.

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

package Genome::Tabview::Page::Section::Feature;

use strict;
use Module::Find;
use dicty::Feature;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Bio::Root::Root;

use base qw( Genome::Tabview::Page::Section );

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::Section::Feature> object. 
            Determines which subclass to instanciate based on the feature type
 Usage    : my $tab = Genome::Tabview::Page::Section::Feature->new( -primary_id => 'DDB0185055', section => 'info' );
 Returns  : Genome::Tabview::Page::Section::Feature subclass object with default configuration.
 Args     : feature primary id
 
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    my $arglist = [qw/PRIMARY_ID SECTION BASE_URL/];

    $self->{root} = Bio::Root::Root->new();
    my ( $primary_id, $section, $base_url ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;

    my $feature = dicty::Feature->new( -primary_id => $primary_id );
    $self->{root}->throw('provided is should belong to feature, not a gene')
        if $feature->type eq 'gene';

    my $namespace = 'Genome::Tabview::Page::Section::Feature';

    my $type = $feature->type;

    my $subclass =
          $type =~ m{RNA|Pseudo}i ? 'Generic'
        : $type =~ m{databank_entry|cDNA_clone}i ? 'GenBank'
        : $type eq 'EST Contig' ? 'EST_Contig'
        :                         $type;

    my @modules = grep {m{::$subclass$}ix} findsubmod $namespace;
    $self->{root}->throw(
        "Module matching section for $subclass not found in namespace "
            . $namespace )
        if !@modules;

    eval "require $modules[0]";
    $self->{root}->throw($@) if $@;

    return $modules[0]
        ->new( -primary_id => $feature->primary_id, -section => $section, -base_url => $base_url );
}

=head2 info

 Title    : info
 Function : Returns info section rows for the feature
 Returns  : array  
 Args     : none
 
=cut

sub info {
    my ( $self, @args ) = @_;
    my $feature = $self->feature;

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    my @rows;
    push @rows, $self->row( 'Feature Type', $feature->display_type );
    push @rows, $self->row( 'Sequence ID',  $feature->primary_id );
    push @rows, $self->row( 'Description',  $feature->description )
        if $feature->description;
    push @rows, $self->row( 'Accession Number', $feature->accession_number )
        if $feature->accession_number;
    push @rows, $self->row( 'Links', $feature->external_links )
        if $feature->external_links;
    push @rows, $self->row( 'Sequence', $feature->get_fasta_selection );

    $panel->items( \@rows );
    $config->add_panel($panel);
    return $config;
}

=head2 protein

 Title    : protein
 Function : Returns protein section rows for the feature
 Returns  : array  
 Args     : none
 
=cut

sub protein {
    my ( $self, @args ) = @_;
    my $feature = $self->feature;
    my $protein = $feature->protein;

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    my $cds_length = length(
        $feature->source_feature->sequence( -type => 'DNA coding sequence' )
    );
    my @rows;
    push @rows, $self->row( 'Protein Length',   $protein->length );
    push @rows, $self->row( 'Molecular Weight', $protein->molecular_weight );
    push @rows, $self->row( 'AA Composition',   $protein->aa_composition );
    push @rows, $self->row( 'CDS Length',       $cds_length . ' nt' );

    $panel->items( \@rows );
    $config->add_panel($panel);
    return $config;
}

=head2 references

 Title    : references
 Function : Returns reference rows for the feature
 Returns  : array  
 Args     : none
 
=cut

sub references {
    my ($self)  = @_;
    my $feature = $self->feature;
    my $config  = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    if ( !$feature->references ) {
        my $row = $self->row( ' ', 'No References available' );
        $panel->add_item($row);
        $config->add_panel($panel);
        return $config;
    }
    my @rows;
    foreach my $reference ( @{ $feature->references() } ) {
        push @rows, $self->row( $reference->links, $reference->citation );
    }
    $panel->items( \@rows );
    $config->add_panel($panel);
    return $config;
}

1;
