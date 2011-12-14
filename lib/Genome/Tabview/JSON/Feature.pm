
=head1 NAME

    B <Genome::Tabview::JSON::Feature> - Class for handling JSON structure conversion for 
    dicty::Feature implementing objects

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::Feature> version 1.0.0

=head1 SYNOPSIS

    my $json_feature = Genome::Tabview::JSON::Feature->new( -primary_id => 'DDB0185055');
    my $curation_status =  = $json_feature->curation_status;
    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::Feature> is a proxy class that provides feature information 
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

package Genome::Tabview::JSON::Feature;

use namespace::autoclean;
use Mouse;
use MouseX::Params::Validate;
use Genome::Tabview::JSON::Feature::Gene;
use Genome::Tabview::JSON::Reference;
use Module::Load;

=head2 json

 Title    : json
 Usage    : $feature->json->link(....);
 Function : gets/sets json handler. Uses Genome::Tabview::Config::Panel::Item::JSON as default one
 Returns  : nothing
 Args     : JSON handler

=cut

has 'json' => (
    is      => 'rw',
    isa     => 'Genome::Tabview::Config::Panel::Item::JSON',
    lazy    => 1,
    default => sub {
        Genome::Tabview::Config::Panel::Item::JSON->new;
    }
);

has 'context' => ( is => 'rw', isa => 'Mojolicious::Controller' );
has 'base_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->context->url_to;
    }
);

has 'reference_feature' => (
    is      => 'rw',
    isa     => 'DBIx::Class::Row',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $rs
            = $self->source_feature->search_related( 'featureloc_features',
            {} )
            ->search_related( 'srcfeature', {}, { prefetch => 'dbxref' } );
        return $rs->first;
    }
);

has 'reference_feature_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $feat = $self->reference_feature;
        return $self->context->url_to( $self->base_url, $feat->type->name,
            $feat->dbxref->accession );
    }
);

=head2 source_feature

 Title    : source_feature
 Usage    : $feature->source_feature($feature);
 Function : gets/sets feature, that would be used as a source for all calls
 Returns  : DBIx::Class::Row object
 Args     : DBIx::Class::Row object

=cut

has 'source_feature' => (
    is       => 'rw',
    isa      => 'DBIx::Class::Row',
    required => 1
);

=head2 location

 Title    : location
 Function : returns json formatted location notes of a feature 
 Usage    : my $location = $feature->location();
 Returns  : hash
 Args     : none

=cut

sub location {
    my ($self) = @_;
    my $floc = $self->source_feature->featureloc_features->first;
    my $strand = $floc->strand eq '1' ? 'Watson' : 'Crick';
    my $start  = $floc->fmin + 1;
    my $end    = $floc->fmax;

    my $ref_feat = $floc->srcfeature;
    my $str
        = $ref_feat->type->name . "<b>"
        . $ref_feat->name
        . "</b> coordinates <b>$start</b> to <b>$end</b>, <b>$strand</b> strand";

    return $self->json->text($str);
}

=head2 name

 Title    : name
 Function : returns json formatted feature name
 Usage    : my $name = $feature->name();
 Returns  : hash
 Args     : none
 
=cut

sub name {
    my ($self) = @_;
    return $self->json->text( '<i>' . $self->source_feature->name . '</i>' );
}

=head2 primary_id

 Title    : primary_id
 Function : returns json formatted primary id of a feature 
 Usage    : my $primary_id = $feature->primary_id(); 
 Returns  : hash
 Args     : none

=cut

sub primary_id {
    my ($self) = @_;
    return $self->json->text( $self->source_feature->dbxref->accession );
}

=head2 make_external_link

 Title    : make_external_link
 Function : returns external_link for the provided id and type
 Usage    : my $link = $feature->make_external_link(
                source => 'UniProt',
                id    => 'O77203' 
            );
 Returns  : hash with json representetion of a link
 Args     : source : source of the link
            ids    : reference to an array of external ids
            type   : type of the link to be created ('tab'/'outer'). 
                      If not defined, 'outer' will be used as a default value;
=cut

sub make_external_link {
    my ( $self, $source, $id, $type ) = validated_list(
        \@_,
        source => { isa => 'DBIx::Class::Row' },
        id     => { isa => 'Str' },
        type   => { isa => 'Str', optional => 1, default => 'outer' }
    );
	my $name = $source->name;
	my $caption = $name =~ /^DB:/ ? ((split /:/,$name))[1]: $name;

    return $self->json->link(
        url     => $source->urlprefix . $id,
        caption => $caption.':'.$id,
        type    => $type
    );
}

=head2 external_links

 Title    : external_links
 Function : Returns json formatted external links array for the feature
 Returns  : array  
 Args     : none
 
=cut

sub external_links {
    my ($self) = @_;
    my $feature = $self->source_feature();
    my $links;
    for my $xref_row ( grep { $_->db->name ne 'GFF_source' }
        $feature->secondary_dbxrefs )
    {
        push @$links,
            $self->make_external_link(
            source => $xref_row->db,
            id     => $xref_row->accession,
            );
    }
    return $links if defined $links;
}

=head2 description

 Title    : description
 Function : returns json formatted description for the feature
 Usage    : my $description = $feature->description(); 
 Returns  : hash  
 Args     : none
 
=cut

#sub description {
#    my ($self) = @_;
#    my $feature = $self->source_feature;
#    return if !$feature->description;
#    return $self->json->format_url( $feature->description );
#}

=head2 gbrowse_window

 Title    : gbrowse_window
 Function : returns gbrowse window start and end for the feature
 Returns  : string
 Args     : dicty::Feature object

=cut

sub gbrowse_window {
    my ( $self, $feature ) = @_;
    my $floc   = $feature->featureloc_features->single;
    my $start  = $floc->fmin + 1;
    my $end    = $floc->fmax;
    my $length = $end - $start;

    my $window_ext = int( $length / 10 );
    $window_ext = $window_ext > 1000 ? 1000 : $window_ext;

    my $flank_start = $start - $window_ext;
    my $flank_end   = $end + $window_ext;
    my $chrom       = $floc->srcfeature->name;

    my $name = "$chrom:$flank_start..$flank_end";
    return $name;
}

=head2 references

 Title    : references
 Function : returns gene references
 Usage    : @references = @{$gene->references()};
 Returns  : reference to an array of Genome::Tabview::JSON::Reference objects
 Args     : none
 
=cut

has '_reference_stack' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    traits  => [qw/Array/],
    lazy    => 1,
    builder => '_build_references',
    handles => { 'references' => 'elements',  'num_of_references' => 'count' }
);

sub _build_references {
    my ($self) = @_;
    my $pub_rs
        = $self->source_feature->search_related( 'feature_pubs', {} )
        ->search_related( 'pub',
        { order_by => { -desc => 'pyear' }} );
    return [] if !$pub_rs->count;

    load('Modware::Publication::DictyBase');
    my $references;
    while ( my $row = $pub_rs->next ) {
        push @$references,
            Genome::Tabview::JSON::Reference->new(
            source_feature =>
                Modware::Publication::DictyBase->new( dbrow => $row ),
            context => $self->context
            );
    }
    return $references;
}

__PACKAGE__->meta->make_immutable;

1;
