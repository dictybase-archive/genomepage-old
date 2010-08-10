#!/usr/bin/perl -w

use strict;
use Pod::Usage;
use Getopt::Long;
use Bio::Chado::Schema;
use LWP::UserAgent;
use Log::Log4perl qw/:easy/;
use Log::Log4perl::Appender;
use Log::Log4perl::Layout::PatternLayout;
use Time::Piece;

GetOptions( 'h|help' => sub { pod2usage(1); } );

my $schema
    = Bio::Chado::Schema->connect(
    "dbi:Oracle:host=192.168.60.10;sid=dictybase",
    'DPUR_CHADO', 'DPUR_CHADO', { LongReadLen => 2**25 } );

my $base_url = $ARGV[0] || 'http://192.168.60.50/purpureum/gene/';
my $agent    = LWP::UserAgent->new;
my $logger   = setup_file_logger('cache_preload.log');

my $gene_rs
    = $schema->resultset('Sequence::Feature')
    ->search( { 'type.name' => 'gene' },
    { join => [qw/type/], prefetch => 'dbxref', rows => 6000 } );

my @sub_urls = map { '/gene/' . $_ }
    ( 'info.json', 'genomic_info.json', 'product.json', 'links.json' );

my $gene_count = $gene_rs->count;
$logger->info("going to preload $gene_count gene");
print "going to preload $gene_count gene\n";

my $success = 0;
my $count_done = 0;

while ( my $row = $gene_rs->next ) {
    my $id = $row->dbxref->accession;

    #get the transcript id
    my $trans_rs = $row->feature_relationship_objects->search_related(
        'subject',
        { 'type.name' => 'mRNA' },
        { 'join'      => 'type' }
        )->search_related(
        'dbxref',
        { 'db.name' => 'DB:dictyBaseDP' },
        { join      => 'db' }
        );

    my $url = $base_url . $id;
    my $res = $agent->get($url);
    if ( $res->is_error ) {
        warn $res->code, "\t", $res->message, "\tfailed:$id\n";
    }
    else {
        $logger->info("preloaded $url");
        $success++;
    }

    my $url2 = $url . '/gene.json';
    $res = $agent->get($url2);
    if ( $res->is_error ) {
        warn $res->code, "\t", $res->message, "\tfailed: $url2\n";
    }
    else {
        $logger->info("preloaded $url2");
        $success++;
    }

    for my $sub_entry (@sub_urls) {
        my $sub_url = $url . $sub_entry;
        $res = $agent->get($sub_url);
        if ( $res->is_error ) {
            warn $res->code, "\t", $res->message, "\tfailed: $sub_url\n";
        }
        else {
            $success++;
            $logger->info("preloaded $sub_url");
        }
    }

    my $mRNA_id = $trans_rs->first->accession;
    my @protein_urls = map { '/protein/' . $_ } (
        $mRNA_id . '.json',
        $mRNA_id . '/info.json',
        $mRNA_id . '/sequence.json'
    );

    for my $protein_entry (@protein_urls) {
        my $pro_url = $url . $protein_entry;
        $res = $agent->get($pro_url);
        if ( $res->is_error ) {
            warn $res->code, "\t", $res->message, "\tfailed: $pro_url\n";
        }
        else {
            $success++;
            $logger->info("preloaded $pro_url");
        }
    }

    my @feat_urls = map { '/feature/' . $_ } (
        $mRNA_id . '.json',
        $mRNA_id . '/info.json',
        $mRNA_id . '/references.json'
    );
    for my $feat_entry (@feat_urls) {
        my $furl = $url . $feat_entry;
        $res = $agent->get($furl);
        if ( $res->is_error ) {
            warn $res->code, "\t", $res->message, "\tfailed: $furl\n";
            next;
        }
        else {
            $success++;
            $logger->info("preloaded $furl");
        }
    }
    $count_done++;
    if ($count_done % 2) {
    	print '[ ', Time::Piece->new->cdate , ' ] ',  "Done with $count_done entires\n";
    }
}
print $success, "\n";
$logger->info("preloaded $success indexes");

sub setup_file_logger {
    my $file     = shift;
    my $appender = Log::Log4perl::Appender->new(
        'Log::Log4perl::Appender::File',
        filename => $file,
        mode     => 'clobber'
    );

    my $layout = Log::Log4perl::Layout::PatternLayout->new(
        "[%d{MM-dd-yyyy hh:mm}] %p > %F{1}:%L - %m%n");

    my $log = Log::Log4perl->get_logger();
    $appender->layout($layout);
    $log->add_appender($appender);
    $log->level($DEBUG);
    $log;
}

=head1 NAME

B<Application name> - [One line description of application purpose]


=head1 SYNOPSIS

=for author to fill in:
Brief code example(s) here showing commonest usage(s).
This section will be as far as many users bother reading
so make it as educational and exeplary as possible.


=head1 REQUIRED ARGUMENTS

=for author to fill in:
A complete list of every argument that must appear on the command line.
when the application  is invoked, explaining what each of them does, any
restrictions on where each one may appear (i.e., flags that must appear
		before or after filenames), and how the various arguments and options
may interact (e.g., mutual exclusions, required combinations, etc.)
	If all of the application's arguments are optional, this section
	may be omitted entirely.


	=head1 OPTIONS

	B<[-h|-help]> - display this documentation.

	=for author to fill in:
	A complete list of every available option with which the application
	can be invoked, explaining what each does, and listing any restrictions,
	or interactions.
	If the application has no options, this section may be omitted entirely.


	=head1 DESCRIPTION

	=for author to fill in:
	Write a full description of the module and its features here.
	Use subsections (=head2, =head3) as appropriate.


	=head1 DIAGNOSTICS

	=head1 CONFIGURATION AND ENVIRONMENT

	=head1 DEPENDENCIES

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

	B<Siddhartha Basu>


	=head1 AUTHOR

	I<Siddhartha Basu>  B<siddhartha-basu@northwestern.edu>

	=head1 LICENCE AND COPYRIGHT

	Copyright (c) B<2010>, Siddhartha Basu C<<siddhartha-basu@northwestern.edu>>. All rights reserved.

	This module is free software; you can redistribute it and/or
	modify it under the same terms as Perl itself. See L<perlartistic>.



