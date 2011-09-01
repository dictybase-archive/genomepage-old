
=head1 NAME

   B<Genome::Tabview::Page::Tab::Phenotypes> - Class for handling gene phenotypes tab configuration 

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Tab::Phenotypes> version 1.0.0

=head1 SYNOPSIS

    my $tab = Genome::Tabview::Page::Tab::Phenotypes->new( -primary_id => <GENE ID> );
    my $json = $tab->configure();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Tab::Phenotypes> handles gene phenotypes tab display.
    

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

package Genome::Tabview::Page::Tab::Phenotypes;

use strict;
use Bio::Root::Root;
use dicty::Feature;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::Config::Panel::Item::JSON::Table;

use base qw( Genome::Tabview::Page::Tab );

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::Tab::Phenotypes> object. 
            Sets templates and configuration parameters for tabs to be displayed
 Usage    : my $tab = Genome::Tabview::Page::Tab::Phenotypes->new( -primary_id => 'DDB0185055' );
 Returns  : Genome::Tabview::Page::Tab::Phenotypes object with default configuration.
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
    my ( $primary_id, $base_url ) =
        $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;

    my $feature = dicty::Feature->new( -primary_id => $primary_id );
    $self->feature($feature);
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
    my $gene = Genome::Tabview::JSON::Feature::Gene->new(
        -primary_id => $self->feature->primary_id );
	$gene->context($self->context) if $self->context;

    my $table = Genome::Tabview::Config::Panel::Item::JSON::Table->new();
    $table->class('general');
    $table->add_column(
        -key       => 'cart',
        -label     => '<span class="shopping_cart">&nbsp;</span>',
        -sortable  => 'true',
        -width     => '20',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'strain',
        -label     => 'Strain',
        -sortable  => 'true',
        -width     => '105',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'character',
        -label     => 'Characteristics',
        -sortable  => 'true',
        -width     => '105',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'phenotype',
        -label     => 'Phenotype',
        -sortable  => 'true',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'ref',
        -label     => 'Reference',
        -sortable  => 'true',
        -formatter => 'grouper',
    );
    $table->add_column(
        -key       => 'ref_link',
        -label     => ' ',
        -sortable  => 'false',
        -width     => '118',
        -formatter => 'grouper',
    );

    foreach my $genotype ( @{ $gene->genotypes } ) {
        foreach my $experiment ( @{ $genotype->experiments } ) {
            my @systematic_name = (
                $self->json->text(
                    '<br>(' . $genotype->source_strain->systematic_name . ')'
                ),
            );
            my $data = {
                cart      => [ $genotype->add_to_cart ],
                strain    => [ $genotype->strain_link, @systematic_name ],
                character => [ $genotype->mutant_character ],
                phenotype => [ $experiment->phenotype_link ],
                ref       => [ $experiment->reference->citation ],
                ref_link  => $experiment->reference->links,
            };
            $table->add_record($data);
        }
    }

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'json' );

    my $form = Genome::Tabview::Config::Panel::Item::JSON->new(
        -content => $self->json->text(
                  '<FORM NAME="order" ACTION="/db/cgi-bin/'
                . $ENV{'SITE_NAME'}
                . '/SC/process_order.pl" METHOD="post" onsubmit="return ValidateCart(this)" target="_blank">'
                . '<input class="hidden" id="order-name" name="NAME" value="">'
                . '<input class="hidden" id="order-id" name="ID_NUM" value="">'
                . '<input type=button onClick="window.open(\'/db/cgi-bin/'
                . $ENV{'SITE_NAME'}
                . '/SC/manage_cart.pl\')" value="View Cart"> '
                . '</FORM>'
        )
    );

    my $item = Genome::Tabview::Config::Panel::Item::JSON->new(
        -type    => 'phenotypes_table',
        -content => $table->structure,
    );

    $panel->add_item($item);
    $panel->add_item($form);
    $config->add_panel($panel);
    $self->config($config);
    return $self;
}

1;
