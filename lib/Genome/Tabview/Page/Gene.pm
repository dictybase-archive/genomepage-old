
=head1 NAME

   B<Genome::Tabview::Page::Gene> - Class for handling tabbed gene page configuration

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Gene> version 1.0.0

=head1 SYNOPSIS

    my $page = Genome::Tabview::Page::Gene->new( 
        -primary_id => <GENE ID>, 
    );
    my $output = $page->process();
    print $cgi->header(), $output;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Gene> handles tabbed gene page configuration. It allows to set up
    tabs to show, their order and provides functionality to checks aviability of each tab for the 
    particular gene. Expects gene primary id to be passed. Uses gene_tabview.tt and error.tt 
    templates as default page and error templates respectively. For reserved genes, such as actin, 
    only gene summary tab  will be displayed. Sets Gene Summary Tab as active if active tab parameter 
    is not passed.

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

 dicty::Feature;
 dicty::Template;
 Bio::Root::Root;
 Genome::Tabview::Page;
 Genome::Tabview::Config;
 Genome::Tabview::Config::Panel;
 Genome::Tabview::Config::Panel::Item::Tab;
 dicty::Dbtable::Insertional_mutants;

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

package Genome::Tabview::Page::Gene;

use strict;
use dicty::Feature;
use dicty::Template;
use Bio::Root::Root;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
use Genome::Tabview::Config::Panel::Item::Tab;
use dicty::Dbtable::Insertional_mutants;
use Genome::Tabview::JSON::GO;

#use Carp::Always;

use base qw(Genome::Tabview::Page);

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page::Gene> object. 
            Sets templates and configuration parameters for tabs to be displayed.
            Uses gene_tabview.tt template and error.tt template a default page 
            and error templates respectively. 
            If active tab have not been set, activates Gene Summary tab, if available.
 Usage    : my $page = Genome::Tabview::Page::Gene->new( 
                -primary_id => <GENE ID>, 
            );
 Returns  : Genome::Tabview::Page::Gene object with default configuration if.
 Args     : -primary_id : feature primary id (mandatory)
          : -template : name of the TT template(optional), default is gene_tabview_test.tt
 
=cut

sub new {
    my ( $class, @args ) = @_;

    $class = ref $class || $class;
    my $self = {};
    bless $self, $class;

    ## -- allowed arguments
    $self->{root} = Bio::Root::Root->new();
    my $arglist
        = [qw/PRIMARY_ID TEMPLATE ACTIVE_TAB SUB_ID BASE_URL CONTEXT/];

    my ( $primary_id, $template, $active_tab, $sub_id, $base_url, $context )
        = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('primary id is not provided') if !$primary_id;

    #$self->{root}->throw('primary id does not belong to gene')
    #    if $primary_id !~ m{DDB_G};

    $self->{root}->throw('sub id should be provided for feature tab')
        if $active_tab && $active_tab eq 'feature' && !$sub_id;

    ## -- defaut templates to use
    my $page_template
        = dicty::Template->new( -name => $template || 'gene_tabview.tt' );
    my $error_template = dicty::Template->new( -name => 'error.tt' );

    $self->template($page_template);
    $self->error_template($error_template);
    $self->primary_id($primary_id);
    $self->active_tab($active_tab) if $active_tab;
    $self->sub_id($sub_id)         if $sub_id;
    $self->base_url($base_url)     if $base_url;
    $self->context($context)       if $context;
    return $self;
}

=head2 active_tab

 Title    : active_tab
 Usage    : $page->active_tab('gene');
 Function : gets/sets active_tab
 Returns  : string
 Args     : string

=cut

sub active_tab {
    my ( $self, $arg ) = @_;
    $self->{active_tab} = $arg if defined $arg;
    return $self->{active_tab};
}

sub context {
    my ( $self, $arg ) = @_;
    $self->{context} = $arg if defined $arg;
    return $self->{context};
}

=head2 sub_id

 Title    : sub_id
 Usage    : $page->sub_id('DDB01234567');
 Function : gets/sets sub_id
 Returns  : string
 Args     : string

=cut

sub sub_id {
    my ( $self, $arg ) = @_;
    $self->{sub_id} = $arg if defined $arg;
    return $self->{sub_id};
}

=head2 base_url

 Title    : base_url
 Usage    : $page->base_url('purpureum');
 Function : gets/sets base_url
 Returns  : string
 Args     : string

=cut

sub base_url {
    my ( $self, $arg ) = @_;
    $self->{base_url} = $arg if defined $arg;
    return $self->{base_url};
}

=head2 init

 Title    : init
 Function : initializes the page. Sets page configuration parameters
 Usage    : $self->init();
 Returns  : nothing
 Args     : none
 
=cut

sub init {
    my ($self) = @_;
    my $primary_id = $self->primary_id;
    my $feature = dicty::Feature->new( -primary_id => $primary_id );
    $self->feature($feature);

    ## -- page configuration
    my $config = Genome::Tabview::Config->new();
    my $panel
        = Genome::Tabview::Config::Panel->new( -layout => 'tabview' );

    my $prepender = $self->base_url || '';
    $prepender .= '/' . $primary_id;

    $panel->add_item(
        $self->tab(
            -key   => 'gene',
            -label => 'Gene Summary',
            -href  => $prepender
        )
    );
    $panel->add_item( $self->protein_tab ) if $self->show_protein;
    $panel->add_item(
        $self->tab(
            -key   => 'go',
            -label => 'Gene Ontology',
            -href  => "$prepender/go"
        )
    ) if $self->show_go;
    $panel->add_item(
        $self->tab(
            -key   => 'orthologs',
            -label => 'Orthologs',
            -href  => "$prepender/orthologs"
        )
    ) if $self->show_orthologs;
    $panel->add_item(
        $self->tab(
            -key   => 'phenotypes',
            -label => 'Phenotypes',
            -href  => "$prepender/phenotypes"
        )
    ) if $self->show_phenotypes;
    $panel->add_item(
        $self->tab(
            -key   => 'references',
            -label => 'References',
            -href  => "$prepender/references"
        )
    ) if $self->show_refs;
    $panel->add_item(
        $self->tab(
            -key      => 'blast',
            -label    => 'BLAST',
            -source   => '/tools/blast?noheader=1&primary_id=' . $primary_id,
            -dispatch => 'true',

            #-href     => 'tools/blast'
            -href => "$prepender/blast"
        )
    ) if $self->show_blast;
    if ( $self->active_tab && $self->active_tab eq 'feature' ) {
        $panel->add_item(
            $self->tab(
                -key        => 'feature',
                -label      => $self->sub_id,
                -primary_id => $self->sub_id,
                -href       => "$prepender/feature/" . $self->sub_id
            )
        );
    }

    $config->add_panel($panel);
    $self->config($config);
    return $self;
}

=head2 protein_tab

 Title    : protein_tab
 Function : composes protein tab for the protein coding genes
 Usage    : $tab = $self->protein_tab();
 Returns  : Genome::Tabview::Config::Panel::Item::Tab object
 Args     : none

=cut

sub protein_tab {
    my ($self) = @_;
    my $gene   = $self->feature;
    my $item   = 'Genome::Tabview::Config::Panel::Item::Tab';

    my @transcripts = @{ $gene->transcripts };
    my $base_url = $self->base_url || '';
    if ( scalar @transcripts > 1 ) {
        my $items;
        my @alphabet = ( 'A' .. 'Z' );
        my $i        = 0;

        foreach my $transcript (@transcripts) {
            my $active = $i == 0 ? 'true' : undef;
            my $subtab = $self->tab(
                -key        => 'protein',
                -label      => 'Splice Variant ' . $alphabet[$i],
                -primary_id => $transcript->primary_id,
                -href       => $base_url . '/'
                    . $gene->primary_id
                    . '/protein/'
                    . $transcript->primary_id,
            );
            push @$items, $subtab;
            $i++;
        }
        my $panel = Genome::Tabview::Config::Panel->new(
            -items  => $items,
            -layout => 'tabview'
        );
        my $tab = Genome::Tabview::Config::Panel::Item::Tab->new(
            -key     => 'protein_isoforms',
            -label   => 'Protein Information',
            -type    => 'toolbar',
            -content => [$panel],
            -href    => $base_url . '/' . $gene->primary_id . '/protein/'
        );
        return $tab;
    }
    my $tab = $self->tab(
        -key        => 'protein',
        -label      => 'Protein Information',
        -primary_id => $transcripts[0]->primary_id,
        -href       => $base_url . '/'
            . $gene->primary_id
            . '/protein/'
            . $transcripts[0]->primary_id,
    );
    return $tab;
}

=head2 get_header

 Title    : get_header
 Function : defines the header of the page
 Usage    : $header = $self->get_header();
 Returns  : string
 Args     : none
 
=cut

sub get_header {
    my ($self) = @_;
    my $gene = $self->feature;
    return $gene->name;
}

=head2 show_protein

 Title    : show_protein
 Function : defines if to show protein tab
 Usage    : $show = $self->show_protein();
 Returns  : boolean
 Args     : none
 
=cut

sub show_protein {
    my ($self) = @_;
    my $gene = $self->feature;
    foreach my $transcript ( @{ $gene->transcripts() } ) {
        next if $transcript->type ne 'mRNA';
        return 1;

        #return 1 if $transcript->protein_info;
    }
    return 0;
}

=head2 show_go

 Title    : show_go
 Function : defines if to show go tab
 Usage    : $show = $self->show_go();
 Returns  : boolean
 Args     : none
 
=cut

sub show_go {
    my ($self) = @_;

    my $go = Genome::Tabview::JSON::GO->new( -primary_id => $self->feature->primary_id );
    return $go->{has_annotations} ? 1 : 0;
}

=head2 show_phenotypes

 Title    : show_phenotypes
 Function : defines if to show strains and phenotypes tab
 Usage    : $show = $self->show_phenotypes();
 Returns  : boolean
 Args     : none
 
=cut

sub show_phenotypes {
    my ($self) = @_;
    my $gene = $self->feature;
    return if !@{ $gene->features };
    my $genotypes = $gene->genotype();
    return $genotypes ? 1 : 0;
}

=head2 show_refs

 Title    : show_refs
 Function : defines if to show references tab
 Usage    : $show = $self->show_refs();
 Returns  : boolean
 Args     : none
 
=cut

sub show_refs {
    my ($self) = @_;
    my $gene = $self->feature;
    return if !@{ $gene->features() };
    return $gene->references ? 1 : 0;
}

=head2 show_blast

 Title    : show_blast
 Function : defines if to show blast tab
 Usage    : $show = $self->show_blast();
 Returns  : boolean
 Args     : none
 
=cut

sub show_blast {
    my ($self) = @_;
    my $gene = $self->feature;
    return @{ $gene->features() } ? 1 : 0;
}

=head2 show_orthologs

 Title    : show_orthologs
 Function : defines if to show orthologs tab
 Usage    : $show = $self->show_orthologs();
 Returns  : boolean
 Args     : none
 
=cut

sub show_orthologs {
    my ($self) = @_;
    my $gene = $self->feature;
    return $gene->has_orthologs;
}

=head2 tab_source

 Title    : tab_source
 Usage    : my $source = $self->tab_source( -key => 'go', -primary_id => <GENE ID>;
 Function : composes sorce url for the tab
 Returns  : string
 Args     : -key        : tab key
            -primary_id : primary id of the feature

=cut

sub tab_source {
    my ( $self, @args ) = @_;

    my $arglist = [qw/KEY PRIMARY_ID/];

    my ( $key, $primary_id ) = $self->{root}->_rearrange( $arglist, @args );
    $self->{root}->throw('tab key is not provided') if !$key;

    my $url = $self->base_url || '';
    $url .= '/' . $self->primary_id . "/$key";
    $url .= "/$primary_id" if $primary_id;
    $url .= '.json';
    return $url;
}

=head2 tab

 Title    : tab
 Function : composes tab
 Usage    : $tab = $self->tab( -key =>'go', -primary_id => <GENE ID>, active => 1);
 Returns  : Genome::Tabview::Config::Panel::Item::Tab object
 Args     : -key        : tab key
            -label      : tab label
            -active     : true value result in tab being activated
            -primary_id : primary id of the feature. If not passed, primary id of the page 
                          feature would be used instead
            -href       : href of the tab. If not set, tab key will be used 
=cut

sub tab {
    my ( $self, @args ) = @_;

    my $arglist = [qw/KEY LABEL PRIMARY_ID ACTIVE HREF SOURCE DISPATCH/];
    my ( $key, $label, $primary_id, $active, $href, $source, $dispatch )
        = $self->{root}->_rearrange( $arglist, @args );

    $self->{root}->throw('tab key is not provided')   if !$key;
    $self->{root}->throw('tab label is not provided') if !$label;

    my $active_tab = $active ? 'true' : $self->active_tab
        && $key eq $self->active_tab ? 'true' : 'false';
    $href = $key if !$href;

    $source = $self->tab_source( -key => $key, -primary_id => $primary_id )
        if !$source;

    my $item = Genome::Tabview::Config::Panel::Item::Tab->new(
        -key      => $key,
        -label    => $label,
        -active   => $active_tab,
        -href     => $href,
        -source   => $source,
        -dispatch => $dispatch
    );
    return $item;
}

1;
