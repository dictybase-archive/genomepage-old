package GenomeREST::Controller::Mitochondria;

use strict;
use File::Spec::Functions;
use base 'GenomeREST::Controller';

sub dna {
    my ($self) = @_;
    my $folder = $self->get_download_folder;
    return if !$folder;

    ## -- get the top feature type
    my $org_rs     = $self->stash('organism_resultset');
    my $feature_rs = $org_rs->search_related(
        'features',
        { 'featureloc_features.srcfeature_id' => undef },
        { prefetch => 'type', join => 'featureloc_features' }
    );
    my $row = $feature_rs->first;
    if ( !$row ) {
        $self->stash( 'message' => 'Mitochondria sequence for '
                . $self->stash('common_name')
                . ' not found' );
        $self->render('missing');
        return;
    }

    my $file
        = $self->stash('common_name')
        . '_mitochondrial_'
        . $row->type->name . '.'
        . $self->stash('format');
    $self->sendfile(
        file => catfile( $folder, $file ),
        type => 'application/x-fasta'
    );
}

sub feature {
    my ($self) = @_;
    my $folder = $self->get_download_folder;
    return if !$folder;
    my $file
        = $self->stash('common_name')
        . '_mitochondrial_feature.'
        . $self->stash('format');
    $self->sendfile(
        file => catfile( $folder, $file ),
        type => 'application/x-gff3'
    );
}

1;    # Magic true value required at end of module

