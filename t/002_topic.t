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

use_ok('DictyREST');

my $client = Mojo::Client->new();

my $name = 'test_BFNVI_0C0011_07646';
my ($gene) = dicty::Search::Gene->find(
    -name       => $name,
    -is_deleted => 'false'
);
my $gene_id = $gene->primary_id;

#request for gene
my $tx = Mojo::Transaction->new_get("/gene/$gene_id/gene.json");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200, 'is a successful response for gene' );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for gene' );
like( $tx->res->body, qr/layout.+accordion/,
    'has a accordion layout in json content' );

#request for gene with name
$tx = Mojo::Transaction->new_get("/gene/$name/gene.json");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200, "is a successful response for $name gene" );
like( $tx->res->headers->content_type,
    qr/json/, 'is a json content for gene' );
like( $tx->res->body, qr/layout.+accordion/,
    'has a accordion layout in json content' );

#request for protein
$tx = Mojo::Transaction->new_get("/gene/$gene_id/protein");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200,
    "is a successful response for protein topic of $name gene" );
like( $tx->res->headers->content_type,
    qr/html/, "is a html content for $name gene" );
like(
    $tx->res->body,
    qr/Gene page for $name/,
    "is the title for $name gene page"
);

#request for protein with gene name
$tx = Mojo::Transaction->new_get("/gene/$name/protein");
$client->process_app( 'DictyREST', $tx );
is( $tx->res->code, 200,
    "is a successful response for protein topic of $name gene" );
like( $tx->res->headers->content_type,
    qr/html/, "is a html content for $name gene" );
like(
    $tx->res->body,
    qr/Gene page for $name/,
    "is the title for $name gene page"
);

