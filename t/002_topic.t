#!perl

use strict;
use warnings;

use Test::More qw/no_plan/;
use FindBin;
use lib "$FindBin::Bin/lib";
use Mojo::Client;
use Mojo::Transaction;
use Data::Dumper;
use dicty::Search::Gene;

use_ok('GenomeREST');


my $species = $ENV{SPECIES} || 'discoideum';
my $base_url = '/'.$species.'/gene';

my $name = 'test_CURATED';
my ($gene) = dicty::Search::Gene->find(
    -name       => $name,
    -is_deleted => 'false'
);
my $gene_id = $gene->primary_id;
my ($transcript)  = @{ $gene->transcripts };
my $transcript_id = $transcript->primary_id();

my $client = Mojo::Client->new();

#request for gene
my $tx = Mojo::Transaction->new_get("$base_url/$gene_id/gene.json");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, 'is a successful response for gene' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for gene' );
like( $tx->res->body, qr/layout.+accordion/,
    'has a accordion layout in json content' );


#request for gene with name
$tx = Mojo::Transaction->new_get("$base_url/$name/gene.json");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, "is a successful response for $name gene" );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for gene' );
like( $tx->res->body, qr/layout.+accordion/,
    'has a accordion layout in json content' );


#request for protein
$tx = Mojo::Transaction->new_get("$base_url/$gene_id/protein");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200,
    "is a successful response for protein topic of $name gene" );
like( $tx->res->headers->content_type,
    qr/html/, "is a html content for $name gene" );
like(
    $tx->res->body,
    qr/Gene Information for $name/,
    "is the title for $name gene page"
);

#request for protein with gene name
$tx = Mojo::Transaction->new_get("$base_url/$name/protein");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200,
    "is a successful response for protein topic of $name gene" );
like( $tx->res->headers->content_type,
    qr/html/, "is a html content for $name gene" );
like(
    $tx->res->body,
    qr/Gene Information for $name/,
    "is the title for $name gene page"
);

#request for protein section for json response
$tx = Mojo::Transaction->new_get(
    "$base_url/$gene_id/protein/$transcript_id".'.json');
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200,
    'is a successful response for protein section with json query' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for protein' );
like( $tx->res->body, qr/layout.+accordion/, 'has a accordion layout in protein' );
