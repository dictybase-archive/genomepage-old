package GenomeREST::Controller::Contig;

use warnings;
use strict;
use File::Spec::Functions;
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
    $self->render( template => 'contig' );
}

sub fasta {
    my ($self) = @_;
    my $common_name = $self->stash('common_name');
    if ( !$self->check_organism($common_name) ) {
        $self->render_not_found;
        return;
    }
    $self->set_organism($common_name);

    my $filename = $common_name . '_supercontig.fa';
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

    my $contig_rs = $self->stash('organism_resultset')->search_related(
        'features',
        { 'type.name' => 'contig' },
        {   join     => 'type',
            prefetch => 'dbxref',
            rows     => $rows,
            page     => $page,
        }
    );

    my $data = [];
    while ( my $row = $contig_rs->next ) {
        push @$data, [ $row->dbxref->accession, $row->seqlen ];
    }
    my $total = $contig_rs->pager->total_entries;
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

    my $contig = $self->stash('organism_resultset')->search_related(
        'features',
        { 'dbxref.accession' => $self->stash('id') },
        { join               => 'dbxref', rows => 1 }
    )->single;

    if ( !$contig ) {
        $self->render_not_found;
        return;
    }
    $self->stash( 'contig' => $contig );
    if ( $self->stash('format') eq 'fasta' ) {
        return $self->show_fasta;
    }
}

sub show_fasta {
    my ($self) = @_;
    my $header = '>' . $self->stash('id') . '|contig';
    $self->render_text( $header . "\n"
            . $self->formatted_sequence( $self->stash('contig')->residues ) );
}

1;    # Magic true value required at end of module

