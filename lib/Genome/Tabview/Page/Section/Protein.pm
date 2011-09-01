
=head1 NAME

   B<Genome::Tabview::Page::Section::Protein> - Class for handling section display

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Section::Protein> version 1.0.0

=head1 SYNOPSIS

    my $section = Genome::Tabview::Page::Section::Protein->new( 
        -primary_id => <GENE ID>, 
        -section => 'info',
    );
    my $json = $section->process();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Section::Protein> handles section display.

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

package Genome::Tabview::Page::Section::Protein;

use strict;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::JSON::Feature::Protein;
use base qw( Genome::Tabview::Page::Section );

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::Section::Protein> object. 
 Usage    : my $page = Genome::Tabview::Page::Section::Protein->new();
 Returns  : Genome::Tabview::Page::Section::Protein object with default configuration.
 Args     : -primary_id   - feature primary id
            -section      - section id
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

    #    $self->{root}->throw('section is not provided')    if !$section;

    my $feature = Genome::Tabview::JSON::Feature::Protein->new(
        -primary_id => $primary_id );

    $self->section($section) if $section;
    $self->feature($feature);
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
        info     => sub { $self->info(@_) },
        domains  => sub { $self->domains(@_) },
        sequence => sub { $self->sequence(@_) },
        links    => sub { $self->links(@_) },
    };
    my $config = $settings->{$section}->();
    $self->config($config);
    return $self;
}

=head2 info

 Title    : info
 Function : returns protein general information section
 Usage    : $json = $section->info();
 Returns  : string  
 Args     : none
 
=cut

sub info {
    my ( $self, @args ) = @_;
    my $protein = $self->feature;
    my $gene    = $protein->gene;

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    my @rows;
    push @rows, $self->row( 'Gene Product', $gene->gene_products )
        if $gene->gene_products;

    push @rows, $self->row( 'Alternative Protein Names', $gene->protein_synonyms )
        if $gene->protein_synonyms;
    push @rows, $self->row( 'dictyBase ID', $protein->primary_id );
    push @rows, $self->row( 'Description',  $gene->description )
        if $gene->description;
    push @rows, $self->row( 'Protein Length',   $protein->length );
    push @rows, $self->row( 'Molecular Weight', $protein->molecular_weight );
    push @rows, $self->row( 'AA Composition',   $protein->aa_composition );

    my @uniprot_rows;

    push @uniprot_rows,
        $self->row( 'Sequence processing*', $protein->sequence_processing )
        if $protein->sequence_processing;
    push @uniprot_rows,
        $self->row( 'Subunit structure*', $protein->subunit_structure )
        if $protein->subunit_structure;
    push @uniprot_rows,
        $self->row( 'Subcellular location*', $protein->subcellular_location )
        if $protein->subcellular_location;
    push @uniprot_rows, $self->row( 'Domain*', $protein->domain )
        if $protein->domain;
    push @uniprot_rows,
        $self->row( 'Post-translational modification*',
        $protein->post_modification )
        if $protein->post_modification;
    push @uniprot_rows, $self->row( 'Cofactor*', $protein->cofactor )
        if $protein->cofactor;
    push @uniprot_rows,
        $self->row( 'Catalityc activity*', $protein->catalityc_activity )
        if $protein->catalityc_activity;

    push @uniprot_rows,
        $self->row( 'Protein existence*', $protein->protein_existence )
        if @uniprot_rows
            || (   $protein->protein_existence
                && $protein->protein_existence->{text} !~ m{Predicted} );
    push @uniprot_rows,
        $self->row( 'Note',
        '<b>*This information was obtained from UniProt manually reviewed record<b>'
        ) if @uniprot_rows;

    my @all_rows = ( @rows, @uniprot_rows );
    $panel->items( \@all_rows );
    $config->add_panel($panel);
    return $config;
}

=head2 domains

 Title    : domains
 Function : returns protein domains section
 Usage    : $json = $section->domains();
 Returns  : string
 Args     : none
 
=cut

sub domains {
    my ( $self, @args ) = @_;
    my $protein = $self->feature;
    my $config  = Genome::Tabview::Config->new();
    my $panel   = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    my $text = $self->json->text(
        '[Click on track to get information about a particular domain]');
    my @domains =
        ( $text, $protein->domains_image, $protein->domains_table_link );
    my $row = $self->row( 'Protein Domains', \@domains );

    $panel->add_item($row);
    $config->add_panel($panel);
    return $config;
}

=head2 sequence

 Title    : sequence
 Function : Returns protein sequence row
 Returns  : hash  
 Args     : none
 
=cut

sub sequence {
    my ($self) = @_;
    my $protein = $self->feature;

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    my $row = $self->row( 'Protein Sequence', $protein->sequence );
    $panel->add_item($row);
    $config->add_panel($panel);
    return $config;
}

=head2 links

 Title    : links
 Function : Returns protein links row
 Returns  : hash  
 Args     : none
 
=cut

sub links {
    my ($self)  = @_;
    my $protein = $self->feature;
    my $gene    = $protein->gene;

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    my @rows;
    push @rows, $self->row( 'Pathways', $gene->pathways ) if $gene->pathways;
    push @rows, $self->row( 'External Links', $protein->external_links )
        if $protein->external_links;

    $panel->items( \@rows );
    $config->add_panel($panel);
    return $config;
}

1;
