
=head1 NAME

    B<Genome::Tabview::Page> - Class for handling tabbed page configuration

=head1 VERSION

    This document describes B<Genome::Tabview::Page> version 1.0.0

=head1 SYNOPSIS

    use base qw(Genome::Tabview::Page);
    
=head1 DESCRIPTION

    B<Genome::Tabview::Page> provides basic functionality for Genome::Tabview::Page
    implementing classes. 

=head1 ERROR MESSAGES AND DIAGNOSTICS

=head1 CONFIGURATION AND ENVIRONMENT

=head1 DEPENDENCIES

use Bio::Root::Root;
use dicty::Feature;

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

package Genome::Tabview::Page;

use strict;
use namespace::autoclean;
use Carp;
use Mouse;

has 'base_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    builder => '_build_base_url'
);

sub _build_base_url {
    my ($self) = @_;
    croak "context attribute need to be set\n" if !$self->has_context;
    return $self->context->url_to;
}

has 'context' => (
    is        => 'rw',
    isa       => 'Mojolicious::Controller',
    predicate => 'has_context'
);

has '_slots_needed' => (
    is         => 'rw',
    isa        => 'ArrayRef',
    auto_deref => 1,
    default    => sub {
        return [qw/model context/];
    },
    lazy => 1
);

has 'model' =>
    ( is => 'rw', isa => 'Bio::Chado::Schema', predicate => 'has_model' );

=head2 config

 Title    : config
 Usage    : $page->config($config);
 Function : gets/sets the page config
 Returns  : Genome::Tabview::Config object
 Args     : Genome::Tabview::Config object

=cut

has 'config' => (
    is  => 'rw',
    isa => 'Genome::Tabview::Config'
);

=head2 primary_id

 Title    : primary_id
 Usage    : $page->primary_id($primary_id);
 Function : gets/sets primary id of the feature the page belongs to 
 Returns  : string
 Args     : string

=cut

has 'primary_id' => (
    is  => 'rw',
    isa => 'Str'
);

=head2 validate_id

 Title    : validate_id
 Usage    : my $mesage = $page->validate_id;
 Function : Validates page feature id and returns message if error occures
 Returns  : string
 Args     : string

=cut

sub validate_id {
    my ($self) = @_;
    my $primary_id = $self->primary_id;

    my $feature;
    eval { $feature = dicty::Feature->new( -primary_id => $primary_id ); };

    if ($@) {
        return "Could not find $primary_id in database."
            if $@ =~ m{Cannot create feature}i;
        return
            "There was an error processing your request. Please report this error to dictyBase: $@";
    }
}

=head2 feature

 Title    : feature
 Usage    : $page->feature($feature);
 Function : gets/sets feature
 Returns  : dicty::Feature implementing object
 Args     : dicty::Feature implementing object

=cut

has 'feature' => (
    is      => 'rw',
    isa     => 'DBIx::Class::Row',
    lazy    => 1,
    builder => '_build_feature'
);

sub _build_feature {
    my ($self) = @_;
    return $self->model->resultset('Sequence::Feature')->search(
        { 'dbxref.accession' => $self->primary_id },
        { join               => 'dbxref', 'rows' => 1 }
    )->single;
}

has 'sub_feature' => (
    is      => 'rw',
    isa     => 'DBIx::Class::Row',
    lazy    => 1,
    builder => '_build_sub_feature'
);

sub _build_sub_feature {
    my ($self) = @_;
    my $rs = $self->feature->search_related(
        'feature_relationship_objects',
        { 'type.name' => 'part_of' },
        { join        => 'type' }
    )->search_related( 'subject', {}, { prefetch => 'dbxref' } );
    return $rs->first;
}

=head2 result

 Title    : result
 Usage    : my $result = $page->result();
 Function : Processes page config but without going through the rendering engine. 
 Returns  : Hash data structure with two keys,  config and header 
 Args     : none

=cut

sub result {
    my ($self) = @_;
    $self->init();
    my $conf = $self->config;
    my $output = { config => $conf->to_json };
    return $output;
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
    return;
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
    return;
}

before 'feature' => sub {
    my ($self) = @_;
    croak "model attribute need to be set before retreiving feature\n"
        if !$self->model;
};

before 'result' => sub {
    my ($self) = @_;
    for my $name ( $self->_slots_needed ) {
        my $api = 'has_' . $name;
        croak "value for $name attribute need to set\n" if !$self->$api;
    }
};

__PACKAGE__->meta->make_immutable;

1;
