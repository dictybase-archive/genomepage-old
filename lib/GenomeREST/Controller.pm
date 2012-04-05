package GenomeREST::Controller;

use strict;
use base 'Mojolicious::Controller';
use File::Spec::Functions;
use File::Basename;
use Mojolicious::Static;

sub check_organism {
    my ( $self, $name ) = @_;
    my $model = $self->app->modware->handler;
    return $model->resultset('Organism::Organism')
        ->count( { 'common_name' => $name } );
}

sub set_organism {
    my ( $self, $name ) = @_;
    my $model  = $self->app->modware->handler;
    my $org_rs = $model->resultset('Organism::Organism')
        ->search( { 'common_name' => $name } );
    my $org_row = $org_rs->first;

    $self->stash( $_ => $org_row->$_ ) for qw/species genus abbreviation/;
    if ( $org_row->species =~ /^(\S+)\s+\S+$/ ) {
        $self->stash( 'species' => $1 );
    }
    $self->stash( 'organism_resultset' => $org_rs );
}

sub show_tab {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);
    my $api = 'show_tab_' . $self->stash('format');
    if ( $self->can($api) ) {
        $self->$api;
    }
    else {
        $self->render_not_found;
    }
}

sub show_section {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    my $api = 'show_section_' . $self->stash('format');
    if ( $self->can($api) ) {
        $self->$api;
    }
    else {
        $self->render_not_found;
    }
}

sub show_subsection {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    my $api = 'show_subsection_' . $self->stash('format');
    if ( $self->can($api) ) {
        $self->$api;
    }
    else {
        $self->render_not_found;
    }
}

sub gene_url {
    my ($self) = @_;
    return $self->url_for( '/' . $self->stash('common_name') . '/gene' )
        ->to_string;
}

sub panel_to_json {
    my ( $self, $factory ) = @_;
    my $tabview = $factory->instantiate;
    $tabview->init;
    my $conf = $tabview->config;
    return [ map { $_->to_json } $conf->panels ];

}

sub get_download_folder {
    my ($self) = @_;
    if ( not defined $self->app->config->{default}->{download} ) {
        $self->stash( 'message' => 'Download folder is not configured' );
        $self->render('missing');
        return;
    }

    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);
    return catdir( $self->app->config->{default}->{download}, $common_name );
}

sub sendfile {
    my ( $self, %arg ) = @_;
    if ( !-e $arg{file} ) {
        $self->stash( 'message' => "Download file could not be found" );
        $self->res->code(404);
        $self->render( template => 'missing', format => 'html' );
        return;
    }
    #my $sendfile = 1 if $arg{xsendfile};
    #$sendfile = 1 if $self->app->mode ne 'development';
    #        $self->res->content->asset(
    #            Mojo::Asset::File->new( path => $arg{file} ) );

    my $dispatcher = Mojolicious::Static->new;
    $dispatcher->root(
        catfile(
            $self->app->config->{default}->{download},
            $self->stash('common_name')
        )
    );
    $self->res->headers->content_type(
            $arg{type} ? $arg{type} : 'text/plain' );
    $self->res->headers->content_disposition(
        "attachment;filename=" . basename( $arg{file} ) );
    $dispatcher->serve( $self, basename( $arg{file} ) );
    $self->rendered(200);
}

sub _chado_name {
    my ( $self, $row ) = @_;
    return $row->name ? $row->name : $row->uniquename;
}

1;    # Magic true value required at end of module

__END__

=head1 NAME

<MODULE NAME> - [One line description of module's purpose here]


=head1 VERSION

This document describes <MODULE NAME> version 0.0.1


=head1 SYNOPSIS

use <MODULE NAME>;

=for author to fill in:
Brief code example(s) here showing commonest usage(s).
This section will be as far as many users bother reading
so make it as educational and exeplary as possible.


=head1 DESCRIPTION

=for author to fill in:
Write a full description of the module and its features here.
Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=for author to fill in:
Write a separate section listing the public components of the modules
interface. These normally consist of either subroutines that may be
exported, or methods that may be called on objects belonging to the
classes provided by the module.

=head2 <METHOD NAME>

=over

=item B<Use:> <Usage>

[Detail text here]

=item B<Functions:> [What id does]

[Details if neccessary]

=item B<Return:> [Return type of value]

[Details]

=item B<Args:> [Arguments passed]

[Details]

=back

=head2 <METHOD NAME>

=over

=item B<Use:> <Usage>

[Detail text here]

=item B<Functions:> [What id does]

[Details if neccessary]

=item B<Return:> [Return type of value]

[Details]

=item B<Args:> [Arguments passed]

[Details]

=back


=head1 DIAGNOSTICS

=for author to fill in:
List every single error and warning message that the module can
generate (even the ones that will "never happen"), with a full
explanation of each problem, one or more likely causes, and any
suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
A full explanation of any configuration system(s) used by the
module, including the names and locations of any configuration
files, and the meaning of any environment variables or properties
that can be set. These descriptions must also include details of any
configuration language used.

<MODULE NAME> requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
A list of all the other modules that this module relies upon,
  including any restrictions on versions, and an indication whether
  the module is part of the standard Perl distribution, part of the
  module's distribution, or must be installed separately. ]

  None.


  =head1 INCOMPATIBILITIES

  =for author to fill in:
  A list of any modules that this module cannot be used in conjunction
  with. This may be due to name conflicts in the interface, or
  competition for system or program resources, or due to internal
  limitations of Perl (for example, many modules that use source code
		  filters are mutually incompatible).

  None reported.


  =head1 BUGS AND LIMITATIONS

  =for author to fill in:
  A list of known problems with the module, together with some
  indication Whether they are likely to be fixed in an upcoming
  release. Also a list of restrictions on the features the module
  does provide: data types that cannot be handled, performance issues
  and the circumstances in which they may arise, practical
  limitations on the size of data sets, special cases that are not
  (yet) handled, etc.

  No bugs have been reported.Please report any bugs or feature requests to
  dictybase@northwestern.edu



  =head1 TODO

  =over

  =item *

  [Write stuff here]

  =item *

  [Write stuff here]

  =back


  =head1 AUTHOR

  I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>


  =head1 LICENCE AND COPYRIGHT

  Copyright (c) B<2003>, Siddhartha Basu C<<siddhartha-basu@northwestern.edu>>. All rights reserved.

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



