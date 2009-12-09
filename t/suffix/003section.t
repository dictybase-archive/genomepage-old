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
my $client = Mojo::Client->new();

my ($gene) = dicty::Search::Gene->find(
    -name       => $name,
    -is_deleted => 'false'
);
my $gene_id       = $gene->primary_id;
my ($transcript)  = @{ $gene->transcripts };
my $transcript_id = $transcript->primary_id();

#request for section info under default gene topic
my $tx = Mojo::Transaction->new_get("$base_url/$gene_id/gene/info.json");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, 'is a successful response for info section' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for info' );
like( $tx->res->body, qr/layout.+row/, 'has a row layout in info' );

#request for product section
$tx = Mojo::Transaction->new_get("$base_url/$gene_id/gene/genomic_info.json");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, 'is a successful response for info section' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for product' );
like( $tx->res->body, qr/layout.+row/, 'has a row layout in product' );


#request for product section
$tx = Mojo::Transaction->new_get("$base_url/$gene_id/gene/product.json");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, 'is a successful response for info section' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for product' );
like( $tx->res->body, qr/layout.+row/, 'has a row layout in product' );


#request for section info under protein topic
$tx = Mojo::Transaction->new_get(
    "$base_url/$gene_id/protein/$transcript_id/info");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200,
    'is a successful response for protein info section' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for protein info' );
like( $tx->res->body, qr/layout.+row/, 'has a row layout in protein links' );

#request for section sequence under protein topic
$tx = Mojo::Transaction->new_get(
    "$base_url/$gene_id/protein/$transcript_id/sequence");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200,
    'is a successful response for protein info sequence' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for protein sequence' );
like( $tx->res->body, qr/layout.+row/,
    'has a row layout in protein sequence' );

#request for section sequence under protein topic with explicit json requirement
$tx = Mojo::Transaction->new_get(
    "$base_url/$gene_id/protein/$transcript_id/sequence.json");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200,
    'is a successful json response for protein info sequence' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for protein sequence' );
like( $tx->res->body, qr/layout.+row/,
    'has a row layout in protein sequence' );

#request for feature tab
$tx = Mojo::Transaction->new_get("$base_url/$gene_id/feature");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, 'is a successful response for feature section' );
like( $tx->res->headers->content_type,
    qr/html/, 'is a html content for feature' );

#explicit request for feature tab
$tx = Mojo::Transaction->new_get("$base_url/$gene_id/feature/$transcript_id");
$client->process_app( 'GenomeREST', $tx );
is( $tx->res->code, 200, 'is a successful response for feature section' );
like(
    $tx->res->body,
    qr/Gene page for $name/i,
    "is the title for $name gene page"
);
like(
    $tx->res->body,
    qr/Supported by NIH/i,
    "is the common footer for every gene page"
);
