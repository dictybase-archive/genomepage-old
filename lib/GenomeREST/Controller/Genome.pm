package GenomeREST::Controller::Genome;

use warnings;
use strict;
use File::Spec::Functions;
use Mojolicious::Static;
use base 'Mojolicious::Controller';

sub index {
    my ($self) = @_;
    my $organism_rs = $self->stash('organism_rs');

    my $features_rs =
        $organism_rs->search_related( 'features', {}, { join => 'type' } );

    my $est_count    = $features_rs->count( { 'type.name' => 'EST' } );
    my $contig_count = $features_rs->count( { 'type.name' => 'contig' } );
    my $supercontig_count =
        $features_rs->count( { 'type.name' => 'supercontig' } );

    my $protein_count = $features_rs->count(
        {   -and => [
                'type.name' => 'polypeptide',
                -or         => [
                    'dbxref.accession' => 'JGI',
                    'dbxref.accession' => 'Sequencing Center'
                ]
            ]
        },
        { join => { 'feature_dbxrefs' => 'dbxref' } }
    );

    my $gene = $features_rs->search( { 'type.name' => 'gene' } )->single;
    
    $self->check_gene( $gene->uniquename );  ## this would populate stash with everything we need   

    my $genbank_id = $features_rs->search(
        { uniquename => $self->stash('transcripts')->[0] } )->search_related(
        'feature_dbxrefs',
        { 'db.name' => 'DB:Protein Accession Number' },
        { join      => { 'dbxref' => 'db' } }
        )->single->dbxref->accession;

    $self->render(
        template    => $self->stash('species') . '/index',
        protein     => $protein_count,
        est         => $est_count,
        contig      => $contig_count,
        supercontig => $supercontig_count,
        genbank_id  => $genbank_id
    );
}

sub contig {
    my ( $self, $c ) = @_;
    my $data;
    my $organism_rs = $self->stash('organism_rs');

    my $contig_rs = $organism_rs->search_related(
        'features',
        {   'type.name'   => 'supercontig',
            'type_2.name' => 'gene',
        },
        {   join => [
                'type',
                { 'featureloc_srcfeatures' => { 'feature' => 'type' } }
            ],
            select => [
                'features.feature_id',
                'features.name',
                { count => 'feature_id', -as => 'gene_count' },
            ],
            group_by => [ 'features.feature_id', 'features.name' ],
            having   => \'count(feature_id) > 0',
            order_by => { -asc => 'features.feature_id' },
        }
    );

    if ( $self->stash('page') ) {
        $contig_rs = $contig_rs->search(
            {},
            {   rows => 50,
                page => $self->stash('page')
            }
        );
    }

    while ( my $contig = $contig_rs->next ) {
        my $description = $contig->search_related(
            'featureprops',
            { 'type.name' => 'description' },
            { join        => 'type' }
        )->single->value;
        push @$data,
            [
            $contig->name,
            $organism_rs->search_related(
                'features',
                { feature_id => $contig->feature_id },
                {   select => { length => 'residues' },
                    as     => 'seqlength'
                }
                )->single->get_column('seqlength'),
            $contig->get_column('gene_count'),
            $description,
            ];
    }
    $self->stash(
        dataset  => $data,
        count    => $contig_rs->count,
        url_path => 'contig'
    );
    $self->stash( pager => $contig_rs->pager ) if $self->stash('page');
    $self->render( template => 'contig' );
}

sub download {
    my ($self) = @_;
    my $filename = $self->req->param('file');
    if ($filename) {
        my $dispatcher = Mojolicious::Static->new;
        $dispatcher->root(
            catdir( $self->app->config->{download}, $self->stash('species') )
        );
        $self->res->headers->content_disposition(
            qq{'attatchment; filename="$filename"'});
        $dispatcher->serve( $self, $filename );
        $self->rendered;
    }
    else {
        $self->render( template => $self->stash('species') . '/download' );
    }
}

sub validate {
    my ($self) = @_;
    my $species = $self->stash('species');
    if ( !$self->check_organism($species) ) {
        $self->render_not_found;
        return;
    }
    1;
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



