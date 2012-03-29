package GenomeREST::Plugin::DefaultHelpers;

use strict;
use Mojo::Base -base;
use base qw/Mojolicious::Plugin/;
use Bio::Symbol::ProteinAlphabet;

has protein_obj => sub {
    my $obj = Bio::Symbol::ProteinAlphabet->new;
};

sub register {
    my ( $self, $app ) = @_;
    $app->helper( is_ddb => sub { $_[1] =~ m{^[A-Z]{3}\d+$} } );
    $app->helper(
        gene2transid => sub {
            my ( $self, $id ) = @_;
            my $model = $app->modware->handler;
            my $row
                = $model->resultset('Sequence::Feature')
                ->search( { 'dbxref.accession' => $id },
                { join => 'dbxref' } )->search_related(
                'feature_relationship_objects',
                { 'type_2.name' => 'part_of' },
                { join          => 'type' }
                )->search_related( 'subject', {}, { rows => 1 } )->single;

            return $row->dbxref->accession if $row;
        }
    );
    $app->helper(
        formatted_sequence => sub {
            my ( $self, $seq, $width ) = @_;
            $width ||= 60;
            $seq =~ s/(\w{1,$width})/$1\n/g;
            return $seq;
        }
    );
    $app->helper(
        protein_alpha => sub {
            my ($c) = @_;
            return grep { $_->name ne 'Ter' } $self->protein_obj->symbols;
        }
    );
    $app->helper(
        amino_label => sub {
            my ( $c, $symbol ) = @_;
            return $symbol->name . '[' . $symbol->token . ']';
        }
    );
    $app->helper(
        amino_count => sub {
            my ( $c, $symbol, $seq ) = @_;
            my $amino = $symbol->token;
            $app->log->debug($amino);
            my $count = ( $seq =~ s/$amino//g );
            return $count;
        }
    );
    $app->helper(
        amino_percent => sub {
            my ( $c, $count, $total ) = @_;
            my $percent = sprintf "%.1f", ( $count * 100 ) / $total ;
            $percent .= '%';
            return $percent;
        }
    );

}
1;
