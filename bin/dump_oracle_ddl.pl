#!/usr/bin/perl -w

use strict;
use Pod::Usage;
use Getopt::Long;
use SQL::Translator;
use SQL::Translator::Schema::View;
use IO::File;
use Module::Load qw/load/;
use DBI;

my $dsn  = 'dbi:Oracle:host=192.168.60.10;sid=dictybase';
my $user = 'CGM_CHADO';
my $pass = 'CGM_CHADO';

GetOptions(
    'h|help'            => sub { pod2usage(1); },
    'd|dsn:s'           => \$dsn,
    'u|user:s'          => \$user,
    'p|pass|password:s' => \$pass
);
my $file_name = $ARGV[0] || 'chado.oracle';

my $tr = SQL::Translator->new(
    parser_args => {
        dsn         => $dsn,
        db_user     => $user,
        db_password => $pass
    },
    to => 'Oracle',
);

$tr->parser( \&ora_parse );
my $output = $tr->translate or die $tr->error;
my $file = IO::File->new( $file_name, 'w' ) or die "cannot open file:$!";
$file->print($output);
$file->close;

sub ora_parse {
    my ( $tr, $data ) = @_;
    my $args   = $tr->parser_args;
    my $schema = $tr->schema;

    my $dbh         = $args->{dbh};
    my $dsn         = $args->{dsn};
    my $db_user     = $args->{db_user};
    my $db_password = $args->{db_password};

    if ( !$dbh ) {
        die 'No DSN' if !$dsn;
        $dbh = DBI->connect(
            $dsn, $db_user,
            $db_password,
            {   FetchHashKeyName => 'NAME_lc',
                LongReadLen      => 3000,
                LongTruncOk      => 1,
                RaiseError       => 1,
            }
        );

    }

    die 'No database handle' if not defined $dbh;

    my $driver = $dbh->{Driver}{Name};
    die "only oracle is supported\n" if $driver ne 'Oracle';

    load 'SQL::Translator::Parser::DBI::Oracle';
    SQL::Translator::Parser::DBI::Oracle::parse( $tr, $dbh )
        or die "unable to parse using module\n";

    my $tsth
        = $dbh->prepare(
        "select when_clause from user_triggers where base_object_type = 'TABLE' and triggering_event = 'INSERT' and table_owner = ? and table_name = ?"
        );

    my $psth = $dbh->prepare(
        "select ucol.column_name from user_cons_columns ucol join user_constraints uc
		on uc.constraint_name = ucol.constraint_name 
		where uc.table_name = ?
		AND uc.owner = ?
		AND uc.constraint_type = 'P'"
    );

    my $uth = $dbh->prepare(
        "select constraint_name from user_constraints where table_name = ? and
		constraint_type = 'U' and owner = ?"
    );

    my $ucsth = $dbh->prepare(
        "select column_name from user_cons_columns ucol
         where ucol.constraint_name = ? order by position asc"
    );

    my $csth = $dbh->prepare(
        "select delete_rule from user_constraints where constraint_name = ?");

    my $vsth = $dbh->prepare("select view_name,  text from user_views");

    for my $table ( $schema->get_tables ) {
        my ($when_clause)
            = $dbh->selectrow_array( $tsth, '',
            ( $db_user, uc $table->name ) );

        if ($when_clause) {
            $when_clause =~ s/^\s*//;
            $when_clause =~ s/\s*$//;
            if ( $when_clause =~ /new\.(\S+)\s+IS/ ) {
                if ( my $field = $table->get_field( uc $1 ) ) {
                    if ( $field->is_primary_key ) {
                        $field->is_auto_increment(1);
                        $table->add_constraint(
                            type   => 'PRIMARY_KEY',
                            fields => $field->name
                        );
                    }
                }
            }
        }
        else {
            my ($pk_col)
                = $dbh->selectrow_array( $psth, '',
                ( uc $table->name, $db_user ) );
            if ( my $field = $table->get_field( uc $pk_col ) ) {
                if ( $field->is_primary_key ) {
                    $field->is_auto_increment(1);
                    $table->add_constraint(
                        type   => 'PRIMARY_KEY',
                        fields => $field->name
                    );
                }
            }
        }

		# -- unique constraints
        my ($ucons)
            = $dbh->selectrow_array( $uth, '', ( $table->name, $db_user ) );
        if ($ucons) {
            my $ucols = $dbh->selectcol_arrayref( $ucsth, { Columns => [1] },
                ($ucons) );
            if ( defined $ucols ) {
                $table->add_constraint(
                    type   => 'UNIQUE',
                    fields => $ucols,
                    name   => $ucons
                );
            }
        }

        # -- foreign key constraints for adding on delete actions
        for my $fconst ( $table->fkey_constraints ) {
            my ($del_rule)
                = $dbh->selectrow_array( $csth, '', ( uc $fconst->name ) );
            $fconst->on_delete($del_rule);
        }
    }

	# -- now the views
    $vsth->execute;
    while ( my ( $name, $sql ) = $vsth->fetchrow_array ) {
    	$sql =~ s/\s*$//;
        $schema->add_view(
            SQL::Translator::Schema::View->new(
                name => $name,
                sql  => $sql
            )
        );
    }

    $dbh->disconnect;
    return 1;
}

