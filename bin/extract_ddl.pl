#!/usr/bin/perl -w

use strict;
use Pod::Usage;
use Getopt::Long;
use DBI;
use Path::Class;

GetOptions( 'h|help' => sub { pod2usage(1); } );

my $connect_str = 'dbi:Oracle:host=192.168.60.10;sid=dictybase';
my $file        = Path::Class::File->new( $ARGV[1] || 'dicty_chado.oracle' );
my $schema      = $ARGV[0] || 'DPUR_CHADO';
my $user        = $schema;
my $pass        = $schema;

my $dbh
    = DBI->connect( $connect_str, $user, $pass, { LongReadLen => 2**25 } );

my $dth = $dbh->prepare(<<SETUP);
BEGIN
 dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM,  'PRETTY',  FALSE);
 dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES',  false );
 dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM,  'STORAGE',  false);
 dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM,  'TABLESPACE',  TRUE );  
 dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS', false );
 dbms_metadata.set_transform_param( DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES',  false );
END;
SETUP

$dth->execute;

my $data = [];
my $sth
    = $dbh->prepare(
    "select dbms_metadata.get_ddl('TABLE', user_tables.table_name) from user_tables"
    );

my $ith
    = $dbh->prepare(
    "select dbms_metadata.get_ddl('INDEX', user_indexes.index_name) from user_indexes"
    );

my $cth
    = $dbh->prepare(
    "select dbms_metadata.get_ddl('REF_CONSTRAINT', user_constraints.constraint_name) from user_constraints where constraint_type = 'R'"
    );

my $seqth
    = $dbh->prepare(
    "select dbms_metadata.get_ddl('SEQUENCE', user_sequences.sequence_name) from user_sequences"
    );

my $tsth
    = $dbh->prepare(
    "select dbms_metadata.get_ddl('TRIGGER', user_triggers.trigger_name) from user_triggers where triggering_event = 'INSERT'"
    );

dump_ddls( $_, $data ) for ( $sth, $cth, $ith, $seqth, $tsth );

$dbh->disconnect;
my $inhandler = $file->openw;

s/\"$schema\"\.//g for @$data;

$inhandler->print( join( "\n\n", @$data ) );
$inhandler->close;

sub dump_ddls {
    my ( $sth, $data ) = @_;
    $sth->execute;
    while ( my ($row) = $sth->fetchrow_array ) {
        push @$data, $row;
    }
}

