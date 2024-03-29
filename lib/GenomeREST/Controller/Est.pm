package GenomeREST::Controller::Est;

use strict;
use base 'GenomeREST::Controller';

sub index {
    my ($self) = @_;
    if ( $self->stash('format') and $self->stash('format') eq 'fasta' ) {
        return $self->fasta;
    }
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);
}

sub fasta {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    my $filename = $common_name . '_est.fa';
    $self->res->headers->content_type('application/x-fasta');
    $self->res->headers->content_disposition(
        "attachment; filename=$filename");
    my $supercontig_rs = $self->stash('organism_resultset')->search_related(
        'features',
        { 'type.name' => 'contig' },
        {   join     => 'type',
            prefetch => 'dbxref'
        }
    );
    while ( my $row = $supercontig_rs->next ) {
        my $seq = $row->residues;
        $seq =~ s/(.{1,60})/$1\n/g;
        $self->write_chunk( '>' . $row->dbxref->accession . "\n$seq" );
    }
    $self->write_chunk('');
}

sub search {
    my ($self) = @_;

    $self->set_organism( $self->stash('common_name') );

    my $rows = $self->param('iDisplayLength');
    my $page = $self->param('iDisplayStart') / $rows + 1;
    my $est_rs;
    if ( my $gene_id = $self->param('gene') ) {
        my $row = $self->stash('organism_resultset')->search_related(
            'features',
            { 'dbxref.accession' => $gene_id },
            { join               => 'dbxref' }
            )->search_related( 'featureloc_features', {}, { rows => 1 } )
            ->single;
        if ( !$row ) {
            $self->render_json(
                {   sEcho                => $self->param('sEcho'),
                    iTotalRecords        => 0,
                    iTotalDisplayRecords => 0,
                    aaData               => []
                }
            );
            return;
        }
        $est_rs = $self->stash('organism_resultset')->search_related(
            'features',
            {   'type.name'                         => 'EST',
                'featureloc_features.fmin'          => { '<=', $row->fmax },
                'featureloc_features.fmax'          => { '>=', $row->fmin },
                'featureloc_features.srcfeature_id' => $row->srcfeature_id
            },
            {   join => [
                    qw/type
                        featureloc_features/
                ],
                prefetch => 'dbxref', 
                rows => $rows, 
                page => $page
            }
        );

    }
    else {
        $est_rs = $self->stash('organism_resultset')->search_related(
            'features',
            { 'type.name' => 'EST' },
            {   join     => 'type',
                prefetch => 'dbxref',
                rows     => $rows,
                page     => $page,
            }
        );
    }

    my $data = [];
    while ( my $row = $est_rs->next ) {
        push @$data, [ $row->dbxref->accession, $row->seqlen ];
    }
    my $total = $est_rs->pager->total_entries;
    $self->render_json(
        {   sEcho                => $self->param('sEcho'),
            iTotalRecords        => $total,
            iTotalDisplayRecords => $total,
            aaData               => $data
        }
    );
}

sub show {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    my $est = $self->stash('organism_resultset')->search_related(
        'features',
        { 'dbxref.accession' => $self->stash('id') },
        { join               => 'dbxref', rows => 1 }
    )->single;

    if ( !$est ) {
        $self->render_not_found;
        return;
    }
    $self->stash( 'est' => $est );
    if ( $self->stash('format') eq 'fasta' ) {
        return $self->show_fasta;
    }
}

sub show_fasta {
    my ($self) = @_;
    my $header = '>' . $self->stash('id') . '|EST';
    $self->render_text( $header . "\n"
            . $self->formatted_sequence( $self->stash('est')->residues ) );
}

1;    # Magic true value required at end of module

