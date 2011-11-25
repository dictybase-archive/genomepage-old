
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
use namespace::autoclean;
use Mouse;
use Genome::Tabview::Config;
use Genome::Tabview::Config::Panel;
extends 'Genome::Tabview::Page::Section';

has '+feature' => (
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $rs
            = $self->model->resultset('Sequence::Feature')
            ->search( { 'dbxref.accession' => $self->primary_id },
            { join => 'type' } );
        return Genome::Tabview::JSON::Feature::Generic->new(
            source_feature => $rs->first,
            base_url       => $self->base_url,
            context        => $self->context
        );
    }
);

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
        info       => sub { $self->info(@_) },
        references => sub { $self->references(@_) },
    };
    my $config = $settings->{$section}->();
    $self->config($config);
    return $self;
}

=head2 info

 Title    : info
 Function : Returns info section rows for the feature
 Returns  : array  
 Args     : none
 
=cut

sub info {
    my ($self) = @_;
    my $feature = $self->feature;

    my $gbrowse_link = $feature->small_gbrowse_image;
    my $gbrowse_text = $self->json->text(
        '[Click on the map to browse the genome from this location]<br>');

    my $config = Genome::Tabview::Config->new();
    my $panel = Genome::Tabview::Config::Panel->new( -layout => 'row' );

    $panel->add_item( $self->row( 'Feature Type', $feature->display_type ) );
    $panel->add_item( $self->row( 'Sequence ID',  $feature->primary_id ) );
    $panel->add_item(
        $self->row(
            'Map',
            [   $gbrowse->text,     $gbrowse->link,
                $feature->location, $feature->coordinate_table
            ]
        )
    );

    if ( $ext = $feature->external_links ) {
        $panel->add_item( $self->row( 'Links', $ext ) );
    }
    $panel->add_item(
        $self->row(
            'Sequence',
            $feature->get_fasta_selection( base_url => $self->base_url )
        )
    );
    $config->add_panel($panel);
    return $config;
}

=head2 columns

 Title    : columns
 Function : returns reference to an array of Genome::Tabview::Config::Panel::Item::JSON
            objects containing column data. First column would have "title" class 
            that would result in different display.
 Usage    : $columns = $section->columns(@elements);
 Returns  : Genome::Tabview::Config::Panel object
 Args     : array of items to put into columns inside the row
 
=cut

sub columns {
    my ( $self, @column_data ) = @_;
    my @columns;
    my $i = 0;
    foreach my $column (@column_data) {
        my $json_panel = $self->json_panel($column);
        my $class      = $i == 0 ? 'content_table_title' : undef;
        my $colspan    = $i == 0 || @column_data > 2 ? undef : '2';

        push @columns,
            Genome::Tabview::Config::Panel::Item::Column->new(
            -type    => $class,
            -content => [$json_panel],
            -colspan => $colspan,
            );
        $i = 1;
    }
    return \@columns;
}


__PACKAGE__->meta->make_immutable;

1;
