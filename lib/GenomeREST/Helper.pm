package GenomeREST::Helper;

use version; our $VERSION = qv('1.0.0');

# Other modules:
use base qw/Mojolicious::Controller/;
use Module::Load;
use Try::Tiny;

# Module implementation
#
__PACKAGE__->attr( 'species', default => 'discoideum' );

sub is_name {
    my ( $self, $id ) = @_;
    return 0 if $id =~ /^[A-Z]+_G\d+$/;
    return 1;
}

sub is_ddb {
    my ( $self, $id ) = @_;

    ##should get the id signature  from config file
    return 1 if $id =~ /^[A-Z]{3}\d+$/;
    return 0;
}

sub name2id {
    my ( $self, $name ) = @_;
    my $app = $self->app;

    #my $cache = $app->cache;
    #my $key   = $name . '_to_id';

    #if ( $cache->is_valid($key) ) {
    #    my $id = $cache->get($key);
    #    $app->log->debug("got id $id for $name from cache");
    #    return $id;
    #}

    my $model = $app->model;
    my $feat  = $model->resultset('Sequence::Feature')->search(
        {   'name'             => $name,
            'organism.species' => $self->species
        },
        {   join     => 'organism',
            prefetch => 'dbxref',
            rows     => 1
        }
    )->single;

    return 0 if !$feat;
    my $id = $feat->dbxref->accession;

    #$cache->set( $key, $id );
    #$app->log->debug("stored id $id for $name in cache");
    $id;
}

sub process_id {
    my ( $self, $id ) = @_;
    my $gene_id = $id;
    if ( $self->is_name($id) ) {
        $gene_id = $self->name2id($id);
        return 0 if !$gene_id;
    }
    return $gene_id;
}

sub transcript_id {
    my ( $self, $id ) = @_;
    load dicty::Feature;
    my $gene;
    try {
        $gene = dicty::Feature->new( -primary_id => $id );
    }
    catch {
        return 0;
    };
    my ($trans) = @{ $gene->primary_features() };
    $trans->primary_id if $trans;
}

sub parse_url {
    my ( $self, $path ) = @_;
    if ( $path =~ /^((\/\w+)?\/gene)/ ) {
        return $1;
    }
}

sub validate_species {
    my ( $self, $name ) = @_;
    my $cache = $self->app->cache;
    my $org_hash;

    #try from cache
    if ( $cache->is_valid($name) ) {
        $org_hash = $cache->get($name);
        $self->app->log->debug("got organism from cache for $name");
        return $org_hash;
    }

    my $model = $self->app->model;
    my ($organism) = $model->resultset('Organism::Organism')->search(
        -or => [
            { common_name  => $name },
            { abbreviation => $name },
            { species      => $name },
        ]
    );
    return if !$organism;
    $self->species( $organism->species );
    $org_hash = {
        common_name  => $organism->common_name,
        abbreviation => $organism->abbreviation,
        species      => $organism->species,
        genus        => $organism->genus
    };
    $cache->set( $name, $org_hash );
    $self->app->log->debug("stored organism $name in cache");
    $org_hash;
}

1;    # Magic true value required at end of module

__END__

=head1 NAME

<DictyREST::Helper> - [Module providing some common methods for the entire application]


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


