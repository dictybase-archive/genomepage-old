package GenomeREST::Controller::Genome;

use warnings;
use strict;

# Other modules:
use GenomeREST::Singleton::Cache;
use base qw/Mojolicious::Controller/;

# Other modules:

# Module implementation
#

sub index {
    my ( $self, $c ) = @_;
    my $species = $c->stash('species');
    my $model   = $self->app->model;
    my $cache   = GenomeREST::Singleton::Cache->cache;

    my $est_key     = $species . '_est';
    my $protein_key = $species . '_protein';
    my ( $est_count, $protein_count );

    if ( $cache->is_valid($est_key) ) {
        $est_count = $cache->get($est_key);
    }
    else {
        $est_count = $model->resultset('Sequence::Feature')->count(
            {   'type.name'        => 'EST',
                'organism.species' => $species
            },
            { join => [ 'type', 'organism' ] }
        );
        $cache->set( $est_key, $est_count );
    }

    if ( $cache->is_valid($protein_key) ) {
        $protein_count = $cache->get($protein_key);
    }
    else {
        $protein_count = $model->resultset('Sequence::Feature')->count(
            {   'type.name'        => 'polypeptide',
                'dbxref.accession' => 'JGI',
                'organism.species' => $species
            },
            {   join =>
                    [ 'type', 'organism', { 'feature_dbxrefs' => 'dbxref' } ]
            }
        );
        $cache->set( $protein_key, $protein_count );
    }

    $self->render(
        handler     => 'index',
        template    => $species,
        species     => $species,
        genus       => $c->stash('genus'),
        abbr        => $c->stash('abbreviation'),
        common_name => $c->stash('common_name'),
        protein     => $protein_count,
        est         => $est_count
    );
}

sub check_name {
    my ( $self, $c ) = @_;
    my $name     = $c->stash('name');
    my $organism = $self->validate_species($name);

    if ( !$organism ) {
        $c->res->code(404);
        $self->render(
            template => 'missing',
            message  => "organism $name not found",
            error    => 1,
            header   => 'Error page',
        );
        return;

    }
    $c->stash(
        species      => $organism->{species},
        abbreviation => $organism->{abbreviation},
        genus        => $organism->{genus},
        common_name  => $organism->{common_name}
    );

    return 1;
}

sub contig {
    my ( $self, $c ) = @_;
    my $data;
    my $model = $self->app->model;
    my $cache = GenomeREST::Singleton::Cache->cache;
    my $rs    = $model->resultset('Sequence::Feature');

    my $contig_key = $c->stash('species') . '_contig';
    if ( $cache->is_valid($contig_key) ) {
        $data = $cache->get($contig_key);
        $self->app->log->debug("got all contigs from cache");
    }
    else {
        my $contig_rs = $rs->search(
            { 'type.name' => 'supercontig', 'type_2.name' => 'gene' },
            {   join => [
                    'type',
                    { 'featureloc_srcfeatures' => { 'feature' => 'type' } }
                ],
                select => [
                    'me.feature_id', 'me.name', { count => 'feature_id' },
                ],
                as       => [ 'cfeature_id',   'cname', 'gene_count' ],
                group_by => [ 'me.feature_id', 'me.name' ],
                having   => \'count(feature_id) > 0',
                order_by => { -asc => 'me.feature_id' }
            }
        );

        while ( my $contig = $contig_rs->next ) {
            push @$data,
                [
                $contig->get_column('cname'),
                $rs->find(
                    { feature_id => $contig->get_column('cfeature_id') },
                    {   select => { length => 'residues' },
                        as     => 'seqlength'
                    }
                    )->get_column('seqlength'),
                $contig->get_column('gene_count')
                ];
        }
        $cache->set( $contig_key, $data,
            $self->app->config->param('cache.expires_in') );
        $self->app->log->debug("put all contigs in cache");
    }

    $c->stash( 'data' => $data, header => 'Contig page' );
    $self->render( template => $c->stash('species') . '/contig' );

}

sub contig_with_page {
    my ( $self, $c ) = @_;
    my $data;
    my $pager;
    my $model = $self->app->model;

    my $rs = $model->resultset('Sequence::Feature');

    #my $contig_key = $c->stash('species') . '_contig_' . $c->stash('page');
    #my $pager_key
    #    = $c->stash('species') . '_contig_' . $c->stash('page') . '_pager';

    #if ( $cache->is_valid($contig_key) ) {
    #    $data  = $cache->get($contig_key);
    #    $pager = $cache->get($pager_key);
    #    $self->app->log->debug("got all paging contigs from cache");
    #}
    #else {
    my $contig_rs = $rs->search(
        { 'type.name' => 'supercontig', 'type_2.name' => 'gene' },
        {   join => [
                'type',
                { 'featureloc_srcfeatures' => { 'feature' => 'type' } }
            ],
            select =>
                [ 'me.feature_id', 'me.name', { count => 'feature_id' }, ],
            as       => [ 'cfeature_id',   'cname', 'gene_count' ],
            group_by => [ 'me.feature_id', 'me.name' ],
            having   => \'count(feature_id) > 0',
            order_by => { -asc => 'me.feature_id' },
            rows     => 50,
            page     => $c->stash('page')
        }
    );

    while ( my $contig = $contig_rs->next ) {
        push @$data,
            [
            $contig->get_column('cname'),
            $rs->find(
                { feature_id => $contig->get_column('cfeature_id') },
                {   select => { length => 'residues' },
                    as     => 'seqlength'
                }
                )->get_column('seqlength'),
            $contig->get_column('gene_count')
            ];
    }

    #$cache->set( $contig_key, $data );
    #$cache->set( $pager_key,  $contig_rs->pager );
    #$self->app->log->debug("putting all paging contigs in cache");

    $c->stash(
        'data' => $data,
        header => 'Contig page',
        pager  => $contig_rs->pager
    );
    $self->render( template => $c->stash('species') . '/contig' );

}

sub name_digit {
    my ( $self, $feat ) = @_;
    my $str = $feat->name;
    $str =~ m{(\d+)$};
    $1;
}

sub validate_species {
    my ( $self, $name ) = @_;
    my $cache = GenomeREST::Singleton::Cache->cache();
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
    $org_hash = {
        common_name  => $organism->common_name,
        abbreviation => $organism->abbreviation,
        species      => $organism->species,
        genus        => $organism->genus
    };
    $cache->set( $name, $org_hash,
        $self->app->config->param('cache.expires_in') );
    $self->app->log->debug("stored organism $name in cache");
    $org_hash;
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


