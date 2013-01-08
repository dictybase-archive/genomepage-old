
=head1 NAME

    B <Genome::Tabview::JSON::Reference> - Class for handling JSON structure conversion for 
    Modware::Publication::DictyBase implementing objects

=head1 VERSION

    This document describes B<Genome::Tabview::JSON::Reference> version 1.0.0

=head1 SYNOPSIS

    my $json_feature = Genome::Tabview::JSON::Reference->new( -primary_id => 'DDB0185055');
    my $curation_status =  = $json_feature->curation_status;
    
=head1 DESCRIPTION

    B<Genome::Tabview::JSON::Reference> is a proxy class that provides feature information 
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

package Genome::Tabview::JSON::Reference;

use strict;
use namespace::autoclean;
use Mouse;
use Genome::Tabview::JSON::Feature::Gene;

has 'pub_id' => (
    is  => 'rw',
    isa => 'Str',
);

=head2 source_feature

 Title    : source_reference
 Usage    : $reference->source_reference($reference);
 Function : gets/sets reference, that would be used as a source for all calls
 Returns  : Modware::Publication::DictyBase object
 Args     : Modware::Publication::DictyBase object

=cut

has 'source_feature' => (
    is       => 'rw',
    isa      => 'Modware::Publication::DictyBase',
    required => 1
);

=head2 json

 Title    : json
 Usage    : $reference->json->link(....);
 Function : gets/sets json handler. Uses Genome::Tabview::Config::Panel::Item::JSON as a default one
 Returns  : nothing
 Args     : JSON handler

=cut

has 'json' => (
    is      => 'rw',
    isa     => 'Genome::Tabview::Config::Panel::Item::JSON',
    lazy    => 1,
    default => sub {
        return Genome::Tabview::Config::Panel::Item::JSON->new;
    }
);

has 'base_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        return $self->context->url_for->to_string;
    }
);

has 'context' => (
    is  => 'rw',
    isa => 'Mojolicious::Controller'
);

=head2 links

 Title    : links
 Usage    : $reference->links();
 Function : returns reference links
 Returns  : array of hashes
 Args     : none

=cut

has 'links' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    lazy    => 1,
    default => sub {
        my ($self)    = @_;
        my $reference = $self->source_feature;
        my $json      = $self->json;
        my ( $dicty_img, $pubmed_img, $full_img );
        $dicty_img = $self->context->image_tag(
            'refDicty.gif',
            alt    => 'dictyBase Papers Entry',
            border => '0'
        );
        $pubmed_img = $self->context->image_tag(
            'refPubmed.gif',
            alt    => 'Pubmed Entry',
            border => '0'
        );
        $full_img = $self->context->image_tag(
            'refFull.gif',
            alt    => 'Reference full text',
            border => '0'
        );

        my $links;
        push @$links,
            $json->link(
            caption => $dicty_img,
            url     => "/publication/" . $reference->pub_id,
            type    => 'outer',
            );

        push @$links,
            $json->link(
            caption => $pubmed_img,
            url  => 'http://view.ncbi.nlm.nih.gov/pubmed/' . $reference->id,
            type => 'outer',
            )
            if $reference->id !~ /^PUB/
                or $reference->id =~ /^\d+/;

        push @$links,
            $json->link(
            caption => $full_img,
            url     => $reference->full_text_url,
            type    => 'outer',
            ) if $reference->has_full_text_url;

        return $links;
    }
);

=head2 citation

 Title    : citation
 Usage    : $reference->citation();
 Function : returns reference citation
 Returns  : hash
 Args     : none

=cut

has 'citation' => (
    is      => 'ro',
    isa     => 'HashRef',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $reference = $self->source_feature;
        return $self->json->text( $reference->formatted_citation );
    }
);

=head2 genes

 Title    : genes
 Usage    : $reference->genes();
 Function : returns reference genes
 Returns  : array
 Args     : none

=cut

sub genes {
    my ($self) = @_;
    my $genes_rs
        = $self->source_feature->dbrow->search_related( 'feature_pubs', {} )
        ->search_related(
        'feature',
        {   'type.name'            => 'gene',
            'organism.common_name' => $self->context->stash('common_name')
        },
        {   join     => [qw/type organism/],
            prefetch => 'dbxref',
            rows     => 6
        }
        );

    my @genes = map {
        Genome::Tabview::JSON::Feature::Gene->new(
            source_feature => $_,
            context        => $self->context,
            base_url       => $self->base_url
            )
    } $genes_rs->all;
    return @genes;

}

sub num_of_genes {
    my ($self) = @_;
    return $self->source_feature->dbrow->search_related( 'feature_pubs', {} )
        ->search_related(
        'feature',
        { 'type.name' => 'gene' },
        { join        => 'type', }
        )->count;
}

__PACKAGE__->meta->make_immutable;

1;
