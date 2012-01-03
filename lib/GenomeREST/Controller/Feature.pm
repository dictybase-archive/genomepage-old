package GenomeREST::Controller::Feature;

use strict;
use Genome::Tabview::Page::Gene;
use Genome::Factory::Tabview::Tab;
use Genome::Factory::Tabview::Section;
use base 'GenomeREST::Controller';

sub show_tab_html {
    my ($self) = @_;
    my $db = Genome::Tabview::Page::Gene->new(
        primary_id => $self->stash('id'),
        active_tab => 'feature',
        context    => $self,
        model      => $self->app->modware->handler,
        base_url   => $self->gene_url
    );
    $self->stash( $db->result );
    $self->render( template => 'gene/show' );

}

sub show_tab_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Tab->new(
        tab        => 'feature',
        primary_id => $self->stash('id'),
        model      => $self->app->modware->handler,
        context    => $self,
        base_url   => $self->gene_url
    );
    $self->render_json( $self->panel_to_json($factory) );
}

sub show_section_html {
    my ($self) = @_;
    $self->show_tab_html;

#    my $db = Genome::Tabview::Page::Gene->new(
#        primary_id => $self->stash('id'),
#        active_tab => 'feature',
#        sub_id     => $self->stash('section'),
#        base_url   => $self->gene_url,
#    );
#
#    $self->stash( $db->result );
#    $self->render( template => 'gene/index' );
}

sub show_section_json {
    my ($self) = @_;
    $self->show_tab_json;
}

sub show_subsection_json {
    my ($self) = @_;
    my $factory = Genome::Factory::Tabview::Section->new(
        primary_id => $self->stash('subid'),
        tab        => 'feature',
        section    => $self->stash('subsection'),
        context    => $self,
        model      => $self->app->modware->handler,
        base_url   => $self->gene_url
    );
    $self->render_json( $self->panel_to_json($factory) );
}

sub show_section_fasta {
    my ($self) = @_;
    my $feat = $self->stash('organism_resultset')->search_related(
        'features',
        { 'dbxref.accession' => $self->stash('subid') },
        { join               => 'dbxref', rows => 1 }
    )->single;
    if ( !$feat ) {
        $self->render_not_found;
        return;
    }

    my $header = '>' . $self->stash('subid');
    $self->render_text(
        "$header\n" . $self->formatted_sequence( $feat->residues ) );
}

1;
