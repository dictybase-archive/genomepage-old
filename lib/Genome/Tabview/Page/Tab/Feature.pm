
=head1 NAME

   B<Genome::Tabview::Page::Tab::Feature> - Class for handling feature tab configuration 

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Tab::Feature> version 1.0.0

=head1 SYNOPSIS

    my $tab = Genome::Tabview::Page::Tab::Feature->new( -primary_id => 'DDB0185055' );
    my $json = $tab->configure();
    print $cgi->header(), $json;
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page::Tab::Feature> handles feature tab configuration.
    Based on the type of the feature, determines which sections are available for the tab.

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

package Genome::Tabview::Page::Tab::Feature;

use strict;
use namespace::autoclean;
use Carp;
use Moose;
extends 'Genome::Tabview::Page::Tab';


has '+tab' => ( lazy => 1, default => 'feature' );
has '+parent_feature_id' => (
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $gene = $self->feature->search_related(
            'feature_relationship_subjects',
            { 'type.name' => 'part_of' },
            { join        => 'type' }
            )->search_related(
            'object',
            { 'type_2.name' => 'gene' },
            {   join     => 'type',
                prefetch => 'dbxref'
            }
            );
        return $gene->first->dbxref->accession;
    }
);

has '+feature' => (
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $row = $self->model->resultset('Sequence::Feature')->search(
            {   'dbxref.accession' => $self->primary_id,
            },
            {   join => [qw/dbxref/],
                rows => 1
            }
        )->single;
        croak $self->primary_id, " is not a protein\n" if !$row;
        return $row;
    }
);

before 'feature' => sub {
    my ($self) = @_;
    croak "Need to set the model attribute\n" if !$self->has_model;
};


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
        layout => 'accordion' );

    $panel->add_item($self->accordion(
        key   => 'info',
        label => $self->simple_label("General Information"),
        primary_id => $self->primary_id
    ));
    $panel->add_item($self->accordion(
        key   => 'references',
        label => $self->simple_label("References"),
        primary_id => $self->primary_id
    )) if $self->show_references;

    $config->add_panel($panel);
    $self->config($config);
    return $self;
}

__PACKAGE__->meta->make_immutable;

1;
