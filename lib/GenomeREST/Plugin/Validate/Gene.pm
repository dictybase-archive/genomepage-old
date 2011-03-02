package GenomeREST::Plugin::Validate::Gene;

use strict;
use base qw/Mojolicious::Plugin/;

sub register {
    my ( $self, $app ) = @_;
    $app->helper(
        check_gene => sub {
            my ( $c, $id ) = @_;
            my $model = $app->modware->handler;

            my $feat = $model->resultset('Sequence::Feature')->search(
                {   -and => [
                        -or => [
                            'UPPER(name)'      => uc $id,
                            'dbxref.accession' => $id
                        ],
                        'organism.species' => $c->stash('species'),
                        'type.name'        => 'gene'
                    ]
                },
                {   join  => [ 'organism', 'dbxref', 'type' ],
                    cache => 1
                }
            )->single;

            return if !$feat;

            my $rs = $feat->featureprops(
                {   'cv.name'   => 'autocreated',
                    'type.name' => 'replaced by'
                },
                { join => { 'type' => 'cv' } }
            );
            my @replaced = map { $_->value } $rs->all;

            $c->stash( replaced => \@replaced ) if @replaced;
            $c->stash( deleted => 1 ) if $feat->get_column('is_deleted');
            $c->stash( gene_id => $feat->dbxref->accession );
            1;
        }
    );
}

1;

=head1 NAME

GenomeRest::Plugin::Validate::Gene - gene id/name validation plugin

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

## in application
plugin "GenomeREST::Plugin::Validate::Gene"

## in controller
my $id       = $self->stash('id');
my $message;
if ( !$self->check_gene($id) ) {
    $message = "gene $id not found",
}
if ($self->stash(deleted)){
    $message = "gene $id is deleted"
}
if ($self->stash(replaced)){
    $message = "gene $id is replaced by" . join(',', @{$self->stash(replaced)})
}

=head1 DESCRIPTION

provides check_gene method for gene name/id valdation. Checks if there is a CHADO feature with 
'gene' type and matching name or primaty dbxref accession. Name search is case insencitive. If
gene exists, controller stash is being populated with gene_id value. If gene is deleted (checks
is_deleted field), "deleted" stash is set to "true". If gene has been replaced (checks for
"replaced by" featureprop), "replaced" stash is set to array reference with list of replacements

=head1 AUTHOR

I<Yulia Bushmanova> B<y-bushmanova@northwestern.edu>

    
