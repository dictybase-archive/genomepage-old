
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
use Bio::Root::Root;
use dicty::Feature;

=head2 new

 Title    : new
 Function : constructor for B<Genome::Tabview::Page> object.
 Returns  : Genome::Tabview::Page object 
 Args     : none
 
=cut

sub new {
    my ( $class, @args ) = @_;
    $class = ref $class || $class;
    my $self = {};
    $self->{root} = Bio::Root::Root->new();
    bless $self, $class;
    return $self;
}

=head2 config

 Title    : config
 Usage    : $page->config($config);
 Function : gets/sets the page config
 Returns  : Genome::Tabview::Config object
 Args     : Genome::Tabview::Config object

=cut

sub config {
    my ( $self, $arg ) = @_;

    $self->{config} = $arg if defined $arg;
    $self->{root}->throw('Page config is not defined')
        if not defined $self->{config};
    $self->{root}->throw(
        'Layout should be Genome::Tabview::Config implementing object')
        if ref( $self->{config} ) !~ m{Genome::Tabview::Config};

    return $self->{config};
}

=head2 template

 Title    : template
 Usage    : $page->template($template);
 Function : gets/sets the page template
 Returns  : dicty::Template object
 Args     : dicty::Template object

=cut

sub template {
    my ( $self, $arg ) = @_;

    $self->{template} = $arg if defined $arg;
    $self->{root}->throw('Page template is not defined')
        if not defined $self->{template};
    $self->{root}->throw('Template should be dicty::Template')
        if ref( $self->{template} ) ne 'dicty::Template';

    return $self->{template};
}

=head2 error_template

 Title    : error_template
 Usage    : $page->error_template($template);
 Function : gets/sets the page error template
 Returns  : dicty::Template object
 Args     : dicty::Template object

=cut

sub error_template {
    my ( $self, $arg ) = @_;

    $self->{error_template} = $arg if defined $arg;

    $self->{root}->throw('Error template is not defined')
        if not defined $self->{error_template};
    $self->{root}->throw('Template should be dicty::Template')
        if ref( $self->{error_template} ) ne 'dicty::Template';

    return $self->{error_template};
}

=head2 primary_id

 Title    : primary_id
 Usage    : $page->primary_id($primary_id);
 Function : gets/sets primary id of the feature the page belongs to 
 Returns  : string
 Args     : string

=cut

sub primary_id {
    my ( $self, $arg ) = @_;
    $self->{primary_id} = $arg if defined $arg;

    #    $self->{root}->throw('Primary ID is not defined')
    #        if not defined $self->{primary_id};
    return $self->{primary_id};
}

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
    if ( $feature->is_deleted() ) {
        my $error_message =
            "$primary_id has been deleted from $ENV{'SITE_NAME'}. ";
        if ( $feature->replaced_by() ) {
            my $replaced_id = $feature->replaced_by;
            $error_message .= 'It has been replaced by ';
            $error_message .=
                "<a href=?primary_id=$replaced_id>$replaced_id</a> ";
        }
        return $error_message;
    }
    return 0;
}

=head2 feature

 Title    : feature
 Usage    : $page->feature($feature);
 Function : gets/sets feature
 Returns  : dicty::Feature implementing object
 Args     : dicty::Feature implementing object

=cut

sub feature {
    my ( $self, $arg ) = @_;

    $self->{feature} = $arg if defined $arg;
    $self->{root}->throw('Feature is not defined')
        if not defined $self->{feature};
    $self->{root}->throw('Feature should be dicty::Feature')
        if ref( $self->{feature} ) !~ m{dicty::Feature}x;

    return $self->{feature};
}

=head2 process

 Title    : process
 Usage    : my $output = $page->process();
 Function : Processes page config and returns html. Chooses the template to use 
            based on the result of the ID validation.
 Returns  : string
 Args     : none

=cut

sub process {
    my ( $self, $arg ) = @_;
    my $params;
    my $output;
    my $message = $self->validate_id;

    if ($message) {
        $params->{message} = $message;
        $output = $self->error_template->process($params);
    }
    else {
        $self->init;
        $params->{config} = $self->config->to_json;
        $params->{header} = $self->get_header;
        $output           = $self->template->process($params);
    }
    return $output;
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
    my $output = {
    	config => $conf->to_json,
        header => $self->get_header,
        raw => [ map { $_->to_json } @{ $conf->panels }], 
	};
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

1;
