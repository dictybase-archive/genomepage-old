
=head1 NAME

   B<Genome::Tabview::Page::Tab> -  Class for handling tab configuration

=head1 VERSION

    This document describes B<Genome::Tabview::Page::Tab> version 1.0.0

=head1 SYNOPSIS

    use base /Genome::Tabview::Page::Tab/;

=head1 DESCRIPTION

    B<Genome::Tabview::Page::Tab>  Class for handling tab configuration

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

package Genome::Tabview::Page::Tab;

use namespace::autoclean;
use Moose;
use MooseX::Params::Validate;
use Carp;
use Genome::Tabview::Config::Panel::Item::JSON;
use Genome::Tabview::Config::Panel::Item::Accordion;

has 'tab'      => ( is => 'rw', isa => 'Str' );
has 'base_url' => ( is => 'rw', isa => 'Str' );
has 'context'  => ( is => 'rw', isa => 'Mojolicious::Controller' );
has 'config'   => ( is => 'rw', isa => 'Genome::Tabview::Config' );
has 'json' =>
    ( is => 'rw', isa => 'Genome::Tabview::Config::Panel::Item::JSON' );
has 'feature' => ( is => 'rw', isa => 'DBIx::Class::Row' );
has 'model' => (is => 'rw',  isa => 'Bio::Chado::Schema,  'predicate => 'has_model');

=head2 process

 Title    : process
 Usage    : $tab->process();
 Function : returns tab section configuration as a json string. 
 Returns  : string
 Args     : string

=cut

sub process {
    my ($self) = @_;
    $self->init;
    my $config = $self->config;
    return $config->to_json;
}

=head2 simple_label

 Title    : simple_label
 Function : returns simple text label
 Usage    : $show = $tab->simple_label("Hello");
 Returns  : hash
 Args     : none
 
=cut

sub simple_label {
    my ( $self, $string ) = @_;
    my $text = $self->json->text($string);
    return [$text];
}

=head2 section_base_url

 Title    : section_base_url
 Usage    : $tab->section_base_url('/db/cgi-bin/dictyBase/yui/section.pl?');
 Function : gets/sets base url for accordion section content retrivial. 
            Uses '/db/cgi-bin/dictyBase/yui/section.pl?' as a default value
 Returns  : string
 Args     : string

=cut

has 'section_base_url' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my ($self) = @_;
        my $gene
            = $self->feature->type eq 'gene'
            ? $self->feature
            : $self->feature->gene;
        return $self->base_url . '/' . $gene->dbxref->accession;
    }
);

=head2 section_source

 Title    : section_source
 Usage    : my $source = $self->tab_source( -key => 'go', -primary_id => <GENE ID>;
 Function : composes sorce url for the section. uses $self->tab to define which tab the section belongs to
 Returns  : string
 Args     : -key        : tab key
            -primary_id : primary id of the feature

=cut

sub section_source {
    my ( $self, %arg ) = validated_hash(
		\@_,
		key => { isa => 'Str'}, 
		primary_id => { isa => 'Str',  optional => 1}
    );

    my $sub_id = $self->feature->type eq 'gene' ? '' : '/' . $arg{primary_id};
    return $self->section_base_url . '/'
        . $self->tab
        . $sub_id . '/'
        . $arg{key} . '.json';
}

=head2 accordion

 Title    : accordion
 Function : composes accordion item
 Usage    : $go = $self->accordion( -key =>'go', -primary_id => <GENE ID>, -label => 'GO Annotation);
 Returns  : Genome::Tabview::Config::Panel::Item::Accordion object
 Args     : -key        : accordion key
            -label      : accordion label
            -primary_id : primary id of the feature. If not passed, primary id of the tab 
                          feature would be used instead
=cut

sub accordion {
    my ( $self, %arg ) = validated_hash(
        \@_,
        key        => { isa => 'Str' },
        label      => { isa => 'Str' },
        primary_id => { isa => 'Str', optional => 1 }
    );

    $primary_id = $self->feature->dbxref->accession if !$arg{$primary_id};
    my $item = Genome::Tabview::Config::Panel::Item::Accordion->new(
        key    => $arg{key},
        label  => $arg{label},
        source => $self->section_source(
            key        => $arg{key},
            primary_id => $primary_id
        ),
    );
    return $item;
}

__PACKAGE__->meta->make_immutable;

1;
