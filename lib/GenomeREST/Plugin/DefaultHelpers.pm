package GenomeREST::Plugin::DefaultHelpers;

use strict;
use base qw/Mojolicious::Plugin/;

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
    		my ($self, $seq, $width) = @_;
    		$width ||= 60;
    		$seq =~ s/(\w{1,$width})/$1\n/g;
    		return $seq;
    	}
    );

}
1;
